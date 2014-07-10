//
//  CTSUserDetails.h
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CTSUserAddress;
@interface CTSUserDetails : NSObject
@property(strong) NSString* email, *firstName, *lastName, *mobileNo;
@property(strong) CTSUserAddress* address;
@end
