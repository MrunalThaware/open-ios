//
//  CTSContactUpdate.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSProfileLayerConstants.h"

@interface CTSContactUpdate : CTSObject
@property(nonatomic, strong) NSString* firstName, *lastName, *email, *mobile;
@property(nonatomic, strong, readonly) NSString* type;
@end
