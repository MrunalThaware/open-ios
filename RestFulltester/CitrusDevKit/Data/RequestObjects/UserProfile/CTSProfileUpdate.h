//
//  CTSProfileUpdate.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 23/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"

@interface CTSProfileUpdate : JSONModel
@property(nonatomic, strong) NSString<Optional>* firstName;
@property(nonatomic, strong) NSString<Optional>* lastName;
@property(nonatomic, strong) NSString<Optional>* email;
@property(nonatomic, strong) NSString<Optional>* mobile;
@end
