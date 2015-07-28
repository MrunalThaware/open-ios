//
//  CTSProfileLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSProfileLayer.h"
#import "CTSProfileLayerConstants.h"
#import "CTSContactUpdate.h"
#import "CTSProfileContactRes.h"
#import "CTSAuthLayerConstants.h"
#import "CTSError.h"
#import "CTSOauthManager.h"
#import "NSObject+logProperties.h"
#import "CTSAuthLayer.h"
#import "CTSNewUserProfileReq.h"

@implementation CTSProfileLayer

enum {
    ProfileGetContactReqId,
    ProfileUpdateContactReqId,
    ProfileGetPaymentReqId,
    ProfileUpdatePaymentReqId,
    ProfileUpdateMobileRequestId,
    ProfileGetNewContactReqId,
    ProfileGetBalanceReqId,
    ProfileActivatePrepaidAccountReqId,
    ProfileActivatePrepaidAccountReqIdGetBalance,
    ProfileGetUserReqId,
    ProfileUserUpdateReqId,
    ProfileGetNewProfileReqId
};

- (instancetype)init {
    NSDictionary* dic = [self getRegistrationDict];
  self = [super initWithRequestSelectorMapping:dic
                                       baseUrl:CITRUS_PROFILE_BASE_URL];

  return self;
}

-(NSDictionary *)getRegistrationDict{
    return @{
             toNSString(ProfileGetContactReqId) : toSelector(handleReqProfileGetContact:),
             toNSString(ProfileUpdateContactReqId) : toSelector(handleProfileUpdateContact:),
             toNSString(ProfileGetPaymentReqId) : toSelector(handleProfileGetPayment:),
             toNSString(ProfileUpdatePaymentReqId) : toSelector(handleProfileUpdatePayment:),
             toNSString(ProfileUpdateMobileRequestId) : toSelector(handleProfileMobileUpdate:),
             toNSString(ProfileGetNewContactReqId) : toSelector(handleGetNewProfileContact:),
             toNSString(ProfileGetBalanceReqId):toSelector(handleProfileGetBanlance:),
             toNSString(ProfileActivatePrepaidAccountReqId):toSelector(handleActivatePrepaidAccount:),
             toNSString(ProfileActivatePrepaidAccountReqIdGetBalance):toSelector(handleActivatePrepaidAccountWithGetBalance:),
             toNSString(ProfileGetUserReqId):toSelector(handleReqUserProfile:),
             toNSString(ProfileUserUpdateReqId):toSelector(handleReqUpdateUserProfile:),
             toNSString(ProfileGetNewProfileReqId) : toSelector(handleGetNewContactProfile:)
             };
}


- (instancetype)initWithUrl:(NSString *)url
{
    
    if(url == nil){
        url = CITRUS_PROFILE_BASE_URL;
    }
    self = [super initWithRequestSelectorMapping:[self getRegistrationDict]
                                         baseUrl:url];
    return self;
}

#pragma mark - class methods

- (void)updateContactInformation:(CTSContactUpdate*)contactInfo
           withCompletionHandler:(ASUpdateContactInfoCallBack)callback {
  [self addCallback:callback forRequestId:ProfileUpdateContactReqId];

  OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
  NSString* oauthToken = oauthStatus.oauthToken;

  if (oauthStatus.error != nil) {
    [self updateContactInfoHelper:oauthStatus.error];
    return;
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
         requestId:ProfileUpdateContactReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:nil
              json:[contactInfo toJSONString]
        httpMethod:PUT];

  [restCore requestAsyncServer:request];
}

- (void)requestContactInformationWithCompletionHandler:
            (ASGetContactInfoCallBack)callback {
  [self addCallback:callback forRequestId:ProfileGetContactReqId];

  OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
  NSString* oauthToken = oauthStatus.oauthToken;

  if (oauthStatus.error != nil) {
    [self getContactInfoHelper:nil error:oauthStatus.error];

    return;
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
         requestId:ProfileGetContactReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:nil
              json:nil
        httpMethod:GET];

  [restCore requestAsyncServer:request];
}

- (void)updatePaymentInformation:(CTSPaymentDetailUpdate*)paymentInfo
           withCompletionHandler:(ASUpdatePaymentInfoCallBack)callback {
    [self addCallback:callback forRequestId:ProfileUpdatePaymentReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self updatePaymentInfoHelper:oauthStatus.error];
        return;
    } else {
        CTSErrorCode error = [paymentInfo validate];
        if (error != NoError) {
            [self updatePaymentInfoHelper:[CTSError getErrorForCode:error]];
            return;
        }
    }
    
    [paymentInfo doCardCorrectionsIfNeeded];
    [paymentInfo clearCVV];
    [paymentInfo clearNetbankCode];
    
    if (oauthStatus.error != nil) {
        [self updatePaymentInfoHelper:[CTSError getErrorForCode:UserNotSignedIn]];
        return;
        return;
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
                                   requestId:ProfileUpdatePaymentReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:[paymentInfo toJSONString]
                                   httpMethod:PUT];
    
    [restCore requestAsyncServer:request];
}

- (void)requestPaymentInformationWithCompletionHandler:
            (ASGetPaymentInfoCallBack)callback {
  [self addCallback:callback forRequestId:ProfileGetPaymentReqId];

  OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
  NSString* oauthToken = oauthStatus.oauthToken;

  if (oauthStatus.error != nil) {
    [self getPaymentInfoHelper:nil error:oauthStatus.error];
      return;
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
         requestId:ProfileGetPaymentReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:nil
              json:nil
        httpMethod:GET];

  [restCore requestAsyncServer:request];
}



- (void)requestUpdateMobile:(NSString *)mobileNumber allowUnverified:(BOOL)allowUnverified WithCompletionHandler:
(ASUpdateMobileNumberCallback)callback;{
    [self addCallback:callback forRequestId:ProfileUpdateMobileRequestId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self updateMobileHelper:oauthStatus.error];
        return;
    }
    
    CTSUserVerificationRes *verificationResponse = [CTSAuthLayer requestSyncIsUserAlreadyRegisteredMobileOrEmail:mobileNumber];
    if(allowUnverified == NO &&( verificationResponse.error  || verificationResponse.respCode == 202 || verificationResponse.respCode == 203)){
        [self updateMobileHelper:[CTSError getErrorForCode:MobileAlreadyExits]];
        return;
    }
    else if(allowUnverified == YES &&( verificationResponse.error  ||  verificationResponse.respCode == 203)){
        [self updateMobileHelper:[CTSError getErrorForCode:MobileAlreadyExits]];
        return;
        
    }
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_UPDATE_MOBILE_PATH
                                   requestId:ProfileUpdateMobileRequestId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:@{MLC_PROFILE_UPDATE_MOBILE_QUERY_MOBILE:mobileNumber}
                                   json:nil
                                   httpMethod:POST];
    
    [restCore requestAsyncServer:request];
}




-(void)requestContactInfoNewWithCompletionHandler:(ASGetContactInfoNewCallback)callback{
    [self addCallback:callback forRequestId:ProfileGetNewContactReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self getNewProfileHelper:nil error:oauthStatus.error];
        return;
    }

    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_GET_NEW_CONTACT
                                   requestId:ProfileGetNewContactReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    
    [restCore requestAsyncServer:request];
}

#define IS_CALLED_ACTIVATION @"alreadyCalledActivationAccount"

-(void)requestGetBalance:(ASGetBalanceCallBack)calback{
    [self addCallback:calback forRequestId:ProfileGetBalanceReqId];
    

    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;

    
    if (oauthStatus.error != nil || oauthToken == nil) {
        [self getBalanceHelper:nil error:oauthStatus.error];
        
    }
    [self requestActivatePrepaidAccountGetBalance:^(CTSAmount *amount, NSError *error) {
        [self getBalanceHelper:amount error:error];

    }];
}


-(void)proceedToGetBalance{
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_GET_BALANCE_PATH
                                   requestId:ProfileGetBalanceReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    
    [restCore requestAsyncServer:request];
}



-(void)requestActivatePrepaidAccount:(ASActivatePrepaidCallBack)callback{
    [self addCallback:callback forRequestId:ProfileActivatePrepaidAccountReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self activatePrepaidHelper:NO error:oauthStatus.error];
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_GET_BALANCE_ACTIVATE_PATH
                                   requestId:ProfileActivatePrepaidAccountReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    
    [restCore requestAsyncServer:request];
}


-(void)requestActivatePrepaidAccountGetBalance:(ASGetBalanceCallBack)callback{
    [self addCallback:callback forRequestId:ProfileActivatePrepaidAccountReqIdGetBalance];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self activatePrepaidHelper:NO error:oauthStatus.error];
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_GET_BALANCE_ACTIVATE_PATH
                                   requestId:ProfileActivatePrepaidAccountReqIdGetBalance
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    
    [restCore requestAsyncServer:request];
}

// 23062015 UM API's
- (void)requestGetUserProfileDetailsWithCompletionHandler:(ASGetUserProfileDetailsCallBack)callback {
    [self addCallback:callback forRequestId:ProfileGetUserReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self getUserProfileHelper:nil error:oauthStatus.error];
        return;
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_GET_USER_PROFILE_DETAILS_PATH
                                   requestId:ProfileGetUserReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    
    [restCore requestAsyncServer:request];
}

// 23062015 UM API's
- (void)updateUserProfileDetails:(CTSProfileUpdate*)profileUpdate withCompletionHandler:(ASUpdateUserProfileDetailsCallBack)callback {
    [self addCallback:callback forRequestId:ProfileUserUpdateReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self updateContactInfoHelper:oauthStatus.error];
        return;
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PROFILE_UPDATE_DETAILS_PATH
                                   requestId:ProfileUserUpdateReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:[profileUpdate toJSONString]
                                   httpMethod:PUT];
    
    [restCore requestAsyncServer:request];
}


-(void)requestMemberInfoWithMobile:(NSString *)mobile withEmail:(NSString *)email
             withCompletionHandler:(ASNewContactProfileCallback)callback{
    
    [self addCallback:callback forRequestId:ProfileGetNewProfileReqId];
    
    CTSNewUserProfileReq *profileReq = [[CTSNewUserProfileReq alloc] init];
    if (email && mobile) {
        if (![CTSUtility validateEmail:email]) {
            [self getNewContactProfileHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
        
        if (![CTSUtility mobileNumberToTenDigitIfValid:mobile]) {
            [self getNewContactProfileHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
        
        profileReq.mobile = mobile;
        profileReq.email = email;
        
    } else if (email){
        if (![CTSUtility validateEmail:email]) {
            [self getNewContactProfileHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
        profileReq.email = email;
        
    }else if (mobile){
        if (![CTSUtility mobileNumberToTenDigitIfValid:mobile]) {
            [self getNewContactProfileHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
        profileReq.mobile = mobile;
        
    }
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus];
    if (oauthStatus.error != nil) {
        [self getNewContactProfileHelper:nil error:oauthStatus.error];
    }

    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_MEMBER_INFO_PATH
                                   requestId:ProfileGetNewProfileReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
                                   parameters:nil
                                   json:[profileReq toJSONString]
                                   httpMethod:POST];
    
    [restCore requestAsyncServer:request];
}

#pragma mark - response handlers methods

- (void)handleReqProfileGetContact:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSProfileContactRes* contact = nil;
    if (error == nil) {
        contact =
        [[CTSProfileContactRes alloc] initWithString:response.responseString
                                               error:&jsonError];
        [contact logProperties];
    }
    [self getContactInfoHelper:contact error:error];
}

- (void)handleReqUserProfile:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSUserProfileRes* userProfile = nil;
    if (error == nil) {
        userProfile = [[CTSUserProfileRes alloc] initWithString:response.responseString
                                               error:&jsonError];
        [userProfile logProperties];
    }
    [self getUserProfileHelper:userProfile error:error];
}

- (void)handleReqUpdateUserProfile:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSUpdateUserProfileRes* userProfile = nil;
    if (error == nil) {
        userProfile = [[CTSUpdateUserProfileRes alloc] initWithString:response.responseString
                                                          error:&jsonError];
        [userProfile logProperties];
    }
    [self getUpdateUserProfileHelper:userProfile error:error];
}



- (void)handleProfileUpdateContact:(CTSRestCoreResponse*)response {
  [self updateContactInfoHelper:response.error];
}

- (void)handleProfileGetPayment:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSProfilePaymentRes* paymentDetails = nil;

  if (error == nil) {
    paymentDetails =
        [[CTSProfilePaymentRes alloc] initWithString:response.responseString
                                               error:&jsonError];
    LogDebug(@"jsonError %@", jsonError);
  }
  [self getPaymentInfoHelper:paymentDetails error:error];
}

- (void)handleProfileUpdatePayment:(CTSRestCoreResponse*)response {
  [self updatePaymentInfoHelper:response.error];
}

- (void)handleProfileMobileUpdate:(CTSRestCoreResponse*)response {
    [self updateMobileHelper:response.error];
}


-(void)handleGetNewProfileContact:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSProfileContactNewRes* contactInfo = nil;
    
    if (error == nil) {
        contactInfo =
        [[CTSProfileContactNewRes alloc] initWithString:response.responseString
                                               error:&jsonError];
        contactInfo.emailDate = [NSDate dateWithTimeIntervalSince1970:[contactInfo.emailVerifiedDate longValue]];
        contactInfo.mobileDate = [NSDate dateWithTimeIntervalSince1970:[contactInfo.mobileVerifiedDate longValue]];

        LogDebug(@"jsonError %@", jsonError);
    }
    
    if(jsonError){
            error = [CTSError getErrorForCode:unknownError];
    }
    [self getNewProfileHelper:contactInfo error:error];

}


//suggested by Mukesh via mail
-(void)handleProfileGetBanlance:(CTSRestCoreResponse*)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSAmount* amount = nil;
    
    if(error == nil){
        // Activate Prepaid Account if balance is -1
        CTSAmount *am = [[CTSAmount alloc] initWithString:response.responseString error:&jsonError];
        if([am.value isEqualToString:@"-1"]){
            [self requestActivatePrepaidAccount:^(BOOL isActivated, NSError *error) {
                CTSAmount *amount = [[CTSAmount alloc] init];
                amount.value = @"0";
                amount.currency = @"INR";
                [self getBalanceHelper:amount error:error];
            }];
        }else{
            amount = [[CTSAmount alloc] initWithString:response.responseString error:&jsonError];
            [self getBalanceHelper:amount error:error];
        }
    }
}

-(void)handleActivatePrepaidAccountWithGetBalance:(CTSRestCoreResponse*)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSAmount* amount = nil;
    
    if(error == nil){
        amount = [[CTSAmount alloc] initWithString:response.responseString error:&jsonError];
    }
    [self activatePrepaidGetBalanceHelper:amount error:error];
}


-(void)handleActivatePrepaidAccount:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSAmount* amount = nil;
    BOOL isActivated = NO;
    
    if(error == nil){
        amount = [[CTSAmount alloc] initWithString:response.responseString error:&jsonError];
        
    }
    if(amount != nil){
        
        isActivated = YES;
    }
    [self activatePrepaidHelper:isActivated error:error];
}


-(void)handleGetNewContactProfile:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSNewContactProfile *profile = nil;
    
    if(error == nil){
        profile = [[CTSNewContactProfile alloc] initWithString:response.responseString error:&jsonError];
    }
    if(jsonError){
        error = jsonError;
    }
    [self getNewContactProfileHelper:profile error:error];
}

#pragma mark - helper methods

- (void)updateContactInfoHelper:(NSError*)error {
  ASUpdateContactInfoCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:ProfileUpdateContactReqId];

  if (callback != nil) {
    callback(error);
  }
}

- (void)getContactInfoHelper:(CTSProfileContactRes*)contact error:(NSError*)error {
    ASGetContactInfoCallBack callback = [self retrieveAndRemoveCallbackForReqId:ProfileGetContactReqId];
    if (callback != nil) {
        callback(contact, error);
    }
}

- (void)getUserProfileHelper:(CTSUserProfileRes*)userProfile error:(NSError*)error {
    ASGetUserProfileDetailsCallBack callback = [self retrieveAndRemoveCallbackForReqId:ProfileGetUserReqId];
    if (callback != nil) {
        callback(userProfile, error);
    }
}

- (void)getUpdateUserProfileHelper:(CTSUpdateUserProfileRes*)updateUserProfile error:(NSError*)error {
    ASUpdateUserProfileDetailsCallBack callback = [self retrieveAndRemoveCallbackForReqId:ProfileUserUpdateReqId];
    if (callback != nil) {
        callback(updateUserProfile, error);
    }
}


- (void)updatePaymentInfoHelper:(NSError*)error {
  ASUpdatePaymentInfoCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:ProfileUpdatePaymentReqId];

  if (callback != nil) {
    callback(error);

  }
}

- (void)getPaymentInfoHelper:(CTSProfilePaymentRes*)payment
                       error:(NSError*)error {
    ASGetPaymentInfoCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:ProfileGetPaymentReqId];
    if (callback != nil) {
        callback(payment, error);
    }
}


-(void)updateMobileHelper:(NSError *)error{
    ASUpdateContactInfoCallBack callback = [self retrieveAndRemoveCallbackForReqId:ProfileUpdateMobileRequestId];
    if (callback != nil) {
        callback(error);
    }
}

-(void)getNewProfileHelper:(CTSProfileContactNewRes *)userProfile error:(NSError *)error{
    ASGetContactInfoNewCallback callback = [self retrieveAndRemoveCallbackForReqId:ProfileGetNewContactReqId];
    
    if(callback != nil){
        callback(userProfile,error);
    }
}


-(void)getBalanceHelper:(CTSAmount *)amount error:(NSError *)error{
    ASGetBalanceCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:ProfileGetBalanceReqId];
    if (callback != nil) {
        callback(amount, error);
    }
}

-(void)activatePrepaidGetBalanceHelper:(CTSAmount *)amount error:(NSError *)error{
    
    if(error == nil){
        [CTSUtility saveToDisk:@"YES" as:IS_CALLED_ACTIVATION];
    }
    
    ASGetBalanceCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:ProfileActivatePrepaidAccountReqIdGetBalance];
    if (callback != nil) {
        callback(amount, error);
    }
}


-(void)activatePrepaidHelper:(BOOL )isActivated error:(NSError *)error{
    if(error == nil){
        [CTSUtility saveToDisk:@"YES" as:IS_CALLED_ACTIVATION];
    }
    
    ASActivatePrepaidCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:ProfileActivatePrepaidAccountReqId];
    if (callback != nil) {
        callback(isActivated, error);
    }
}

-(void)getNewContactProfileHelper:(CTSNewContactProfile *)profile error:(NSError *)error{
    ASNewContactProfileCallback callback = [self retrieveAndRemoveCallbackForReqId:ProfileGetNewProfileReqId];
    if (callback != nil) {
        callback(profile, error);
    }
}

@end
