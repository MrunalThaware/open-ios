//
//  CTSRestIntergration.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSRestIntergration.h"
#import "CTSRestLayer.h"
#import <RestKit/RestKit.h>

@interface CTSRestIntergration : NSObject<CTSRestLayerProtocol> {
  CTSRestLayer* restService;
}
+ (void)initialize;
@end
