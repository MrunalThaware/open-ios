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
#import "HMACSignature.h"
#import "CTSPaymentNetbankingRequest.h"
#import "CTSTokenizedCardPayment.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSProfileLayer.h"
#import "CTSAuthLayer.h"

#import <RestKit/RestKit.h>
@interface CTSPaymentLayer ()
@property(strong) CTSPaymentDetailUpdate* paymentdetailinfo;
@property(strong) CTSContactUpdate* contactdetailinfo;
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
- (instancetype)init {
  if (self = [super init]) {
    backgroundQueue = dispatch_queue_create("com.citruspay.authQueue", NULL);
    restService =
        [[CTSRestLayer alloc] initWithBaseURL:CITRUS_PAYMENT_BASE_URL];
    [restService register:[self formRegistrationArray]];
    [restService paymentCardRequestMapping];
    [restService paymentNetbankingRequestMapping];
    [restService tokenizedCardRequestMapping];
    [restService guestCheckoutPaymentMapping];
    [restService registerPgSettingResponse];
    [restService setDelegate:self];
  }
  return self;
}

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
        stringWithFormat:@"Bearer %@",
                         [CTSUtility
                             readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN]]
  };

  [restService postObject:nil
                   atPath:MLC_PAYMENT_GETSIGNATURE_PATH
               withHeader:header
           withParameters:@{
             MLC_PAYMENT_QUERY_AMOUNT : amount,
             MLC_PAYMENT_QUERY_CURRENCY : @"INR",
             MLC_PAYMENT_QUERY_REDIRECT : MLC_PAYMENT_REDIRECT_URL
           } withInfo:MLC_PAYMENT_GET_SIGNATURE_INFO];
}

- (void)getGuestPaymentSignature:(NSString*)amount {
  NSString* data = [NSString
      stringWithFormat:@"merchantAccessKey=%@&transactionId=%@&amount=%@",
                       MLC_GUESTCHECKOUT_ACCESSKEY,
                       self.transactionId,
                       amount];
  HMACSignature* hmacSignature = [[HMACSignature alloc] init];
  self.signature =
      [hmacSignature generateHMAC:MLC_GUESTCHECKOUT_SECRETKEY withData:data];
  [self insertGuestValues:self.paymentdetailinfo
              withContact:self.contactdetailinfo
                withTxnId:self.transactionId
            withSignature:self.signature
               withAmount:amount];
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
  [restService changeBaseUrl:MLC_GUEST_PAYMENT_BASE_URL];
  [restService guestCheckoutPaymentResponseMapping];
  CTSErrorCode error = [paymentDetailInfo validate];
  if (error != NoError) {
    [delegate transactionInformation:nil
                               error:[CTSError getErrorForCode:error]];
    return;
  }
  NSDictionary* header = @{
    @"access_key" : MLC_GUESTCHECKOUT_ACCESSKEY,
    @"Accept-Language" : @"en-US",
    @"Accept-Encoding" : @"application/json",
    @"Content-Type" : @"application/json",
    @"Content-Type" : @"application/xml",
    @"signature" : reqsignature
  };
  [restService postObject:guestpayment
                   atPath:MLC_CITRUS_GUESTCHECKOUT_URL
               withHeader:header
           withParameters:nil
                 withInfo:MLC_PAYMENT_TRANSACTION];
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
      tokenizedCardPaymentRequest.merchantKey = MLC_PAYMENT_ACCESSKEY;
      tokenizedCardPaymentRequest.merchantTxnId = self.merchantTxnId;
      tokenizedCardPaymentRequest.notifyUrl = @"";
      tokenizedCardPaymentRequest.requestSignature = self.signature;
      tokenizedCardPaymentRequest.returnUrl = MLC_PAYMENT_REDIRECT_URL;
      CTSAmount* amount = [[CTSAmount alloc] init];
      amount.value = @"1";
      amount.currency = @"INR";
      CTSPaymentToken* paymentToken = [[CTSPaymentToken alloc] init];
      paymentToken.type = self.paymentTokenType;
      paymentToken.tokenid = paymentOption.token;
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
      [restService changeBaseUrl:MLC_PAYMENT_BASE_URL];
      [restService paymentResponseMapping];
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
      NSDictionary* header = @{
        @"Authorization" : [NSString
            stringWithFormat:@"Bearer %@",
                             [CTSUtility
                                 readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN]],
        @"access_key" : MLC_PAYMENT_ACCESSKEY,
        @"Accept-Language" : @"en-US",
        @"Accept-Encoding" : @"application/json",
        @"Content-Type" : @"application/json"
      };
      [restService postObject:tokenizedCardPaymentRequest
                       atPath:MLC_CITRUS_SERVER_URL
                   withHeader:header
               withParameters:nil
                     withInfo:MLC_PAYMENT_TRANSACTION];
    } else {
      CTSPaymentRequest* paymentrequest = [[CTSPaymentRequest alloc] init];
      paymentrequest.merchantKey = MLC_PAYMENT_ACCESSKEY;
      paymentrequest.merchantTxnId = self.merchantTxnId;
      paymentrequest.notifyUrl = @"";
      paymentrequest.requestSignature = self.signature;
      paymentrequest.returnUrl = MLC_PAYMENT_REDIRECT_URL;
      CTSAmount* amount = [[CTSAmount alloc] init];
      amount.value = @"1";
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
      paymentrequest.userDetails = userDetails;
      [restService changeBaseUrl:MLC_PAYMENT_BASE_URL];
      [restService paymentResponseMapping];
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
      NSDictionary* header = @{
        @"Authorization" : [NSString
            stringWithFormat:@"Bearer %@",
                             [CTSUtility
                                 readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN]],
        @"access_key" : MLC_PAYMENT_ACCESSKEY,
        @"Accept-Language" : @"en-US",
        @"Accept-Encoding" : @"application/json",
        @"Content-Type" : @"application/json"
      };
      [restService postObject:paymentrequest
                       atPath:MLC_CITRUS_SERVER_URL
                   withHeader:header
               withParameters:nil
                     withInfo:MLC_PAYMENT_TRANSACTION];
    }
  }
}
- (void)receivedObjectArray:(NSArray*)response
                    forPath:(NSString*)path
                  withError:(NSError*)error
                   withInfo:(NSString*)info {
  NSLog(@"%@", response);
  BOOL isSuccess = NO;
  if (error == nil) {
    isSuccess = YES;
    if ([info isEqualToString:MLC_PAYMENT_TRANSACTION]) {
      for (CTSPaymentTransactionRes* transactionres in response) {
        [delegate transactionInfo:transactionres];
      }

    } else if ([info isEqualToString:MLC_PAYMENT_GET_SIGNATURE_INFO]) {
      for (CTSPaymentRes* result in response) {
        self.signature = result.signature;
        self.merchantTxnId = result.merchantTransactionId;
        [self insertMemberValues:self.paymentdetailinfo
                     withContact:self.contactdetailinfo
                       withTxnId:result.merchantTransactionId
                   withSignature:self.signature
                      withAmount:self.amount];
        isSignatureSuccess = YES;
      }
    } else if ([path isEqualToString:MLC_PAYMENT_GET_PGSETTINGS_PATH]) {
      for (CTSPgSettings* transactionres in response) {
        [delegate pgSetting:transactionres error:error];
      }
    }
  }
}

- (void)makePaymentByCard:(CTSPaymentDetailUpdate*)paymentInfo
              withContact:(CTSContactUpdate*)contactInfo
                   amount:(NSString*)amount {
  isSignatureSuccess = NO;
  self.paymentTokenType = @"paymentOptionToken";
  if (!isSignatureSuccess) {
    [self getsignature:amount];
  }
  self.paymentdetailinfo = paymentInfo;
  self.contactdetailinfo = contactInfo;
  self.amount = amount;
}

- (void)makePaymentByNetBanking:(CTSPaymentDetailUpdate*)paymentInfo
                    withContact:(CTSContactUpdate*)contactInfo
                         amount:(NSString*)amount {
  isSignatureSuccess = NO;
  self.paymentTokenType = @"paymentOptionToken";
  if (!isSignatureSuccess) {
    [self getsignature:amount];
  }
  self.paymentdetailinfo = paymentInfo;
  self.contactdetailinfo = contactInfo;
  self.amount = amount;
}

- (void)makeTokenizedCardPayment:(CTSPaymentDetailUpdate*)paymentInfo
                     withContact:(CTSContactUpdate*)contactInfo
                          amount:(NSString*)amount {
  isSignatureSuccess = NO;
  self.paymentTokenType = @"paymentOptionIdToken";
  if (!isSignatureSuccess) {
    [self getsignature:amount];
  }
  self.paymentdetailinfo = paymentInfo;
  self.contactdetailinfo = contactInfo;
  self.amount = amount;
}

- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount
                       isDoSignup:(BOOL)isDoSignup {
  /*
   get instance of the authentication layer
   set the delegate to ownself
   call for signup on new thread,

   once sign up is complete call the new delegate to inform implementer about
   this sign up/error

   clear instance

   */
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
  long long CurrentTime =
      (long long)([[NSDate date] timeIntervalSince1970] * 1000);
  self.transactionId = [NSString stringWithFormat:@"%lld", CurrentTime];
  NSLog(@"transactionId:%@", self.transactionId);
  self.paymentdetailinfo = paymentInfo;
  self.contactdetailinfo = contactInfo;
  isSignatureSuccess = NO;
  if (!isSignatureSuccess) {
    [self getGuestPaymentSignature:amount];
  }
}

- (void)requestMerchantPgSettings:(NSString*)vanityUrl {
  if (vanityUrl == nil) {
    [delegate pgSetting:nil error:[CTSError getErrorForCode:InvalidParameter]];
  }
  [restService postObject:nil
                   atPath:MLC_PAYMENT_GET_PGSETTINGS_PATH
               withHeader:nil
           withParameters:@{
             MLC_PAYMENT_GET_PGSETTINGS_QUERY_VANITY : vanityUrl
           } withInfo:nil];
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

@end
