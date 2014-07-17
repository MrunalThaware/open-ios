//
//  CTSUtility.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 17/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSUtility : NSObject
+ (NSString*)readFromDisk:(NSString*)key;
+ (void)saveToDisk:(NSString*)data as:(NSString*)key;
+ (NSDictionary*)readSigninTokenAsHeader;
+ (NSDictionary*)readSignupTokenAsHeader;
+ (BOOL)validateEmail:(NSString*)email;
+ (BOOL)validateMobile:(NSString*)mobile;
+ (BOOL)validateCardNumber:(NSString*)number;
+ (BOOL)validateExpiryDate:(NSString*)date;
+ (BOOL)validateCVV:(NSString*)cvv cardNumber:(NSString*)cardNumber;
@end
