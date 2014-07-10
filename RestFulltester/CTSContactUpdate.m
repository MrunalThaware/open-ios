//
//  CTSContactUpdate.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSContactUpdate.h"

@implementation CTSContactUpdate
@synthesize type, firstName, lastName, email, mobile;
- (instancetype)init {
  self = [super init];
  if (self) {
    type = MLC_PROFILE_GET_CONTACT_QUERY_TYPE;
  }
  return self;
}
@end
