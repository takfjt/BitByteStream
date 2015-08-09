// BitByteStream.h
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

#ifndef BitByteStream_h
#define BitByteStream_h

/**
 `BitByteStream` provides conversion stream between bit and byte functionally.
 */
@interface BitByteStream: NSObject

///-------------------------------
/// @name Bit To Byte Stream
///-------------------------------

/**
 The Length of `Bit to Byte Queue`.
 */
@property (atomic, getter=getBitToByteQueueLength,setter=setBitToByteQueueLength:) NSUInteger bitToByteQueueLength;

/**
 Writes a provided bit to the queue.
 
 @param bit The bit to write
 */
- (NSInteger)writeBit:(uint8_t)bit;

- (NSInteger)writeBit:(uint8_t)bit withCount:(NSUInteger)bitCount;

- (NSInteger)readByte:(uint8_t *)buffer maxLength:(NSUInteger)len;

@property (atomic, getter=getByteToBitQueueLength,setter=setByteToBitQueueLength:) NSUInteger byteToBitQueueLength;

@end

#endif
