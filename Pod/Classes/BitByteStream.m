// BitByteStream.m
// Copyright (c) 2015 Takahiro Fujita
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "BitByteStream.h"

#define MAX_QUEUE_LENGTH (2048)
#define DEFAULT_QUEUE_LENGTH (1024)

@implementation BitByteStream {
  NSMutableArray *queue;
  NSInteger data;
  NSInteger checker;
  NSLock *lockBit;
  NSLock *lockQueue;
  
  NSMutableArray *bitToByteQueue;
  uint8_t bitToByteData, bitToByteDataChecker; // for input, LIFO
  NSLock *bitToByteLock;
  
  NSMutableArray *byteToBitQueue;
  uint8_t byteToBitData, byteToBitDataChecker; // for output, LIFO
  NSLock *byteToBitLock;
}
@synthesize bitToByteQueueLength;
@synthesize byteToBitQueueLength;

#pragma mark -

- (id)init
{
  self = [super init];
  if (self) {
    bitToByteQueue = [NSMutableArray array];
    bitToByteData = 0;
    bitToByteDataChecker = 0;
    bitToByteLock = [[NSLock alloc] init];
    self.bitToByteQueueLength = DEFAULT_QUEUE_LENGTH;

    byteToBitQueue = [NSMutableArray array];
    byteToBitData = 0;
    byteToBitDataChecker = 0;
    byteToBitLock = [[NSLock alloc] init];
    self.byteToBitQueueLength = DEFAULT_QUEUE_LENGTH;
}
  return self;
}


- (void)clearStream
{
  [self _clearBitToByteStream];
  [self _clearByteToBitStream];
}

#pragma mark Bit To Byte Stream

- (NSUInteger)getBitToByteQueueLength
{
  return bitToByteQueueLength;
}

- (void)setBitToByteQueueLength:(NSUInteger)_bitToByteQueueLength
{
  if (_bitToByteQueueLength > MAX_QUEUE_LENGTH) {
    _bitToByteQueueLength = MAX_QUEUE_LENGTH;
  }

  [bitToByteLock lock];
  bitToByteQueueLength = _bitToByteQueueLength;
  while ([bitToByteQueue count] > bitToByteQueueLength) {
    [bitToByteQueue removeLastObject];
  }
  [bitToByteLock unlock];
}

- (NSInteger)_writeBit:(uint8_t)bit
{
  if ([bitToByteQueue count] >= self.bitToByteQueueLength) {
    return 0;
  }

  bitToByteData = (bitToByteData << 1) | (bit & 0x01);
  bitToByteDataChecker++;
  
  if (bitToByteDataChecker == 8) {
    [bitToByteQueue addObject: [NSNumber numberWithInt: (bitToByteData & 0xff)]];
    bitToByteData = 0;
    bitToByteDataChecker = 0;
  }
  
  return 1;
}

- (NSInteger)writeBit:(uint8_t)bit
{
  NSInteger count = 0;
  [bitToByteLock lock];
  count += [self _writeBit:bit];
  [bitToByteLock unlock];
  return count;
}

- (NSInteger)writeBit:(uint8_t)bit withCount:(NSUInteger)bitCount
{
  NSInteger count = 0;
  [bitToByteLock lock];
  while (bitCount--) {
    NSUInteger ret = [self _writeBit:bit];
    if (ret == 0) {
      break;
    }
    count += ret;
  }
  [bitToByteLock unlock];
  return count;
}

- (NSInteger)readByte:(uint8_t *)buffer maxLength:(NSUInteger)len
{
  NSInteger readableLen, i;
  [bitToByteLock lock];

  readableLen = [bitToByteQueue count];
  if (len > readableLen) {
    len = readableLen;
  }

  if (len > 0) {
    for (i = 0; i < len; i++) {
      buffer[i] = (uint8_t)[bitToByteQueue[i] integerValue];
    }
    [bitToByteQueue removeObjectsInRange:NSMakeRange(0, len)];
  }
  
  [bitToByteLock unlock];
  return len;
}

- (void)_clearBitToByteStream
{
  [bitToByteQueue removeAllObjects];
}

- (void)clearBitToByteStream
{
  [bitToByteLock lock];
  [self _clearBitToByteStream];
  [bitToByteLock unlock];
}

#pragma mark Byte to Bit Stream

- (NSUInteger)getByteToBitQueueLength
{
  return byteToBitQueueLength;
}

- (void)setByteToBitQueueLength:(NSUInteger)_byteToBitQueueLength
{
  if (_byteToBitQueueLength > MAX_QUEUE_LENGTH) {
    _byteToBitQueueLength = MAX_QUEUE_LENGTH;
  }
  [byteToBitLock lock];
  byteToBitQueueLength = _byteToBitQueueLength;
  while ([byteToBitQueue count] > byteToBitQueueLength) {
    [byteToBitQueue removeLastObject];
  }
  [byteToBitLock unlock];

}

- (NSInteger)_writeByte:(uint8_t)byte
{
  if ([byteToBitQueue count] >= byteToBitQueueLength) {
    return 0;
  }
  [byteToBitQueue addObject: [NSNumber numberWithInt: (byte & 0xff)]];
  return 1;
}

- (NSInteger)writeByte:(uint8_t)byte
{
  NSInteger count = 0;
  [byteToBitLock lock];
  count += [self _writeByte: byte];
  [byteToBitLock unlock];
  return count;
}

- (NSInteger)writeByteFromBuffer:(uint8_t *)buffer maxLength:(NSUInteger)len
{
  NSInteger count = 0, i;
  [byteToBitLock lock];
  for (i = 0; i < len; i++) {
    count += [self _writeByte: buffer[i]];
  }
  [byteToBitLock unlock];
  return count;
}

- (NSInteger)_readBit:(uint8_t *)buffer
{
  NSInteger count = 0;
  if (byteToBitDataChecker == 0 && [byteToBitQueue count] > 0) {
    byteToBitData = (uint8_t)[byteToBitQueue[0] integerValue];
    [byteToBitQueue removeObjectsInRange: NSMakeRange(0, 1)];
    byteToBitDataChecker = 8;
  }
  if (byteToBitDataChecker > 0) {
    buffer[0] = (byteToBitData >> 7) & 0x01;
    byteToBitData <<= 1;
    byteToBitDataChecker--;
    count++;
  }
  
  return count;
}

- (NSInteger)readBit:(uint8_t *)buffer maxLength:(NSUInteger)len
{
  NSInteger count = 0, i, ret;
  [byteToBitLock lock];

  for (i = 0; i < len; i++) {
    ret =  [self _readBit: (buffer + i)];
    if (ret == 0) {
      break;
    }
    count++;
  }
  
  [byteToBitLock unlock];
  return count;
}

- (void)_clearByteToBitStream
{
  [byteToBitQueue removeAllObjects];
}

- (void)clearByteToBitStream
{
  [byteToBitLock lock];
  [self _clearByteToBitStream];
  [byteToBitLock unlock];
}

@end