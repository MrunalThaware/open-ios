//
//  ViewController.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+logProperties.h"
#import "CTSOauthManager.h"

@interface ViewController ()
//@property(strong) CTSContactUpdate* contactInfo;
//@property(strong) CTSElectronicCardUpdate* guestflowdebitcard;
//@property(strong) CTSPaymentDetailUpdate* guestFlowDebitCardInfo;
@end

@implementation ViewController
//@synthesize contactInfo, guestflowdebitcard, guestFlowDebitCardInfo;
- (void)viewDidLoad {
  [super viewDidLoad];
  //[self initialize];
  //
  //  CTSOauthTokenRes* oauthToekRes = [[CTSOauthTokenRes alloc] init];
  //  oauthToekRes.refreshToken = @"REFRESH_TOKEN_SAMPLE";
  //  oauthToekRes.accessToken = @"ACCESS_TOKEN_SAMPLE";
  //  oauthToekRes.tokenType = @"BEARER";
  //  oauthToekRes.tokenExpiryTime = 15552000;
  //  oauthToekRes.scope = @"SAMPLE_SCOPE";
  //
  //  [CTSOauthManager saveOauthData:oauthToekRes];
  //  [[CTSOauthManager readOauthData] logProperties];
  // [CTSOauthManager resetOauthData];
  // [[CTSOauthManager readOauthData] logProperties];

  LogTrace(@"[CTSOauthManager hasOauthExpired] %d",
           [CTSOauthManager hasOauthExpired]);

  // pragma marked user methods are sample implementations of sdk
  // TestParams.h should be populated according to your needs
  authLayer = [[CTSAuthLayer alloc] init];
  authLayer.delegate = self;
  profileLayer = [[CTSProfileLayer alloc] init];
  profileLayer.delegate = self;
  [self signIn];
  //[self signUp];
  //[self doTokenizedPaymentDebitCard];
  //[self doTokenizedPaymentNetbanking];
  //[self doGuestPaymentNetbanking];
  //[self doGuestPaymentCard];
  //[self updatePaymentInfo];
}

//- (void)networkStatusChanged:(CTSNetworkStatus)networkStatus {
//  NSLog(@"networkStatus %d", networkStatus);
//}

//- (void)initialize {
//  // required initialization
//
//  authLayer = [[CTSAuthLayer alloc] init];
//  authLayer.delegate = self;
//
//  profileService = [[CTSProfileLayer alloc] init];
//  profileService.delegate = self;
//
//  paymentlayerinfo = [[CTSPaymentLayer alloc] init];
//  paymentlayerinfo.delegate = self;
//
//  contactInfo = [[CTSContactUpdate alloc] init];
//  contactInfo.firstName = TEST_FIRST_NAME;
//  contactInfo.lastName = TEST_LAST_NAME;
//  contactInfo.email = TEST_EMAIL;
//  contactInfo.mobile = TEST_MOBILE;
//
//  // guest flow
//}

#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
    didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
                    error:(NSError*)error {
  LogTrace(@"contactInfo %@ %@",
           contactInfo.type,
           [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey]);
}
/**
 *  called when client requests for payment information
 *
 *  @param contactInfo nil in case of error
 *  @param error       nil when succesful
 */
- (void)profile:(CTSProfileLayer*)profile
    didReceivePaymentInformation:(CTSProfilePaymentRes*)paymentInfo
                           error:(NSError*)error {
  [paymentInfo logProperties];
  for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
    [option logProperties];
  }
}
/**
 *  when contact information is updated to server
 *
 *  @param error error if happned
 */
- (void)profile:(CTSProfileLayer*)profile
    didUpdateContactInfoError:(NSError*)error {
  LogTrace(@"contactInfoUpdatedError %@ %@",
           error,
           [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey]);
  [profileLayer requestContactInformation];
}

/**
 *  when payment information is updated on server
 *
 *  @param error nil when successful
 */
- (void)profile:(CTSProfileLayer*)profile
    didUpdatePaymentInfoError:(NSError*)error {
  LogTrace(@"paymentInfoUpdatedError");
  [profileLayer requestPaymentInformation];
}
//
//#pragma mark - payment layer delegates
//- (void)transactionInfo:(CTSPaymentTransactionRes*)paymentinfo {
//  NSLog(@"redirectUrl:%@", paymentinfo.redirectUrl);
//}
//
//- (void)transactionInformation:(CTSPaymentRes*)transactionInfo
//                         error:(NSError*)error {
//  LogTrace(@"TransactionError %@ %@",
//            error,
//            [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey]);
//}
//
//- (void)pgSetting:(CTSPgSettings*)pgSetting error:(NSError*)error {
//  [pgSetting logProperties];
//  [pgSetting.netBanking logProperties];
//  NSLog(@"error %@", error);
//}

#pragma mark - authentication layer delegates

//- (void)signin:(BOOL)isSuccessful
//    forUserName:(NSString*)userName
//    accessToken:(NSString*)token
//          error:(NSError*)error {
//}
//
//- (void)signUp:(BOOL)isSuccessful
//    accessToken:(NSString*)token
//          error:(NSError*)error {
//  ENTRY_LOG
//
//  LogTrace(@"isSuccessful %d", isSuccessful);
//  LogTrace(@"error %@", error);
//  LogTrace(@"access token %@", token);
//
//  EXIT_LOG
//}

- (void)auth:(CTSAuthLayer*)layer
    didSigninUsername:(NSString*)userName
           oauthToken:(NSString*)token
                error:(NSError*)error {
  ENTRY_LOG
  LogTrace(@"userName %@", userName);
  LogTrace(@"error %@", error);
  LogTrace(@"access token %@", token);

  [self updatePaymentInfo];

  // [self doUserDebitCardPayment];

  EXIT_LOG
}

- (void)auth:(CTSAuthLayer*)layer
    didSignupUsername:(NSString*)userName
           oauthToken:(NSString*)token
                error:(NSError*)error {
  ENTRY_LOG

  LogTrace(@"error %@", error);
  LogTrace(@"access token %@", token);

  EXIT_LOG
}

- (void)auth:(CTSAuthLayer*)layer
    didRefreshOauthStatus:(OauthRefresStatus)status
                    error:(NSError*)error {
  NSLog(@"OauthRefresStatus %d", status);
  LogTrace(@"error %@", error);
}

#pragma mark - user methods

- (void)signIn {
  [authLayer requestSigninWithUsername:TEST_EMAIL password:TEST_PASSWORD];
}

- (void)signUp {
  [authLayer requestSignUpWithEmail:TEST_EMAIL
                             mobile:TEST_MOBILE
                           password:TEST_PASSWORD];
}

//- (void)getMerchantSetting:(NSString*)merchantVanity {
//  [paymentlayerinfo requestMerchantPgSettings:merchantVanity];
//}
//
- (void)updatePaymentInfo {
  // credit card
  CTSPaymentDetailUpdate* creditCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* creditCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  creditCard.number = TEST_CREDIT_CARD_NUMBER;
  creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
  creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
  creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
  creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
  // creditCard.cvv = TEST_CREDIT_CARD_CVV;
  [creditCardInfo addCard:creditCard];

  // debit card
  CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* debitCard =
      [[CTSElectronicCardUpdate alloc] initDebitCard];

  debitCard.number = TEST_DEBIT_CARD_NUMBER;
  debitCard.expiryDate = TEST_DEBIT_CARD_EXPIRY;
  debitCard.scheme = TEST_DEBIT_SCHEME;
  debitCard.ownerName = TEST_DEBIT_OWNER_NAME;
  debitCard.name = TEST_BANK_NAME;
  debitCard.token = TEST_DEBIT_CARD_TOKEN;
  debitCard.cvv = TEST_DEBIT_CVV;
  [paymentInfo addCard:debitCard];
  [profileLayer updatePaymentInformation:paymentInfo];
}

//- (void)doUserDebitCardPayment {
//  CTSPaymentDetailUpdate* creditCardInfo =
//      [[CTSPaymentDetailUpdate alloc] init];
//  CTSElectronicCardUpdate* creditCard =
//      [[CTSElectronicCardUpdate alloc] initCreditCard];
//  creditCard.number = TEST_CREDIT_CARD_NUMBER;
//  creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
//  creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
//  creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
//  creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
//  creditCard.cvv = TEST_CREDIT_CARD_CVV;
//  [creditCardInfo addCard:creditCard];
//
//  [paymentlayerinfo makePaymentByCard:creditCardInfo
//                          withContact:contactInfo
//                               amount:@"1"];
//}

//- (void)doGuestPaymentCard {
//  guestFlowDebitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
//  guestflowdebitcard = [[CTSElectronicCardUpdate alloc] initDebitCard];
//  guestflowdebitcard.number = TEST_DEBIT_CARD_NUMBER;
//  guestflowdebitcard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
//  guestflowdebitcard.scheme = TEST_DEBIT_SCHEME;
//  guestflowdebitcard.cvv = TEST_DEBIT_CVV;
//  guestflowdebitcard.ownerName = TEST_OWNER_NAME;
//
//  [guestFlowDebitCardInfo addCard:guestflowdebitcard];
//
//  [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowDebitCardInfo
//                                  withContact:contactInfo
//                                       amount:@"1"
//                                   isDoSignup:YES];
//}

//- (void)doGuestPaymentNetbanking {
//  CTSPaymentDetailUpdate* guestFlowNetBankingUpdate =
//      [[CTSPaymentDetailUpdate alloc] init];
//  CTSNetBankingUpdate* guestflownetbank = [[CTSNetBankingUpdate alloc] init];
//  guestflownetbank.code = TEST_NETBAK_CODE;
//  [guestFlowNetBankingUpdate addNetBanking:guestflownetbank];
//
//  [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowNetBankingUpdate
//                                  withContact:contactInfo
//                                       amount:@"1"
//                                   isDoSignup:NO];
//}

//- (void)doTokenizedPaymentNetbanking {
//  CTSPaymentDetailUpdate* tokenizedNetbankingInfo =
//      [[CTSPaymentDetailUpdate alloc] init];
//  CTSNetBankingUpdate* tokenizednetbank = [[CTSNetBankingUpdate alloc] init];
//  tokenizednetbank.token = TEST_TOKENIZED_PAYBANK_TOKEN;
//  [tokenizedNetbankingInfo addNetBanking:tokenizednetbank];
//
//  [paymentlayerinfo makePaymentByNetBanking:tokenizedNetbankingInfo
//                                withContact:contactInfo
//                                     amount:@"1"];
//}

//- (void)doTokenizedPaymentDebitCard {
//  CTSPaymentDetailUpdate* tokenizedCardInfo =
//      [[CTSPaymentDetailUpdate alloc] init];
//  CTSElectronicCardUpdate* tokenizedCard =
//      [[CTSElectronicCardUpdate alloc] initDebitCard];
//  tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
//  tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
//  [tokenizedCardInfo addCard:tokenizedCard];
//
//  [paymentlayerinfo makeTokenizedCardPayment:tokenizedCardInfo
//                                 withContact:contactInfo
//                                      amount:@"1"];
//}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
