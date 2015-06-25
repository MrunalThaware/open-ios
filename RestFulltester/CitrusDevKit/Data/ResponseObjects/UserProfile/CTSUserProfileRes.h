//
//  CTSUserProfileRes.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 23/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"

@interface CTSUserProfileRes : JSONModel
@property(strong)NSString<Optional>* email;
@property(assign)int emailVerified;
@property(assign)NSNumber<Optional> *emailVerifiedDate;
@property(strong)NSString<Optional>* mobile;
@property(assign)int mobileVerified;
@property(assign)NSNumber<Optional> * mobileVerifiedDate;
@property(strong)NSString<Optional>* firstName;
@property(strong)NSString<Optional>* lastName;
@property(strong)NSString<Optional>* uuid;
@end
