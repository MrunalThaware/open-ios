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

@end

@implementation ViewController
//@synthesize contactInfo, guestflowdebitcard, guestFlowDebitCardInfo;
- (void)viewDidLoad {
  [super viewDidLoad];
  [self initialize];

  // pragma marked user methods are sample implementations of sdk
  // TestParams.h should be populated according to your needs

  //[self signUp];
}

- (void)initialize {
  authLayer = [[CTSAuthLayer alloc] init];
  authLayer.delegate = self;
  profileLayer = [[CTSProfileLayer alloc] init];
  profileLayer.delegate = self;
  paymentlayerinfo = [[CTSPaymentLayer alloc] init];
  paymentlayerinfo.delegate = self;

  contactInfo = [[CTSContactUpdate alloc] init];
  contactInfo.firstName = TEST_FIRST_NAME;
  contactInfo.lastName = TEST_LAST_NAME;
  contactInfo.email = TEST_EMAIL;
  contactInfo.mobile = TEST_MOBILE;

  // guest flow
}
/****************************************************|AUTHLAYER|*****************************************************************************/

#pragma mark - AuthLayer Sample implementation

- (void)signIn {
  [authLayer requestSigninWithUsername:TEST_EMAIL
                              password:TEST_PASSWORD
                     completionHandler:^(NSString* userName,
                                         NSString* token,
                                         NSError* error) {
                         LogTrace(@"userName %@ ", userName);
                         LogTrace(@"token %@ ", token);
                         LogTrace(@"error %@ ", error);
                     }];
}

- (void)signUp {
  [authLayer requestSignUpWithEmail:TEST_EMAIL
                             mobile:TEST_MOBILE
                           password:TEST_PASSWORD
                  completionHandler:^(NSString* userName,
                                      NSString* token,
                                      NSError* error) {
                      LogTrace(@"userName %@ ", userName);
                      LogTrace(@"token %@ ", token);
                      LogTrace(@"error %@ ", error);
                  }];
}

- (void)isUserCitrusMember {
  [authLayer requestIsUserCitrusMemberUsername:TEST_EMAIL
                             completionHandler:^(BOOL isUserCitrusMember,
                                                 NSError* error) {
                                 LogTrace(@" isUserCitrusMember %d",
                                          isUserCitrusMember);
                                 LogTrace(@" error %@ ", error);
                             }];
}

#pragma mark - AuthLayer delegates

- (void)auth:(CTSAuthLayer*)layer
    didSigninUsername:(NSString*)userName
           oauthToken:(NSString*)token
                error:(NSError*)error {
  ENTRY_LOG
  LogTrace(@"userName %@", userName);
  LogTrace(@"error %@", error);
  LogTrace(@"access token %@", token);

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

/**********************************************|PROFILELAYER|*****************************************************************************/

#pragma mark - Profile Sample implementation

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

  [creditCardInfo addCard:creditCard];

  [profileLayer updatePaymentInformation:creditCardInfo
                   withCompletionHandler:nil];
}

- (void)updateContactInformation {
  CTSContactUpdate* contactUpdate = [[CTSContactUpdate alloc] init];
  contactUpdate.firstName = @"Yadnesh";
  contactUpdate.lastName = @"Wankhede";
  contactUpdate.mobile = @"9702962222";
  contactUpdate.email = @"yaddy@gmail.com";

  [profileLayer
      updateContactInformation:contactUpdate
         withCompletionHandler:^(NSError* error) {
             [profileLayer requestContactInformationWithCompletionHandler:nil];
         }];
}
#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
    didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
                    error:(NSError*)error {
  LogTrace(@"didReceiveContactInfo");
  LogTrace(@"contactInfo %@", contactInfo);
  [contactInfo logProperties];
  LogTrace(@"contactInfo %@", error);
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
  LogTrace(@"didUpdatePaymentInfoError error %@ ", error);
}

/**************************************************************|PAYMENTLAYER|**************************************************************************/

#pragma mark - PaymentLayer Sample implementation

- (void)doUserNetbankingPayment {
  CTSPaymentDetailUpdate* netBankingPaymentInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
  netbank.code = @"CID001";
  [netBankingPaymentInfo addNetBanking:netbank];
  //  [paymentlayerinfo makeUserPayment:netBankingPaymentInfo
  //                        withContact:contactInfo
  //                             amount:@"1"
  //                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
  //                          withTxnId:@"PPTX000000003946"];
  [paymentlayerinfo makeUserPayment:netBankingPaymentInfo
                        withContact:contactInfo
                             amount:@"1"
                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                          withTxnId:@"PPTX000000003946"
              withCompletionHandler:nil];
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

  /*[paymentlayerinfo makeUserPayment:debitCardInfo
   withContact:contactInfo
   amount:@"1"
   withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
   withTxnId:@"PPTX000000003946"
   withCompletionHandler:nil];*/
  [paymentlayerinfo makeUserPayment:debitCardInfo
                        withContact:contactInfo
                             amount:@"1"
                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                          withTxnId:@"PPTX000000003946"
              withCompletionHandler:^(CTSPaymentTransactionRes* payment,
                                      NSError* error) {
                  LogTrace(@"userName %@ ", payment);
                  LogTrace(@"error %@ ", error);
              }];
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
                          withTxnId:@"PPTX000000003946"
              withCompletionHandler:nil];
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
                                   isDoSignup:NO
                        withCompletionHandler:nil];
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
                                   isDoSignup:NO
                        withCompletionHandler:nil];
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
                  withTxnId:@"PPTX000000003989"
      withCompletionHandler:nil];
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
                  withTxnId:@"PPTX000000003946"
      withCompletionHandler:nil];
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
                  withTxnId:@"PPTX000000003946"
      withCompletionHandler:nil];
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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
