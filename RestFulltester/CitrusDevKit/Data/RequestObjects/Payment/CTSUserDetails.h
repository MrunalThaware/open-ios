//
//  CTSUserDetails.h
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CTSUserAddress;
#import "JSONModel.h"
@interface CTSUserDetails : JSONModel
@property(strong) NSString<Optional>* email;
@property(strong) NSString<Optional>* firstName;
@property(strong) NSString<Optional>* lastName;
@property(strong) NSString<Optional>* mobileNo;
@property(strong) CTSUserAddress* address;
@end
