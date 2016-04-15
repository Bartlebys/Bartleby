//
//  NSData+CRC.h
//  PdSDeltaSync
//
//  Added by Benoit Pereira da Silva on 26/11/2013.
//  Copyright (c) 2013 Pereira da Silva. All rights reserved.
//

// Extracted from :
// http://classroomm.com/objective-c/index.php?action=printpage;topic=2891.0

#import <Foundation/Foundation.h>

@interface NSData (CRC)

- (uint32_t)crc32;
- (uint32_t)crc32WithSeed:(uint32_t)seed;
- (uint32_t)crc32UsingPolynomial:(uint32_t)poly;
- (uint32_t)crc32WithSeed:(uint32_t)seed usingPolynomial:(uint32_t)poly;

@end
