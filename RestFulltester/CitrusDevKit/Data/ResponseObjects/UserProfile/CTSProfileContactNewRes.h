//
//  CTSProfileContactNewRes.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 16/02/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"

@interface CTSProfileContactNewRes : JSONModel
@property(strong)NSString<Optional>* type;
@property(strong)NSString<Optional>* email;
@property(assign)int emailVerified;
@property(strong)NSString<Optional>* mobile;
@property(assign)int mobileVerified;
@property(strong)NSString<Optional>* firstName;
@property(strong)NSString<Optional>* lastName;
@property(strong)NSString<Optional>* uuid;
@property(assign)NSNumber<Optional> *emailVerifiedDate;
@property(assign)NSNumber<Optional> * mobileVerifiedDate;
@property(assign)NSDate<Ignore> *emailDate;
@property(assign)NSDate<Ignore> * mobileDate;
@end
