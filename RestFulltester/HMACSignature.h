//
//  HMACSignature.h
//  RestFulltester
//
//  Created by Raji Nair on 27/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
@interface HMACSignature : NSObject
- (NSString*)generateHMAC:(NSString*)key withData:(NSString*)data;
//
@end
