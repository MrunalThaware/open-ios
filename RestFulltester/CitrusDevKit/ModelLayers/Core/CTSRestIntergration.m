//
//  CTSRestIntergration.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSRestIntergration.h"

@implementation CTSRestIntergration
- (instancetype)init {
  self = [super init];
  if (self) {
    if (self != [CTSRestIntergration class] &&
        ![self conformsToProtocol:@protocol(CTSRestLayerProtocol)]) {
      @throw [[NSException alloc]
          initWithName:@"UnImplimented Protocol"
                reason:@"CTSRestLayerProtocol - not adopted"
              userInfo:nil];
    }
  }
  return self;
}

@end
