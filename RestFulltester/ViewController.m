//
//  ViewController.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "ViewController.h"
#import <RestKit/RestKit.h>
#import "CTSOauthTokenRes.h"
#import "CTSAuthLayer.h"
#import "CTSAuthLayerConstants.h"
#import "Logging.h"
#import "CTSProfileLayer.h"
#import "NSObject+logProperties.h"

@interface ViewController ()
@property(strong) CTSContactUpdate* contactInfo;
@property(strong) CTSElectronicCardUpdate* guestflowdebitcard;
@property(strong) CTSPaymentDetailUpdate* guestFlowDebitCardInfo;
@end

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@implementation ViewController
@synthesize contactInfo, guestflowdebitcard, guestFlowDebitCardInfo;
- (void)viewDidLoad {
  [super viewDidLoad];
  [self initialize];

  //[self signIn];
  [self signUp];

  //[self doGuestPayment];
}

- (void)initialize {
  // required initialization
  authLayer = [[CTSAuthLayer alloc] init];
  authLayer.delegate = self;
  profileService = [[CTSProfileLayer alloc] init];
  profileService.delegate = self;
  paymentlayerinfo = [[CTSPaymentLayer alloc] init];
  paymentlayerinfo.delegate = self;

  contactInfo = [[CTSContactUpdate alloc] init];
  contactInfo.firstName = @"dongGing";
  contactInfo.lastName = @"wankhede";
  contactInfo.email = TEST_EMAIL;
  contactInfo.mobile = TETS_MOBILE;

  // guest flow
  guestFlowDebitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
  guestflowdebitcard = [[CTSElectronicCardUpdate alloc] initDebitCard];
  guestflowdebitcard.number = @"4028530052708001";
  guestflowdebitcard.expiryDate = @"03/2015";
  guestflowdebitcard.scheme = @"visa";
  guestflowdebitcard.cvv = @"018";
  guestflowdebitcard.ownerName = @"Jitendra Gupta";

  [guestFlowDebitCardInfo addCard:guestflowdebitcard];
}

- (void)signIn {
  [authLayer requestSigninWithUsername:TEST_EMAIL password:TEST_PASSWORD];
}

- (void)signUp {
  [authLayer requestSignUpWithEmail:TEST_EMAIL
                             mobile:TETS_MOBILE
                           password:TEST_PASSWORD];
}

- (void)getMerchantSetting:(NSString*)merchantVanity {
  [paymentlayerinfo requestMerchantPgSettings:merchantVanity];
}

- (void)contactInformation:(CTSProfileContactRes*)contactInfo
                     error:(NSError*)error {
  //[contactInfo printNextResponder];
  DDLogInfo(@"contactInfo %@ %@",
            contactInfo.type,
            [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey]);
}
- (void)paymentInformation:(CTSProfilePaymentRes*)paymentInfo
                     error:(NSError*)error {
  [paymentInfo logProperties];
  for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
    [option logProperties];
  }
}

- (void)paymentInfoUpdatedError:(NSError*)error {
  DDLogInfo(@"paymentInfoUpdatedError");
  [profileService requestPaymentInformation];
}

- (void)contactInfoUpdatedError:(NSError*)error {
  DDLogInfo(@"contactInfoUpdatedError %@ %@",
            error,
            [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey]);
  [profileService requestContactInformation];
}
- (void)transactionInfo:(CTSPaymentTransactionRes*)paymentinfo {
  NSLog(@"redirectUrl:%@", paymentinfo.redirectUrl);
}

- (void)transactionInformation:(CTSPaymentRes*)transactionInfo
                         error:(NSError*)error {
  DDLogInfo(@"TransactionError %@ %@",
            error,
            [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey]);
}
- (void)signin:(BOOL)isSuccessful
    forUserName:(NSString*)userName
    accessToken:(NSString*)token
          error:(NSError*)error {
  ENTRY_LOG
  DDLogInfo(@"isSuccessful %d", isSuccessful);
  DDLogInfo(@"userName %@", userName);
  DDLogInfo(@"error %@", error);
  DDLogInfo(@"access token %@", token);

  CTSProfileLayer* profileinfo = [[CTSProfileLayer alloc] init];

  CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* debitCard =
      [[CTSElectronicCardUpdate alloc] initDebitCard];
  debitCard.number = @"4028530052708001";
  debitCard.expiryDate = @"12/15";
  debitCard.scheme = @"visa";
  debitCard.ownerName = @"Yaddy";
  debitCard.name = @"KOTAK";
  debitCard.token = @"";
  debitCard.cvv = @"018";
  [paymentInfo addCard:debitCard];
  [profileinfo requestContactInformation];
  //[profileService updatePaymentInformation:paymentInfo];
  /*[paymentlayerinfo makePaymentByCard:paymentInfo
   withContact:contactInfo
   amount:@"1"];*/

  CTSPaymentDetailUpdate* creditCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* creditCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  creditCard.number = @"4028530052708001";
  creditCard.expiryDate = @"12/15";
  creditCard.scheme = @"visa";
  creditCard.ownerName = @"Nair";
  creditCard.name = @"ICICI";
  creditCard.cvv = @"018";
  [creditCardInfo addCard:creditCard];
  /*[paymentlayerinfo makePaymentByCard:creditCardInfo
   withContact:contactInfo
   amount:@"1"];*/

  CTSPaymentDetailUpdate* netBankingPaymentInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
  netbank.code = @"CID001";
  [netBankingPaymentInfo addNetBanking:netbank];
  /*[paymentlayerinfo makePaymentByNetBanking:netBankingPaymentInfo
   withContact:contactInfo
   amount:@"1"];*/

  // Guest Flow
  // For card

  // For netbanking
  CTSPaymentDetailUpdate* guestFlowNetBankingUpdate =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* guestflownetbank = [[CTSNetBankingUpdate alloc] init];
  guestflownetbank.code = @"CID001";
  [guestFlowNetBankingUpdate addNetBanking:guestflownetbank];
  /* [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowNetBankingUpdate
   withContact:contactInfo
   amount:@"1"];*/

  // Tokenized Payments
  CTSPaymentDetailUpdate* tokenizedNetbankingInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* tokenizednetbank = [[CTSNetBankingUpdate alloc] init];
  tokenizednetbank.token = @"f4fd6afdabc6c85ff05ec737ad6188b3";
  [tokenizedNetbankingInfo addNetBanking:tokenizednetbank];
  /* [paymentlayerinfo makeTokenizedCardPayment:tokenizedNetbankingInfo
   withContact:contactInfo
   amount:@"1"];*/

  CTSPaymentDetailUpdate* tokenizedCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* tokenizedCard =
      [[CTSElectronicCardUpdate alloc] initDebitCard];
  tokenizedCard.token = @"7f51054446e0d9d7b34d7a79684313c6";
  tokenizedCard.cvv = @"018";
  [tokenizedCardInfo addCard:tokenizedCard];
  /*[paymentlayerinfo makeTokenizedCardPayment:tokenizedCardInfo
     withContact:contactInfo
     amount:@"1"];*/
  EXIT_LOG
}

- (void)signUp:(BOOL)isSuccessful
    accessToken:(NSString*)token
          error:(NSError*)error {
  ENTRY_LOG

  DDLogInfo(@"isSuccessful %d", isSuccessful);
  DDLogInfo(@"error %@", error);
  DDLogInfo(@"access token %@", token);

  EXIT_LOG
}

- (void)pgSetting:(CTSPgSettings*)pgSetting error:(NSError*)error {
  [pgSetting logProperties];
  [pgSetting.netBanking logProperties];
  NSLog(@"error %@", error);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)doGuestPayment {
  [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowDebitCardInfo
                                  withContact:contactInfo
                                       amount:@"1"
                                   isDoSignup:YES];
}

@end
