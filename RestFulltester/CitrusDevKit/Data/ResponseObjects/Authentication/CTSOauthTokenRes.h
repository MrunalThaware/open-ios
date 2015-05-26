//
//  SubcriptionRes.h
//  RestFulltester
/// Users/yadnesh
//  Created by Yadnesh Wankhede on 14/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface CTSOauthTokenRes : JSONModel
@property(strong) NSString* accessToken;
@property(strong) NSString<Optional>* refreshToken;
@property(strong) NSString* tokenType;
@property(assign) long tokenExpiryTime;
@property(strong) NSString* scope;
@property(strong) NSDate<Ignore>* tokenSaveDate;
@end
