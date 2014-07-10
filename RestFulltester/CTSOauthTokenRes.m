//
//  SubcriptionRes.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 14/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSOauthTokenRes.h"

@implementation CTSOauthTokenRes
@synthesize accessToken, tokenType, tokenExpiryTime, scope;
- (NSString*)description {
  return [NSString
      stringWithFormat:
          @"accessToken %@ \n tokenType %@ \n tokenExpiryTime %ld \nscope %@",
          accessToken,
          tokenType,
          tokenExpiryTime,
          scope];
};
@end
