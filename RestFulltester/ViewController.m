//
//  ViewController.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "ViewController.h"
#import "CitrusSdk.h"
#import "NSObject+logProperties.h"
#import "HMACSignature.h"
#import "TestParams.h"

@interface ViewController ()
//@property(strong) CTSContactUpdate* contactInfo;
//@property(strong) CTSElectronicCardUpdate* guestflowdebitcard;
//@property(strong) CTSPaymentDetailUpdate* guestFlowDebitCardInfo;
@end

@implementation ViewController
//@synthesize contactInfo, guestflowdebitcard, guestFlowDebitCardInfo;
- (void)viewDidLoad {
  [super viewDidLoad];
  [self initialize];
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

  // pragma marked user methods are sample implementations of sdk
  // TestParams.h should be populated according to your needs
  authLayer = [[CTSAuthLayer alloc] init];
  authLayer.delegate = self;
  profileLayer = [[CTSProfileLayer alloc] init];

  [self signIn];
  //[self signUp];
  //[self updatePaymentInfo];
  paymentlayerinfo = [[CTSPaymentLayer alloc] init];
  paymentlayerinfo.delegate = self;
}

- (void)initialize {
  // required initialization

  // authLayer = [[CTSAuthLayer alloc] init];
  // authLayer.delegate = self;

  // profileService = [[CTSProfileLayer alloc] init];
  // profileService.delegate = self;

  contactInfo = [[CTSContactUpdate alloc] init];
  contactInfo.firstName = TEST_FIRST_NAME;
  contactInfo.lastName = TEST_LAST_NAME;
  contactInfo.email = TEST_EMAIL;
  contactInfo.mobile = TEST_MOBILE;

  // guest flow
}

#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
    didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
                    error:(NSError*)error {
}
- (void)profile:(CTSProfileLayer*)profile
    didReceivePaymentInformation:(CTSProfilePaymentRes*)contactInfo
                           error:(NSError*)error {
}

- (void)profile:(CTSProfileLayer*)profile
    didUpdateContactInfoError:(NSError*)error {
}

- (void)profile:(CTSProfileLayer*)profile
    didUpdatePaymentInfoError:(NSError*)error {
}

#pragma mark - authentication layer delegates

- (void)auth:(CTSAuthLayer*)layer
    didSigninUsername:(NSString*)userName
           oauthToken:(NSString*)token
                error:(NSError*)error {
  ENTRY_LOG
  LogTrace(@"userName %@", userName);
  LogTrace(@"error %@", error);
  LogTrace(@"access token %@", token);

  // make signed in user payments using debit card
  [self doUserDebitCardPayment];

  // make signed in user payments using credit card
  //  [self doUserCreditCardPayment];
  //
  //  // make signed in user payments using netbanking
  //  [self doUserNetbankingPayment];
  //
  //  // make guest payment using netbanking
  //  [self doGuestPaymentNetbanking];
  //
  //  // make guest payment using card
  //  [self doGuestPaymentCard];
  //
  //  // make tokenized payment using debit card
  //  [self doTokenizedPaymentDebitCard];
  //
  //  // make tokenized payment using credit card
  //  [self doTokenizedPaymentCreditCard];
  //
  //  // make tokenized payment using net banking
  //  [self doTokenizedPaymentNetbanking];
  //
  //  // requesting for merchant pg Settings
  //  [paymentlayerinfo requestMerchantPgSettings:@"citrusbank"];

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

#pragma mark - Payment layer delegates

- (void)payment:(CTSPaymentLayer*)layer
    didRequestMerchantPgSettings:(CTSPgSettings*)pgSettings
                           error:(NSError*)error {
  NSLog(@"%@", pgSettings);
}

- (void)payment:(CTSPaymentLayer*)layer
    didMakeUserPayment:(CTSPaymentTransactionRes*)paymentInfo
                 error:(NSError*)error {
  NSLog(@"%@", paymentInfo);
}

- (void)payment:(CTSPaymentLayer*)layer
    didMakeTokenizedPayment:(CTSPaymentTransactionRes*)paymentInfo
                      error:(NSError*)error {
  NSLog(@"%@", paymentInfo);
}

- (void)payment:(CTSPaymentLayer*)layer
    didMakePaymentUsingGuestFlow:(CTSPaymentTransactionRes*)paymentInfo
                           error:(NSError*)error {
  NSLog(@"%@", paymentInfo);
}

#pragma mark - user methods used for testing

- (void)signIn {
  [authLayer requestSigninWithUsername:TEST_EMAIL
                              password:TEST_PASSWORD
                     completionHandler:nil];
}

- (void)signUp {
  [authLayer requestSignUpWithEmail:TEST_EMAIL
                             mobile:TEST_MOBILE
                           password:TEST_PASSWORD
                  completionHandler:nil];
}

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
  creditCard.cvv = TEST_CREDIT_CARD_CVV;
  [creditCardInfo addCard:creditCard];
  [profileLayer updatePaymentInformation:creditCardInfo];
}

- (void)doUserNetbankingPayment {
  CTSPaymentDetailUpdate* netBankingPaymentInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
  netbank.code = @"CID001";
  [netBankingPaymentInfo addNetBanking:netbank];
  [paymentlayerinfo makeUserPayment:netBankingPaymentInfo
                        withContact:contactInfo
                             amount:@"1"
                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                          withTxnId:@"PPTX000000003946"];
}
- (void)doUserDebitCardPayment {
  CTSPaymentDetailUpdate* debitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* debitCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  debitCard.number = TEST_DEBIT_CARD_NUMBER;
  debitCard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
  debitCard.scheme = TEST_DEBIT_SCHEME;
  debitCard.ownerName = TEST_DEBIT_OWNER_NAME;
  debitCard.name = TEST_BANK_NAME;
  debitCard.cvv = TEST_DEBIT_CVV;
  [debitCardInfo addCard:debitCard];

  [paymentlayerinfo makeUserPayment:debitCardInfo
                        withContact:contactInfo
                             amount:@"1"
                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                          withTxnId:@"PPTX000000003946"];
}
- (void)doUserCreditCardPayment {
  CTSPaymentDetailUpdate* creditCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* creditCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  creditCard.number = TEST_CREDIT_CARD_NUMBER;
  creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
  creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
  creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
  creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
  creditCard.cvv = TEST_CREDIT_CARD_CVV;
  [creditCardInfo addCard:creditCard];

  [paymentlayerinfo makeUserPayment:creditCardInfo
                        withContact:contactInfo
                             amount:@"1"
                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                          withTxnId:@"PPTX000000003946"];
}

- (void)doGuestPaymentCard {
  NSString* transactionId;
  long long CurrentTime =
      (long long)([[NSDate date] timeIntervalSince1970] * 1000);
  transactionId = [NSString stringWithFormat:@"%lld", CurrentTime];
  NSLog(@"transactionId:%@", transactionId);
  NSString* signature = [self getGuestPaymentSignature:transactionId:@"1"];
  CTSPaymentDetailUpdate* guestFlowDebitCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* guestflowdebitcard =
      [[CTSElectronicCardUpdate alloc] initDebitCard];
  guestflowdebitcard.number = TEST_DEBIT_CARD_NUMBER;
  guestflowdebitcard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
  guestflowdebitcard.scheme = TEST_DEBIT_SCHEME;
  guestflowdebitcard.cvv = TEST_DEBIT_CVV;
  guestflowdebitcard.ownerName = TEST_OWNER_NAME;

  [guestFlowDebitCardInfo addCard:guestflowdebitcard];

  [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowDebitCardInfo
                                  withContact:contactInfo
                                       amount:@"1"
                                withSignature:signature
                                    withTxnId:transactionId
                                   isDoSignup:NO];
}

- (NSString*)getGuestPaymentSignature:(NSString*)
                        transactionId:(NSString*)amount {
  NSString* signature;

  NSString* data = [NSString
      stringWithFormat:@"merchantAccessKey=%@&transactionId=%@&amount=%@",
                       MLC_GUESTCHECKOUT_ACCESSKEY,
                       transactionId,
                       amount];
  HMACSignature* hmacSignature = [[HMACSignature alloc] init];
  signature =
      [hmacSignature generateHMAC:MLC_GUESTCHECKOUT_SECRETKEY withData:data];
  return signature;
}
- (void)doGuestPaymentNetbanking {
  NSString* transactionId;
  long long CurrentTime =
      (long long)([[NSDate date] timeIntervalSince1970] * 1000);
  transactionId = [NSString stringWithFormat:@"%lld", CurrentTime];
  NSLog(@"transactionId:%@", transactionId);
  NSString* signature = [self getGuestPaymentSignature:transactionId:@"1"];
  CTSPaymentDetailUpdate* guestFlowNetBankingUpdate =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* guestflownetbank = [[CTSNetBankingUpdate alloc] init];
  guestflownetbank.code = TEST_NETBAK_CODE;
  [guestFlowNetBankingUpdate addNetBanking:guestflownetbank];
  [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowNetBankingUpdate
                                  withContact:contactInfo
                                       amount:@"1"
                                withSignature:signature
                                    withTxnId:transactionId
                                   isDoSignup:NO];
}

- (void)doTokenizedPaymentNetbanking {
  CTSPaymentDetailUpdate* tokenizedNetbankingInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* tokenizednetbank = [[CTSNetBankingUpdate alloc] init];
  tokenizednetbank.token = @"9e64001c72fd51c453ff0f2d778b8693";
  [tokenizedNetbankingInfo addNetBanking:tokenizednetbank];

  [paymentlayerinfo
      makeTokenizedPayment:tokenizedNetbankingInfo
               withContact:contactInfo
                    amount:@"1"
             withSignature:@"951906e7c5bb14ed62306d71f7bd85f1b14af6f6"
                 withTxnId:@"PPTX000000003989"];
}

- (void)doTokenizedPaymentDebitCard {
  CTSPaymentDetailUpdate* tokenizedCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* tokenizedCard =
      [[CTSElectronicCardUpdate alloc] initDebitCard];
  tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
  tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
  [tokenizedCardInfo addCard:tokenizedCard];

  [paymentlayerinfo
      makeTokenizedPayment:tokenizedCardInfo
               withContact:contactInfo
                    amount:@"1"
             withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                 withTxnId:@"PPTX000000003946"];
}

- (void)doTokenizedPaymentCreditCard {
  CTSPaymentDetailUpdate* tokenizedCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* tokenizedCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
  tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
  [tokenizedCardInfo addCard:tokenizedCard];
  [paymentlayerinfo
      makeTokenizedPayment:tokenizedCardInfo
               withContact:contactInfo
                    amount:@"1"
             withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                 withTxnId:@"PPTX000000003946"];
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
