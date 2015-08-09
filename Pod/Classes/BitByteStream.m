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
  uint8_t bitToByteBuffer, bitToByteBufferChecker; // for input, LIFO
  NSLock *bitToByteLock;
  
  NSMutableArray *byteToBitQueue;
  uint8_t byteToBitBuffer, byteToBitBufferChecker; // for output, LIFO
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
    bitToByteBuffer = 0;
    bitToByteBufferChecker = 0;
    bitToByteLock = [[NSLock alloc] init];
    self.bitToByteQueueLength = DEFAULT_QUEUE_LENGTH;

    byteToBitQueue = [NSMutableArray array];
    byteToBitBuffer = 0;
    byteToBitBufferChecker = 0;
    byteToBitLock = [[NSLock alloc] init];
    self.byteToBitQueueLength = DEFAULT_QUEUE_LENGTH;
}
  return self;
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

- (NSUInteger)getByteToBitQueueLength
{
  return byteToBitQueueLength;
}

- (void)setByteToBitQueueLength:(NSUInteger)_byteToBitQueueLength
{
  if (_byteToBitQueueLength > MAX_QUEUE_LENGTH) {
    _byteToBitQueueLength = MAX_QUEUE_LENGTH;
  }
  byteToBitQueueLength = _byteToBitQueueLength;
}

- (NSInteger)_writeBit:(uint8_t)bit
{
  if ([bitToByteQueue count] >= self.bitToByteQueueLength) {
    return 0;
  }

  bitToByteBuffer = (bitToByteBuffer << 1) | (bit & 0x01);
  bitToByteBufferChecker++;
  
  if (bitToByteBufferChecker == 8) {
    [bitToByteQueue addObject: [NSNumber numberWithInt: (bitToByteBuffer & 0xff)]];
    bitToByteBuffer = 0;
    bitToByteBufferChecker = 0;
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

- (NSInteger)writeByte:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
  return 0;
}

- (void)_clearBitToByteStream
{
}
- (void)clearBitToByteStream
{
}

- (void)_clearByteToBitStream
{
}
- (void)clearByteToBitStream
{
}

- (void)clearStream
{
  [self _clearBitToByteStream];
  [self _clearByteToBitStream];
}

@end