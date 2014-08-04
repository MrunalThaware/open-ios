//
//  HMACSignature.m
//  RestFulltester
//
//  Created by Raji Nair on 27/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "HMACSignature.h"

@implementation HMACSignature
- (NSString*)generateHMAC:(NSString*)key withData:(NSString*)data {
  const char* cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
  const char* cData = [data cStringUsingEncoding:NSASCIIStringEncoding];

  uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];

  CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

  NSString* Hash1 = @"";
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    Hash1 = [Hash1
        stringByAppendingString:[NSString stringWithFormat:@"%02x", cHMAC[i]]];
  }
  return Hash1;
}
@end
