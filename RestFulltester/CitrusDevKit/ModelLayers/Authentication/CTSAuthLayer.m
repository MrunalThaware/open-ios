//
//  CTSAuthLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSAuthLayer.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSSignUpRes.h"
#import "UserLogging.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSOauthManager.h"
#import <CommonCrypto/CommonDigest.h>
#ifndef MIN
#import <NSObjCRuntime.h>
#endif

@implementation CTSAuthLayer
@synthesize delegate;

//+ (id)sharedRestLayer {
//  static CTSAuthLayer* sharedInstance = nil;
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{ sharedInstance = [[self alloc] init]; });
//  return sharedInstance;
//}

//- (instancetype)init {
//  self = [super init];
//  if (self) {
//    restService = [[CTSRestLayer alloc] initWithBaseURL:CITRUS_AUTH_BASE_URL];
//    [restService register:[self formRegistrationArray]];
//    restService.delegate = self;
//    userNameSignIn = @"";
//    wasSignupCalled = NO;
//    LogTrace(@"authToken %@", [CTSOauthManager readOauthToken]);
//  }
//  return self;
//}

- (NSArray*)formRegistrationArray {
  NSMutableArray* registrationArray = [[NSMutableArray alloc] init];

  // NSDictionary* mappingDictionary = ;

  [registrationArray
      addObject:
          [[CTSRestRegister alloc]
                 initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                   httpMethod:MLC_OAUTH_TOKEN_SIGNUP_REQ_TYPE
               requestMapping:nil
              responseMapping:
                  [[CTSTypeToParameterMapping alloc]
                      initWithType:MLC_OAUTH_TOKEN_SIGNUP_RES_TYPE
                        parameters:MLC_OAUTH_TOKEN_SIGNUP_RESPONSE_MAPPING]]];

  [registrationArray
      addObject:
          [[CTSRestRegister alloc]
                 initWithPath:MLC_SIGNUP_REQ_PATH
                   httpMethod:MLC_SIGNUP_REQ_TYPE
               requestMapping:nil
              responseMapping:[[CTSTypeToParameterMapping alloc]
                                  initWithType:MLC_SIGNUP_RES_TYPE
                                    parameters:MLC_SIGNUP_RESPONSE_MAPPING]]];

  return registrationArray;
}

#pragma mark - public methods

- (void)requestChangePassword:(NSString*)userNameArg {
  NSString* oauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
  if (oauthToken == nil) {
    [delegate auth:self
        didSignupUsername:nil
               oauthToken:oauthToken
                    error:[CTSError getErrorForCode:OauthTokenExpired]];
  }

  if (![CTSUtility validateEmail:userNameArg]) {
    [delegate auth:self
        didSignupUsername:nil
               oauthToken:oauthToken
                    error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  //  [restService postObject:nil
  //                   atPath:
  //               withHeader:[CTSUtility readOauthTokenAsHeader:oauthToken]
  //           withParameters:@{
  //              MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME : userNameArg
  //            } withInfo:nil];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_REQUEST_CHANGE_PWD_REQ_PATH
         requestId:RequestForPasswordChangeReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{
          MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME : userNameArg
        } json:nil
        httpMethod:POST];

  [restCore requestServer:request];
}
- (void)resetSignupCredentials {
  userNameSignup = @"";
  mobileSignUp = @"";
  passwordSignUp = @"";
}

- (void)failedSignupWithError:(NSError*)error {
  [self resetSignupCredentials];
  [delegate auth:self
      didSignupUsername:nil
             oauthToken:[CTSOauthManager readOauthToken]
                  error:error];
}

- (void)requestInternalSignupMobile:(NSString*)mobile email:(NSString*)email {
  if (![CTSUtility validateEmail:email]) {
    [self failedSignupWithError:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  if (![CTSUtility validateMobile:mobile]) {
    [self failedSignupWithError:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

  //  [restService postObject:nil
  //                   atPath:MLC_SIGNUP_REQ_PATH
  //               withHeader:[CTSUtility readSignupTokenAsHeader]
  //           withParameters:@{
  //             MLC_SIGNUP_QUERY_EMAIL : email,
  //             MLC_SIGNUP_QUERY_MOBILE : mobile
  //           } withInfo:nil];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_SIGNUP_REQ_PATH
         requestId:SignupStageOneReqId
           headers:[CTSUtility readSignupTokenAsHeader]
        parameters:@{
          MLC_SIGNUP_QUERY_EMAIL : email,
          MLC_SIGNUP_QUERY_MOBILE : mobile
        } json:nil
        httpMethod:POST];

  [restCore requestServer:request];
}

- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password {
  if (![CTSUtility validateEmail:email]) {
    [self failedSignupWithError:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  if (![CTSUtility validateMobile:mobile]) {
    [self failedSignupWithError:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

  userNameSignup = email;
  mobileSignUp = mobile;
  if (password != nil) {
    passwordSignUp = password;
  } else {
    passwordSignUp = [self generatePseudoRandomPassword];
  }

  [self requestSignUpOauthToken];
}

- (void)requestSignUpOauthToken {
  ENTRY_LOG
  wasSignupCalled = YES;
  //  [restService postObject:nil
  //                   atPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
  //               withHeader:nil
  //           withParameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
  //                 withInfo:MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
         requestId:SignupOauthTokenReqId
           headers:nil
        parameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
              json:nil
        httpMethod:POST];

  [restCore requestServer:request];

  EXIT_LOG
}

- (void)requestOauthTokenRefresh {
  // call for refresh token

  NSDictionary* parameters = @{
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_REFRESH_CLIENT_ID,
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET,
    MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_REFRESH_CLIENT_SECRET,
    MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN : [CTSOauthManager readRefreshToken],
  };

  //  [restService postObject:nil
  //                   atPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
  //               withHeader:nil
  //           withParameters:parameters
  //                 withInfo:MLC_OAUTH_REFRESH_GRANT_TYPE];

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                     requestId:OauthRefreshReqId
                                       headers:nil
                                    parameters:parameters
                                          json:nil
                                    httpMethod:POST];

  [restCore requestServer:request];
}

- (void)requestSigninWithUsername:(NSString*)userNameArg
                         password:(NSString*)password {
  /**
   *  flow sigin in
   check oauth expiry time if oauth token is expired call for refresh token and
   send refresh token
   if refresh token has error then proceed for normal signup

   */

  if (![CTSUtility validateEmail:userNameArg]) {
    [delegate auth:self
        didSigninUsername:userNameArg
               oauthToken:nil
                    error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  userNameSignIn = userNameArg;
  NSDictionary* parameters = @{
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_ID,
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET,
    MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_SIGNIN_GRANT_TYPE,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : password,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : userNameArg
  };

  //  [restService postObject:nil
  //                   atPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
  //               withHeader:nil
  //           withParameters:parameters
  //                 withInfo:MLC_SIGNIN_GRANT_TYPE];

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                     requestId:SigninOauthTokenReqId
                                       headers:nil
                                    parameters:parameters
                                          json:nil
                                    httpMethod:POST];

  [restCore requestServer:request];
}

- (void)usePassword:(NSString*)password
     hashedUsername:(NSString*)hashedUsername {
  ENTRY_LOG

  NSString* oauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
  if (oauthToken == nil) {
    [delegate auth:self
        didSignupUsername:nil
               oauthToken:oauthToken
                    error:[CTSError getErrorForCode:OauthTokenExpired]];
  }
  //  [restService putObject:nil
  //                  atPath:MLC_CHANGE_PASSWORD_REQ_PATH
  //              withHeader:[CTSUtility readOauthTokenAsHeader:oauthToken]
  //          withParameters:@{
  //            MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : hashedUsername,
  //            MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : password
  //          } withInfo:nil];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_CHANGE_PASSWORD_REQ_PATH
         requestId:SignupChangePasswordReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{
          MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : hashedUsername,
          MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : password
        } json:nil
        httpMethod:PUT];

  [restCore requestServer:request];
  EXIT_LOG
}

#pragma mark - CTSRestLayerProtocol methods
- (void)receivedObjectArray:(NSArray*)responseArray
                    forPath:(NSString*)path
                  withError:(NSError*)error
                   withInfo:(NSString*)info {
  ENTRY_LOG
  LogTrace(@" path %@", path);
  BOOL isSuccess = NO;

  if (error == nil)
    isSuccess = YES;

  if ([MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH isEqualToString:path] &&
      [info isEqualToString:MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE]) {
  } else if ([MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH isEqualToString:path] &&
             [info isEqualToString:MLC_SIGNIN_GRANT_TYPE]) {
  } else if ([MLC_SIGNUP_REQ_PATH isEqualToString:path]) {
  } else if ([MLC_CHANGE_PASSWORD_REQ_PATH isEqualToString:path]) {
  } else if ([MLC_REQUEST_CHANGE_PWD_REQ_PATH isEqualToString:path]) {
  } else if ([info isEqualToString:MLC_OAUTH_REFRESH_GRANT_TYPE]) {
  }

  EXIT_LOG
}

#pragma mark - pseudo password generator methods
- (NSString*)generatePseudoRandomPassword {
  // Build the password using C strings - for speed
  int length = 7;
  char* cPassword = calloc(length + 1, sizeof(char));
  char* ptr = cPassword;

  cPassword[length - 1] = '\0';

  char* lettersAlphabet = "abcdefghijklmnopqrstuvwxyz";
  ptr = appendRandom(ptr, lettersAlphabet, 2);

  char* capitalsAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  ptr = appendRandom(ptr, capitalsAlphabet, 2);

  char* digitsAlphabet = "0123456789";
  ptr = appendRandom(ptr, digitsAlphabet, 2);

  char* symbolsAlphabet = "!@#$%*[];?()";
  ptr = appendRandom(ptr, symbolsAlphabet, 1);

  // Shuffle the string!
  for (int i = 0; i < length; i++) {
    int r = arc4random() % length;
    char temp = cPassword[i];
    cPassword[i] = cPassword[r];
    cPassword[r] = temp;
  }
  return [NSString stringWithCString:cPassword encoding:NSUTF8StringEncoding];
}

char* appendRandom(char* str, char* alphabet, int amount) {
  for (int i = 0; i < amount; i++) {
    int r = arc4random() % strlen(alphabet);
    *str = alphabet[r];
    str++;
  }

  return str;
}

- (void)generator:(int)seed {
  seedState = seed;
}

- (int)nextInt:(int)max {
  seedState = 7 * seedState % 3001;
  return (seedState - 1) % max;
}
- (char)nextLetter {
  int n = [self nextInt:52];
  return (char)(n + ((n < 26) ? 'A' : 'a' - 26));
}
static NSData* digest(NSData* data,
                      unsigned char* (*cc_digest)(const void*,
                                                  CC_LONG,
                                                  unsigned char*),
                      CC_LONG digestLength) {
  unsigned char md[digestLength];
  (void)cc_digest([data bytes], [data length], md);
  return [NSData dataWithBytes:md length:digestLength];
}

- (NSData*)md5:(NSString*)email {
  NSData* data = [email dataUsingEncoding:NSASCIIStringEncoding];
  return digest(data, CC_MD5, CC_MD5_DIGEST_LENGTH);
}

- (NSArray*)copyOfRange:(NSArray*)original:(int)from:(int)to {
  int newLength = to - from;
  NSArray* destination;
  if (newLength < 0) {
  } else {
    int copy[newLength];
    destination = [original subarrayWithRange:NSMakeRange(from, newLength)];
  }
  return destination;
}
- (int)genrateSeed:(NSString*)data {
  NSMutableArray* array = [[NSMutableArray alloc] init];
  NSData* hashed = [self md5:data];
  NSUInteger len = [hashed length];
  Byte* byteData = (Byte*)malloc(len);
  [hashed getBytes:byteData length:len];

  int result1[16];
  for (int i = 0; i < 16; i++) {
    Byte b = byteData[i];  // 0xDC;
    result1[i] = (b & 0x80) > 0 ? b - 0xFF - 1 : b;
    [array addObject:[NSNumber numberWithInt:result1[i]]];
  }

  NSArray* val = [self copyOfRange:array:[array count] - 3:[array count]];
  NSData* arrayData = [NSKeyedArchiver archivedDataWithRootObject:val];
  NSLog(@"%@", arrayData);
  int x = 0;
  for (int i = 0; i < [val count]; i++) {
    int z = [[val objectAtIndex:(val.count - 1 - i)] intValue];
    if (z < 0) {
      z = z + 256;
    }
    z = z << (8 * i);
    x = x + z;
    NSLog(@"%d", x);
  }
  return x;
}
- (NSString*)generateBigIntegerString:(NSString*)email {
  int ran = [self genrateSeed:email];

  [self generator:ran];
  NSMutableString* large_CSV_String = [[NSMutableString alloc] init];
  for (int i = 0; i < 8; i++) {
    // Add something from the key?? Your format here.
    [large_CSV_String appendFormat:@"%c", [self nextLetter]];
  }
  NSLog(@"random password:%@", large_CSV_String);
  return large_CSV_String;
}

enum {
  SignupOauthTokenReqId,
  SigninOauthTokenReqId,
  SignupStageOneReqId,
  SignupChangePasswordReqId,
  RequestForPasswordChangeReqId,
  OauthRefreshReqId
};
- (instancetype)init {
  NSDictionary* dict = @{
    toNSString(SignupOauthTokenReqId) : toSelector(handleReqSignupOauthToken
                                                   :),
    toNSString(SigninOauthTokenReqId) : toSelector(handleReqSigninOauthToken
                                                   :),
    toNSString(SignupStageOneReqId) : toSelector(handleReqSignupStageOneComplete
                                                 :),
    toNSString(SignupChangePasswordReqId) : toSelector(handleReqChangePassword
                                                       :),
    toNSString(RequestForPasswordChangeReqId) :
        toSelector(handleReqRequestForPasswordChange
                   :),
    toNSString(OauthRefreshReqId) : toSelector(handleReqOauthRefresh
                                               :)
  };

  self =
      [super initWithRequestSelectorMapping:dict baseUrl:CITRUS_AUTH_BASE_URL];

  return self;
}

- (void)handleReqSignupOauthToken:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  // signup flow
  if (error == nil) {
    CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [CTSUtility saveToDisk:resultObject.accessToken
                        as:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
    [self requestInternalSignupMobile:mobileSignUp email:userNameSignup];
  } else {
    [self failedSignupWithError:error];
    return;
  }
}

- (void)handleReqSigninOauthToken:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  // signup flow
  if (error == nil) {
    CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [resultObject logProperties];
    [CTSOauthManager saveOauthData:resultObject];
    if (wasSignupCalled == YES) {
      // in case of sign up flow
      [self usePassword:passwordSignUp
          hashedUsername:[self generateBigIntegerString:userNameSignup]];
      wasSignupCalled = NO;
    } else {
      // in case of sign in flow

      [delegate auth:self
          didSigninUsername:userNameSignIn
                 oauthToken:[CTSOauthManager readOauthToken]
                      error:error];
    }
  } else {
    [self failedSignupWithError:error];
  }
}

- (void)handleReqSignupStageOneComplete:(CTSRestCoreResponse*)response {
  NSError* error = response.error;

  // change password
  //[self usePassword:TEST_PASSWORD for:SET_FIRSTTIME_PASSWORD];

  // get singn in oauth token for password use use hashed email
  // use it for sending the change password so that the password is set(for
  // old password use username)

  // always use this acess token

  if (error == nil) {
    // signup flow - now sign in
    [self
        requestSigninWithUsername:userNameSignup
                         password:[self
                                      generateBigIntegerString:userNameSignup]];

  } else {
    [self failedSignupWithError:error];
  }
}

- (void)handleReqChangePassword:(CTSRestCoreResponse*)response {
  LogTrace(@"password changed ");
  [self resetSignupCredentials];
  [delegate auth:self
      didSignupUsername:nil
             oauthToken:[CTSOauthManager readOauthToken]
                  error:response.error];
}

- (void)handleReqRequestForPasswordChange:(CTSRestCoreResponse*)response {
  LogTrace(@"password change requested");
}
- (void)handleReqOauthRefresh:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  if (error == nil) {
    CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [CTSOauthManager saveOauthData:resultObject];

    [delegate auth:self
        didRefreshOauthStatus:OauthRefreshStatusSuccess
                        error:error];
  } else {
    [delegate auth:self
        didRefreshOauthStatus:OauthRefreshStatusNeedToLogin
                        error:error];
  }
}
@end
