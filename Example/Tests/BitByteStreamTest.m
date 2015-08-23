// BitByteStreamTest.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <BitByteStream/BitByteStream.h>

@interface BitByteStreamTest : XCTestCase

@end

@implementation BitByteStreamTest {
  BitByteStream *b;
}

- (void)setUp {
  [super setUp];
  b = [[BitByteStream alloc] init];
}

- (void)tearDown {
  b = nil;
  [super tearDown];
}

- (void)testReadByteFromEmpty {
  uint8_t data[1] = {0};
  NSInteger len;
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");
}

- (void)testReadByteFromNotEnoughBits {
  uint8_t data[1] = {0};
  NSInteger len;
  [b writeBit: 1];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 0];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 1];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 1];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 0];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 1];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 1];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");

  [b writeBit: 1];
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 1, @"Pass");
  XCTAssertEqual(data[0], 0xb7, @"Pass");
}

- (void)testReadByteFromEnoughBits {
  uint8_t data[1] = {0};
  NSInteger len;

  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  [b writeBit: 1];

  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 1, @"Pass");
  XCTAssertEqual(data[0], 0xb7, @"Pass");
}

- (void)testReadByteFromMoreBits {
  uint8_t data[1] = {0};
  NSInteger len;
  
  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  [b writeBit: 1];
  
  [b writeBit: 0]; // 9bit
  
  len = [b readByte: data maxLength: 1];
  XCTAssertEqual(len, 1, @"Pass");
  XCTAssertEqual(data[0], 0xb7, @"Pass");
}

- (void)testReadByteFromSmallData {
  uint8_t data[2] = {0};
  NSInteger len;
  
  [b writeBit: 1 withCount: 8];
  
  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 1, @"Pass");
  XCTAssertEqual(data[0], 0xff, @"Pass");

  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 0, @"Pass");
}

- (void)testReadByteFromEqualData {
  uint8_t data[2] = {0};
  NSInteger len;
  
  [b writeBit: 1 withCount: 16];
  
  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 2, @"Pass");
  XCTAssertEqual(data[0], 0xff, @"Pass");
  XCTAssertEqual(data[1], 0xff, @"Pass");
  
  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 0, @"Pass");
}

- (void)testReadByteFromMoreData {
  uint8_t data[2] = {0};
  NSInteger len;
  
  [b writeBit: 1 withCount: 24];
  
  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 2, @"Pass");
  XCTAssertEqual(data[0], 0xff, @"Pass");
  XCTAssertEqual(data[1], 0xff, @"Pass");
  
  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 1, @"Pass");
  XCTAssertEqual(data[0], 0xff, @"Pass");
}

- (void)testReadByteContinuous {
  uint8_t data[2] = {0};
  NSInteger len;
  
  // 1
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  // 2
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 0];
  // 3
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  
  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 2, @"Pass");
  XCTAssertEqual(data[0], 0x01, @"Pass");
  XCTAssertEqual(data[1], 0x02, @"Pass");

  // 4
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 0];

  len = [b readByte: data maxLength: 2];
  XCTAssertEqual(len, 2, @"Pass");
  XCTAssertEqual(data[0], 0x03, @"Pass");
  XCTAssertEqual(data[1], 0x04, @"Pass");
}

- (void)testReadByteOverInput {
  uint8_t data[4] = {0};
  NSInteger len;
  
  b.bitToByteQueueLength = 2;

  // 1
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  // 2
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 0];
  // 3
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  
  len = [b readByte: data maxLength: 4];
  XCTAssertEqual(len, 2, @"Pass");
  XCTAssertEqual(data[0], 0x01, @"Pass");
  XCTAssertEqual(data[1], 0x02, @"Pass");
  
  
  // 4
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 0];
  // 5
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 0];
  [b writeBit: 1];
  // 6
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 0];
  [b writeBit: 1];
  [b writeBit: 1];
  [b writeBit: 0];
  
  len = [b readByte: data maxLength: 4];
  XCTAssertEqual(len, 2, @"Pass");
  XCTAssertEqual(data[0], 0x04, @"Pass");
  XCTAssertEqual(data[1], 0x05, @"Pass");
}

- (void)testReadBitFromEmpty {
  uint8_t data[1] = {0};
  NSInteger len;
  len = [b readBit: data maxLength: 1];
  XCTAssertEqual(len, 0, @"Pass");
}

- (void)testReadBitFromNotEnoughByte {
  uint8_t data[16] = {0};
  NSInteger len;
  [b writeByte:0xb7];

  len = [b readBit: data maxLength: 16];

  XCTAssertEqual(len, 8, @"Pass");

  XCTAssertEqual(data[0], 0x01, @"Pass");
  XCTAssertEqual(data[1], 0x00, @"Pass");
  XCTAssertEqual(data[2], 0x01, @"Pass");
  XCTAssertEqual(data[3], 0x01, @"Pass");
  XCTAssertEqual(data[4], 0x00, @"Pass");
  XCTAssertEqual(data[5], 0x01, @"Pass");
  XCTAssertEqual(data[6], 0x01, @"Pass");
  XCTAssertEqual(data[7], 0x01, @"Pass");
}

- (void)testReadBitContinuous {
  uint8_t data[16] = {0};
  NSInteger len;

  [b writeByte:0xb7];
  
  len = [b readBit: data maxLength: 4];
  
  XCTAssertEqual(len, 4, @"Pass");
  
  XCTAssertEqual(data[0], 0x01, @"Pass");
  XCTAssertEqual(data[1], 0x00, @"Pass");
  XCTAssertEqual(data[2], 0x01, @"Pass");
  XCTAssertEqual(data[3], 0x01, @"Pass");

  [b writeByte:0xb7];
  
  len = [b readBit: data maxLength: 4];
  
  XCTAssertEqual(len, 4, @"Pass");

  XCTAssertEqual(data[0], 0x00, @"Pass");
  XCTAssertEqual(data[1], 0x01, @"Pass");
  XCTAssertEqual(data[2], 0x01, @"Pass");
  XCTAssertEqual(data[3], 0x01, @"Pass");

  len = [b readBit: data maxLength: 8];
  
  XCTAssertEqual(len, 8, @"Pass");

  XCTAssertEqual(data[0], 0x01, @"Pass");
  XCTAssertEqual(data[1], 0x00, @"Pass");
  XCTAssertEqual(data[2], 0x01, @"Pass");
  XCTAssertEqual(data[3], 0x01, @"Pass");
  XCTAssertEqual(data[4], 0x00, @"Pass");
  XCTAssertEqual(data[5], 0x01, @"Pass");
  XCTAssertEqual(data[6], 0x01, @"Pass");
  XCTAssertEqual(data[7], 0x01, @"Pass");
}

- (void)testReadBitOverInput {
  uint8_t data[32] = {0};
  NSInteger len;

  b.byteToBitQueueLength = 2;

  len = [b writeByte:0x01];

  XCTAssertEqual(len, 1, @"Pass");

  len = [b writeByte:0x02];
  
  XCTAssertEqual(len, 1, @"Pass");

  len = [b writeByte:0x03];
  
  XCTAssertEqual(len, 0, @"Pass");

  len = [b readBit: data maxLength: 32];
  
  XCTAssertEqual(len, 16, @"Pass");

  XCTAssertEqual(data[ 0], 0x00, @"Pass");
  XCTAssertEqual(data[ 1], 0x00, @"Pass");
  XCTAssertEqual(data[ 2], 0x00, @"Pass");
  XCTAssertEqual(data[ 3], 0x00, @"Pass");
  XCTAssertEqual(data[ 4], 0x00, @"Pass");
  XCTAssertEqual(data[ 5], 0x00, @"Pass");
  XCTAssertEqual(data[ 6], 0x00, @"Pass");
  XCTAssertEqual(data[ 7], 0x01, @"Pass");

  XCTAssertEqual(data[ 8], 0x00, @"Pass");
  XCTAssertEqual(data[ 9], 0x00, @"Pass");
  XCTAssertEqual(data[10], 0x00, @"Pass");
  XCTAssertEqual(data[11], 0x00, @"Pass");
  XCTAssertEqual(data[12], 0x00, @"Pass");
  XCTAssertEqual(data[13], 0x00, @"Pass");
  XCTAssertEqual(data[14], 0x01, @"Pass");
  XCTAssertEqual(data[15], 0x00, @"Pass");

  len = [b writeByte:0x04];
  
  XCTAssertEqual(len, 1, @"Pass");
  
  len = [b writeByte:0x05];
  
  XCTAssertEqual(len, 1, @"Pass");
  
  len = [b writeByte:0x06];
  
  XCTAssertEqual(len, 0, @"Pass");
  
  len = [b readBit: data maxLength: 32];
  
  XCTAssertEqual(len, 16, @"Pass");
  
  XCTAssertEqual(data[ 0], 0x00, @"Pass");
  XCTAssertEqual(data[ 1], 0x00, @"Pass");
  XCTAssertEqual(data[ 2], 0x00, @"Pass");
  XCTAssertEqual(data[ 3], 0x00, @"Pass");
  XCTAssertEqual(data[ 4], 0x00, @"Pass");
  XCTAssertEqual(data[ 5], 0x01, @"Pass");
  XCTAssertEqual(data[ 6], 0x00, @"Pass");
  XCTAssertEqual(data[ 7], 0x00, @"Pass");

  XCTAssertEqual(data[ 8], 0x00, @"Pass");
  XCTAssertEqual(data[ 9], 0x00, @"Pass");
  XCTAssertEqual(data[10], 0x00, @"Pass");
  XCTAssertEqual(data[11], 0x00, @"Pass");
  XCTAssertEqual(data[12], 0x00, @"Pass");
  XCTAssertEqual(data[13], 0x01, @"Pass");
  XCTAssertEqual(data[14], 0x00, @"Pass");
  XCTAssertEqual(data[15], 0x01, @"Pass");
}
@end
