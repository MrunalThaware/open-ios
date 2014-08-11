//
//  CTSPaymentLayer.m
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//
#import "CTSPaymentDetailUpdate.h"
#import "CTSContactUpdate.h"
#import "CTSPaymentLayer.h"
#import "CTSPaymentMode.h"
#import "CTSPaymentRequest.h"
#import "CTSAmount.h"
#import "CTSPaymentToken.h"
#import "CTSPaymentMode.h"
#import "CTSUserDetails.h"
#import "CTSUserAddress.h"
#import "CTSPaymentTransactionRes.h"
#import "CTSGuestCheckout.h"
#import "CTSPaymentNetbankingRequest.h"
#import "CTSTokenizedCardPayment.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSProfileLayer.h"
#import "CTSAuthLayer.h"
#import "CTSRestCoreRequest.h"
#import "CTSUtility.h"
#import "CTSOauthManager.h"
#import "CTSTokenizedPaymentToken.h"
@interface CTSPaymentLayer ()
@property(strong) CTSPaymentDetailUpdate* paymentDetailInfo;
@property(strong) CTSContactUpdate* contactDetailInfo;
@property(strong) NSString* amount;
@property(strong) NSString* paymentTokenType;
@property(assign) BOOL isGuestCheout;
@property(strong) NSString* transactionId;
@property(strong) CTSPaymentDetailUpdate* paymentDetailUpdate;
@end

@implementation CTSPaymentLayer
static BOOL isSignatureSuccess;
@synthesize merchantTxnId;
@synthesize signature;
@synthesize objectManager;
@synthesize delegate;

- (NSArray*)formRegistrationArray {
  NSMutableArray* registrationArray = [[NSMutableArray alloc] init];
  [registrationArray
      addObject:
          [[CTSRestRegister alloc]
                 initWithPath:MLC_PAYMENT_GETSIGNATURE_PATH
                   httpMethod:MLC_OAUTH_TOKEN_SIGNUP_REQ_TYPE
               requestMapping:nil
              responseMapping:
                  [[CTSTypeToParameterMapping alloc]
                      initWithType:MLC_PAYMENT_RESPONSE_TYPE
                        parameters:MLC_PAYMENT_GET_SIGNATURE_RES_MAPPING]]];

  return registrationArray;
}
- (void)getsignature:(NSString*)amount {
  if ([CTSUtility readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN] == nil) {
    [delegate
        transactionInformation:nil
                         error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }
  NSDictionary* header = @{
    @"Authorization" : [NSString
        stringWithFormat:@"Bearer %@", [CTSOauthManager readOauthToken]]
  };
  NSString* oauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PAYMENT_GETSIGNATURE_PATH
         requestId:PaymentGetSignatureReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{
          MLC_PAYMENT_QUERY_AMOUNT : amount,
          MLC_PAYMENT_QUERY_CURRENCY : @"INR",
          MLC_PAYMENT_QUERY_REDIRECT : MLC_PAYMENT_REDIRECT_URL
        } json:nil
        httpMethod:POST];
  [restCore requestServer:request];
}

- (void)insertGuestValues:(CTSPaymentDetailUpdate*)paymentDetailInfo
              withContact:(CTSContactUpdate*)contactDetailInfo
                withTxnId:(NSString*)merchanttxnId
            withSignature:(NSString*)reqsignature
               withAmount:(NSString*)amt {
  CTSGuestCheckout* guestpayment = [[CTSGuestCheckout alloc] init];
  guestpayment.returnUrl = MLC_GUESTCHECKOUT_REDIRECTURL;
  guestpayment.amount = amt;

  // Address can't be blank
  guestpayment.addressState = @"Maharashtra";
  guestpayment.addressCity = @"Mumbai";
  guestpayment.address = @"North Avenue";
  guestpayment.email = contactDetailInfo.email;
  guestpayment.firstName = contactDetailInfo.firstName;
  guestpayment.lastName = contactDetailInfo.lastName;
  guestpayment.mobile = contactDetailInfo.mobile;
  guestpayment.merchantTxnId = merchanttxnId;
  for (CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
    if ([paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]) {
      guestpayment.paymentMode = @"CREDIT_CARD";
    } else if ([paymentOption.type
                   isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE]) {
      guestpayment.paymentMode = @"DEBIT_CARD";
    } else if ([paymentOption.type
                   isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]) {
      guestpayment.paymentMode = @"NET_BANKING";
    }
    if (paymentOption.expiryDate != nil) {
      NSArray* expiryDate =
          [paymentOption.expiryDate componentsSeparatedByString:@"/"];
      guestpayment.expiryMonth = [expiryDate objectAtIndex:0];
      guestpayment.expiryYear = [expiryDate objectAtIndex:1];
    }
    if (paymentOption.owner != nil) {
      guestpayment.cardHolderName = paymentOption.owner;
    }
    if (paymentOption.cvv != nil) {
      guestpayment.cvvNumber = paymentOption.cvv;
    }
    if (paymentOption.scheme != nil) {
      guestpayment.cardType = paymentOption.scheme;
    }
    if (paymentOption.number != nil) {
      guestpayment.cardNumber = paymentOption.number;
    }
    if (paymentOption.code != nil) {
      guestpayment.issuerCode = paymentOption.code;
    }
  }
  CTSErrorCode error = [paymentDetailInfo validate];
  if (error != NoError) {
    [delegate transactionInformation:nil
                               error:[CTSError getErrorForCode:error]];
    return;
  }
  NSDictionary* header = @{
    @"access_key" : MLC_GUESTCHECKOUT_ACCESSKEY,
    @"Accept-Language" : @"en-US",
    @"Accept" : @"application/json",
    @"Content-Type" : @"application/json",
    @"Content-Type" : @"application/xml",
    @"signature" : reqsignature
  };
  NSLog(@"guest request:%@", guestpayment);
  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_GUESTCHECKOUT_URL
                                     requestId:PaymentAsGuestReqId
                                       headers:header
                                    parameters:nil
                                          json:[guestpayment toJSONString]
                                    httpMethod:POST];
  [restCore requestServer:request];
}
- (void)insertMemberValues:(CTSPaymentDetailUpdate*)paymentDetailInfo
               withContact:(CTSContactUpdate*)contactDetailInfo
                 withTxnId:(NSString*)merchanttxnId
             withSignature:(NSString*)signature
                withAmount:(NSString*)amt {
  for (CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
    if ([self.paymentTokenType isEqualToString:@"paymentOptionIdToken"]) {
      CTSTokenizedCardPayment* tokenizedCardPaymentRequest =
          [[CTSTokenizedCardPayment alloc] init];
      tokenizedCardPaymentRequest.merchantAccessKey = MLC_PAYMENT_ACCESSKEY;
      tokenizedCardPaymentRequest.merchantTxnId = merchanttxnId;
      tokenizedCardPaymentRequest.notifyUrl = @"";
      tokenizedCardPaymentRequest.requestSignature = signature;
      tokenizedCardPaymentRequest.returnUrl = MLC_PAYMENT_REDIRECT_URLCOMPLETE;
      CTSAmount* amount = [[CTSAmount alloc] init];
      amount.value = amt;
      amount.currency = @"INR";
      CTSTokenizedPaymentToken* paymentToken =
          [[CTSTokenizedPaymentToken alloc] init];
      paymentToken.type = self.paymentTokenType;
      paymentToken.id = paymentOption.token;
      if (paymentOption.cvv != nil) {
        paymentToken.cvv = paymentOption.cvv;
      }
      CTSUserDetails* userDetails = [[CTSUserDetails alloc] init];
      userDetails.email = contactDetailInfo.email;
      userDetails.firstName = contactDetailInfo.firstName;
      userDetails.lastName = contactDetailInfo.lastName;
      userDetails.mobileNo = contactDetailInfo.mobile;
      CTSUserAddress* userAddress = [[CTSUserAddress alloc] init];
      userAddress.city = @"mumbai";
      userAddress.country = @"wdw";
      userAddress.state = @"wefqwrf";
      userAddress.street1 = @"wfwrf";
      userAddress.street2 = @"drfrf";
      userAddress.zip = @"wrwrf";
      userDetails.address = userAddress;
      tokenizedCardPaymentRequest.amount = amount;
      tokenizedCardPaymentRequest.paymentToken = paymentToken;
      tokenizedCardPaymentRequest.userDetails = userDetails;
      tokenizedCardPaymentRequest.userDetails = userDetails;
      if ([CTSOauthManager readOauthToken] == nil) {
        [delegate
            transactionInformation:nil
                             error:[CTSError getErrorForCode:UserNotSignedIn]];
        return;
      }
      NSDictionary* header = @{ @"Content-Type" : @"application/json" };
      NSLog(@"json request:%@", tokenizedCardPaymentRequest);
      CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
          initWithPath:MLC_CITRUS_SERVER_URL
             requestId:PaymentUsingtokenizedCardBankReqId
               headers:header
            parameters:nil
                  json:[tokenizedCardPaymentRequest toJSONString]
            httpMethod:POST];
      [restCore requestServer:request];
    } else {
      CTSPaymentRequest* paymentrequest = [[CTSPaymentRequest alloc] init];
      paymentrequest.merchantAccessKey = MLC_PAYMENT_ACCESSKEY;
      paymentrequest.merchantTxnId = merchanttxnId;
      paymentrequest.requestSignature = signature;
      paymentrequest.notifyUrl = @"";
      paymentrequest.returnUrl = MLC_PAYMENT_REDIRECT_URL;
      CTSAmount* amount = [[CTSAmount alloc] init];
      amount.value = amt;
      amount.currency = @"INR";
      CTSPaymentToken* paymentToken = [[CTSPaymentToken alloc] init];
      paymentToken.type = self.paymentTokenType;
      CTSPaymentMode* paymentMode = [[CTSPaymentMode alloc] init];
      for (
          CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
        paymentMode.type = paymentOption.type;
        if (paymentOption.code != nil) {
          paymentMode.code = paymentOption.code;
        }
        if (paymentOption.name != nil) {
          paymentMode.holder = paymentOption.name;
        }
        if (paymentOption.expiryDate != nil) {
          paymentMode.expiry = paymentOption.expiryDate;
        }
        if (paymentOption.cvv != nil) {
          paymentMode.cvv = paymentOption.cvv;
        }
        if (paymentOption.number != nil) {
          paymentMode.number = paymentOption.number;
        }
        if (paymentOption.scheme != nil) {
          paymentMode.scheme = paymentOption.scheme;
        }
      }
      paymentToken.paymentMode = paymentMode;
      CTSUserDetails* userDetails = [[CTSUserDetails alloc] init];
      userDetails.email = contactDetailInfo.email;
      userDetails.firstName = contactDetailInfo.firstName;
      userDetails.lastName = contactDetailInfo.lastName;
      userDetails.mobileNo = contactDetailInfo.mobile;
      CTSUserAddress* userAddress = [[CTSUserAddress alloc] init];
      userAddress.city = @"mumbai";
      userAddress.country = @"wdw";
      userAddress.state = @"wefqwrf";
      userAddress.street1 = @"wfwrf";
      userAddress.street2 = @"drfrf";
      userAddress.zip = @"wrwrf";
      userDetails.address = userAddress;
      paymentrequest.amount = amount;
      paymentrequest.paymentToken = paymentToken;
      paymentrequest.userDetails = userDetails;
      if ([CTSUtility readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN] == nil) {
        [delegate
            transactionInformation:nil
                             error:[CTSError getErrorForCode:UserNotSignedIn]];
        return;
      } else {
        CTSErrorCode error = [paymentDetailInfo validate];
        if (error != NoError) {
          [delegate transactionInformation:nil
                                     error:[CTSError getErrorForCode:error]];
          return;
        }
      }
      NSDictionary* header = @{ @"Content-Type" : @"application/json" };
      NSLog(@"json request:%@", paymentrequest);
      NSLog(@"JSON STRING:%@", [paymentrequest toJSONString]);
      CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
          initWithPath:MLC_CITRUS_SERVER_URL
             requestId:PaymentUsingSignedInCardBankReqId
               headers:header
            parameters:nil
                  json:[paymentrequest toJSONString]
            httpMethod:POST];
      [restCore requestServer:request];
    }
  }
}
- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
            withContact:(CTSContactUpdate*)contactInfo
                 amount:(NSString*)amount
          withSignature:(NSString*)signature
              withTxnId:(NSString*)merchantTxnId {
  self.paymentTokenType = @"paymentOptionToken";
  [self insertMemberValues:paymentInfo
               withContact:contactInfo
                 withTxnId:merchantTxnId
             withSignature:signature
                withAmount:amount];
}

- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                      amount:(NSString*)amount
               withSignature:(NSString*)signature
                   withTxnId:(NSString*)merchantTxnId {
  self.paymentTokenType = @"paymentOptionIdToken";
  [self insertMemberValues:paymentInfo
               withContact:contactInfo
                 withTxnId:merchantTxnId
             withSignature:signature
                withAmount:amount];
}
- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount
                    withSignature:(NSString*)signature
                        withTxnId:(NSString*)merchantTxnId
                       isDoSignup:(BOOL)isDoSignup {
  if (isDoSignup == YES) {
    CTSAuthLayer* authLayer = [[CTSAuthLayer alloc] init];
    authLayer.delegate = self;
    _paymentDetailUpdate = paymentInfo;
    __block NSString* email = contactInfo.email;
    __block NSString* mobile = contactInfo.mobile;
    __block NSString* password = contactInfo.password;

    dispatch_async(backgroundQueue, ^(void) {
        [authLayer requestSignUpWithEmail:email
                                   mobile:mobile
                                 password:password];
    });
  }

  [self insertGuestValues:paymentInfo
              withContact:contactInfo
                withTxnId:merchantTxnId
            withSignature:signature
               withAmount:amount];
}

- (void)requestMerchantPgSettings:(NSString*)vanityUrl {
  if (vanityUrl == nil) {
    [delegate payment:self
        didRequestMerchantPgSettings:nil
                               error:[CTSError
                                         getErrorForCode:InvalidParameter]];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PAYMENT_GET_PGSETTINGS_PATH
         requestId:PaymentPgSettingsReqId
           headers:nil
        parameters:@{
          MLC_PAYMENT_GET_PGSETTINGS_QUERY_VANITY : vanityUrl
        } json:nil
        httpMethod:POST];
  [restCore requestServer:request];
}

#pragma mark - authentication protocol mehods
- (void)signUp:(BOOL)isSuccessful
    accessToken:(NSString*)token
          error:(NSError*)error {
  if (isSuccessful) {
    dispatch_async(backgroundQueue, ^(void) {
        CTSProfileLayer* profileLayer = [[CTSProfileLayer alloc] init];
        [profileLayer updatePaymentInformation:_paymentDetailUpdate];
        _paymentDetailUpdate = nil;
    });
  }
}

enum {
  PaymentGetSignatureReqId,
  PaymentAsGuestReqId,
  PaymentUsingtokenizedCardBankReqId,
  PaymentUsingSignedInCardBankReqId,
  PaymentPgSettingsReqId
};
- (instancetype)init {
  NSDictionary* dict = @{
    toNSString(PaymentGetSignatureReqId) :
        toSelector(handleReqPaymentGetSignature
                   :),
    toNSString(PaymentAsGuestReqId) : toSelector(handleReqPaymentAsGuest
                                                 :),
    toNSString(PaymentUsingtokenizedCardBankReqId) :
        toSelector(handleReqPaymentUsingtokenizedCardBank
                   :),
    toNSString(PaymentUsingSignedInCardBankReqId) :
        toSelector(handlePaymentUsingSignedInCardBank
                   :),
    toNSString(PaymentPgSettingsReqId) : toSelector(handleReqPaymentPgSettings
                                                    :)
  };
  self = [super initWithRequestSelectorMapping:dict
                                       baseUrl:CITRUS_PAYMENT_BASE_URL];
  return self;
}

- (void)handleReqPaymentAsGuest:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  if (error == nil) {
    CTSPaymentTransactionRes* resultObject =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [delegate payment:self
        didMakePaymentUsingGuestFlow:resultObject
                               error:error];
  }
}

- (void)handleReqPaymentUsingtokenizedCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  if (error == nil) {
    NSLog(@"error:%@", jsonError);
    CTSPaymentTransactionRes* resultObject =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [delegate payment:self didMakeTokenizedPayment:resultObject error:error];
  }
}

- (void)handlePaymentUsingSignedInCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  if (error == nil) {
    CTSPaymentTransactionRes* resultObject =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [delegate payment:self didMakeUserPayment:resultObject error:error];
  }
}

- (void)handleReqPaymentPgSettings:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  if (error == nil) {
    CTSPgSettings* resultObject =
        [[CTSPgSettings alloc] initWithString:response.responseString
                                        error:&jsonError];
    [delegate payment:self
        didRequestMerchantPgSettings:resultObject
                               error:error];
  }
}
@end
