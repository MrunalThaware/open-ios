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
#import "CTSContactUpdate.h"
#import "CTSUserAddress.h"
#import <UIKit/UIKit.h>

#define CTS_SIGNIN_USER_EMAIL @"CTS_SIGNIN_USER_EMAIL"

@interface CTSUtility : NSObject
+ (NSString*)readFromDisk:(NSString*)key;
+ (void)saveToDisk:(id)data as:(NSString*)key;

+ (NSDictionary*)readSigninTokenAsHeader;
+ (NSDictionary*)readSignupTokenAsHeader;
+ (NSDictionary*)readOauthTokenAsHeader:(NSString*)oauthToken;
+ (void)removeFromDisk:(NSString*)key;
+ (BOOL)validateEmail:(NSString*)email;
+ (BOOL)validateMobile:(NSString*)mobile;
+ (BOOL)validateCardNumber:(NSString*)number;
+ (BOOL)validateExpiryDate:(NSString*)date;
+ (BOOL)validateCVV:(NSString*)cvv cardNumber:(NSString*)cardNumber;
+ (BOOL)toBool:(NSString*)boolString;
+ (NSString*)fetchCardSchemeForCardNumber:(NSString *)cardNumber;
+ (NSDictionary*)getResponseIfTransactionIsFinished:(NSData*)postData;
+ (NSDictionary*)getResponseIfTransactionIsComplete:(UIWebView *)webview ;
+ (UIImage*)getSchmeTypeImage:(NSString*)cardNumber;
+ (BOOL)appendHyphenForCardnumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)appendHyphenForMobilenumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)enterNumericOnly:(NSString*)string;
+ (BOOL)enterCharecterOnly:(NSString*)string;
+ (BOOL)validateCVVNumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)validateCVVNumber:(UITextField*)textField cardNumber:(NSString*)cardNumber replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (NSString*)createTXNId;
+(NSString*)correctExpiryDate:(NSString *)date;
+(BOOL)validateBill:(CTSBill *)bill;
+(BOOL)isVerifyPage:(NSString *)urlString;
+(NSArray *)getLoadResponseIfSuccesfull:(NSURLRequest *)request;
+(BOOL)string:(NSString *)source containsString:(NSString*)desti;
+(void)deleteSigninCookie;
+(BOOL)isCookieSetAlready;
+(BOOL)isMaestero:(NSString *)number;
+(int)extractReqId:(NSMutableDictionary *)response;
+(NSError *)extractError:(NSMutableDictionary *)response;
+(NSDictionary *)errorResponseIfReturnUrlDidntRespond:(NSString *)returnUrl webViewUrl:(NSString *)webviewUrl currentResponse:(NSDictionary *)responseDict;
+(NSDictionary *)errorResponseTransactionForcedClosedByUser;
+(NSString *)toStringBool:(BOOL)paramBool;
+(BOOL)convertToBool:(NSString *)boolStr;
+(BOOL)isEmail:(NSString *)string;
+(NSString *)toJson:(NSDictionary *)dict;
+(NSDictionary *)toDict:(NSString *)json;
+(NSString*)mobileNumberToTenDigitIfValid:(NSString *)number;
+(BOOL)isAmex:(NSString *)number;
+(BOOL)stringContainsSpecialChars:(NSString *)toCheck exceptChars:(NSString*)exceptionChars exceptCharSet:(NSCharacterSet*)exceptionCharSet;
+(BOOL)islengthInvalid:(NSString*)string;
+(BOOL)isURL:(NSURL *)aURL toUrl:(NSURL *)bUrl;
+(NSDictionary *)errorResponseDeviceOffline:(NSError *)error;
+(CTSContactUpdate *)correctContactIfNeeded:(CTSContactUpdate *)contact;
+(CTSUserAddress *)correctAdressIfNeeded:(CTSUserAddress *)address;
+(BOOL)isUserCookieValid;
+(NSError *)verifiyEmailOrMobile:(NSString *)userName;
+(BOOL)validateAmountString:(NSString *)amount;

@end
