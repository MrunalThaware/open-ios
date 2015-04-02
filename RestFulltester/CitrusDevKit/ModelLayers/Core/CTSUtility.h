//
//  CTSUtility.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 17/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSOauthTokenRes.h"
#import "CTSAuthLayerConstants.h"
#import "UserLogging.h"
#import "CTSBill.h"

@interface CTSUtility : NSObject
+ (NSString*)readFromDisk:(NSString*)key;
+ (void)saveToDisk:(id)data as:(NSString*)key;

+ (NSDictionary*)readSigninTokenAsHeader;
+ (NSDictionary*)readSignupTokenAsHeader;
+ (NSDictionary*)readOauthTokenAsHeader:(NSString*)oauthToken;
+ (void)removeFromDisk:(NSString*)key;
+ (BOOL)validateEmail:(NSString*)email;
+ (BOOL)validateMobile:(NSString*)mobile;
+ (NSString *)mobileNumberToTenDigit:(NSString*)mobile;
+(NSString*)mobileNumberToTenDigitIfValid:(NSString *)number;
+(BOOL)isEmail:(NSString *)string;
+ (BOOL)validateCardNumber:(NSString*)number;
+ (BOOL)validateExpiryDate:(NSString*)date;
+ (BOOL)validateCVV:(NSString*)cvv cardNumber:(NSString*)cardNumber;
+ (BOOL)toBool:(NSString*)boolString;
+ (NSString*)fetchCardSchemeForCardNumber:(NSString *)cardNumber;
+ (NSDictionary*)getResponseIfTransactionIsFinished:(NSData*)postData;
+ (UIImage*)getSchmeTypeImage:(NSString*)cardNumber;
+ (BOOL)appendHyphenForCardnumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)appendHyphenForMobilenumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)enterNumericOnly:(NSString*)string;
+ (BOOL)enterCharecterOnly:(NSString*)string;
+ (BOOL)validateCVVNumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (NSString*)createTXNId;
+(BOOL)convertToBool:(NSString *)boolStr;
+(NSString*)correctExpiryDate:(NSString *)date;
+(NSError *)verifiyEmailOrMobile:(NSString *)userName;
+(BOOL)validateBill:(CTSBill *)bill;
+ (NSDictionary*)getResponseIfTransactionIsComplete:(UIWebView *)webview;
+(BOOL)isVerifyPage:(NSString *)urlString;
@end
