//
//  CTSUserVerificationRes.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 14/11/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSUserVerificationRes.h"
#import "CTSError.h"

@implementation CTSUserVerificationRes
-(NSError *)convertToError{
    return [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:UserExits userInfo:@{NSLocalizedDescriptionKey:_respMsg}];
}
@end
