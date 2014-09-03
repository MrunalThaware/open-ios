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
#import "TestParams.h"
#import "MerchantConstants.h"
#import "ServerSignature.h"

@interface ViewController ()

@end
#define TextCreditCards  \
  @[                     \
    @"371449635398431",  \
    @"30569309025904",   \
    @"6011111111111117", \
    @"3530111333300000", \
    @"5555555555554444", \
    @"4111111111111111", \
    @"6759649826438453"  \
  ]
@implementation ViewController
//@synthesize contactInfo, guestflowdebitcard, guestFlowDebitCardInfo;
- (void)viewDidLoad {
  [super viewDidLoad];
  [self initialize];
  [self signIn];
  //[self testCardSchemes];
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

  addressInfo = [[CTSUserAddress alloc] init];
  addressInfo.city = @"Mumbai";
  addressInfo.country = @"India";
  addressInfo.state = @"Maharashtra";
  addressInfo.street1 = @"Golden Road";
  addressInfo.street2 = @"Pink City";
  addressInfo.zip = @"401209";

  // guest flow
}
/****************************************************|AUTHLAYER|***************************************************/

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
                         //                         [paymentlayerinfo
                         //                         requestMerchantPgSettings:VanityUrl
                         //                                               withCompletionHandler:nil];

                         //[self doUserDebitCardPayment];
                         //[self doGuestPaymentCard];
                         [self doUserNetbankingPayment];
                         //[self doTokenizedPaymentNetbanking];

                         //[self updatePaymentInfo];
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
                      [self signIn];
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

- (void)auth:(CTSAuthLayer*)layer didChangePasswordError:(NSError*)error {
}

- (void)auth:(CTSAuthLayer*)layer didRequestForResetPassword:(NSError*)error {
}

- (void)auth:(CTSAuthLayer*)layer
    didCheckIsUserCitrusMember:(BOOL)isMember
                         error:(NSError*)error {
}

/**********************************************|PROFILELAYER|*****************************************************/

#pragma mark - Profile Sample implementation

- (void)updatePaymentInfo {
  CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];

  // credit card
  CTSElectronicCardUpdate* creditCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  creditCard.number = TEST_CREDIT_CARD_NUMBER;
  creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
  creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
  creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
  creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
  [paymentInfo addCard:creditCard];

  //  // debit card
  CTSElectronicCardUpdate* debitCard =
      [[CTSElectronicCardUpdate alloc] initDebitCard];
  debitCard.number = TEST_DEBIT_CARD_NUMBER;
  debitCard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
  debitCard.scheme = TEST_DEBIT_SCHEME;
  debitCard.ownerName = TEST_DEBIT_OWNER_NAME;
  debitCard.name = TEST_DEBIT_CARD_BANK_NAME;
  [paymentInfo addCard:debitCard];
  //
  //  // netbaking
  CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
  netBank.name = TEST_NETBAK_OWNER_NAME;
  netBank.bank = TEST_NETBAK_NAME;

  [paymentInfo addNetBanking:netBank];

  // send it to server
  [profileLayer updatePaymentInformation:paymentInfo withCompletionHandler:nil];
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
  // LogTrace(@"contactInfo %@", contactInfo);
  //[contactInfo logProperties];
  LogTrace(@"contactInfo %@", error);
}
- (void)profile:(CTSProfileLayer*)profile
    didReceivePaymentInformation:(CTSProfilePaymentRes*)paymentInfo
                           error:(NSError*)error {
  if (error == nil) {
    LogTrace(@" paymentInfo.type %@", paymentInfo.type);
    LogTrace(@" paymentInfo.defaultOption %@", paymentInfo.defaultOption);

    for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
      [option logProperties];
    }

    paymentSavedResponse = paymentInfo;
  } else {
    LogTrace(@"error received %@", error);
  }
}

- (void)profile:(CTSProfileLayer*)profile
    didUpdateContactInfoError:(NSError*)error {
}

- (void)profile:(CTSProfileLayer*)profile
    didUpdatePaymentInfoError:(NSError*)error {
  LogTrace(@"didUpdatePaymentInfoError error %@ ", error);
  [profileLayer requestPaymentInformationWithCompletionHandler:nil];
}

/****************************************|PAYMENTLAYER|**************************************************/

#pragma mark - PaymentLayer Sample implementation

- (void)doUserNetbankingPayment {
  CTSPaymentDetailUpdate* netBankingPaymentInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
  netbank.code = @"CID001";
  [netBankingPaymentInfo addNetBanking:netbank];
  NSString* txnId = [self createTXNId];
  //  [paymentlayerinfo makeUserPayment:netBankingPaymentInfo
  //                        withContact:contactInfo
  //                             amount:@"1"
  //                      withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
  //                          withTxnId:@"PPTX000000003946"];
  [paymentlayerinfo
            makeUserPayment:netBankingPaymentInfo
                withContact:contactInfo
                withAddress:addressInfo
                     amount:@"1"
              withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
              withSignature:[ServerSignature getSignatureFromServerTxnId:txnId
                                                                  amount:@"1"]
                  withTxnId:txnId
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
  debitCard.name = TEST_DEBIT_CARD_BANK_NAME;
  debitCard.cvv = TEST_DEBIT_CVV;
  [debitCardInfo addCard:debitCard];
  NSString* txnId = [self createTXNId];

  [paymentlayerinfo
            makeUserPayment:debitCardInfo
                withContact:contactInfo
                withAddress:addressInfo
                     amount:@"1"
              withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
              withSignature:[ServerSignature getSignatureFromServerTxnId:txnId
                                                                  amount:@"1"]
                  withTxnId:txnId
      withCompletionHandler:nil];
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

  NSString* transactionId;

  transactionId = [self createTXNId];
  NSLog(@"transactionId:%@", transactionId);
  NSString* signature =
      [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];

  [paymentlayerinfo makeUserPayment:creditCardInfo
                        withContact:contactInfo
                        withAddress:addressInfo
                             amount:@"1"
                      withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                      withSignature:signature
                          withTxnId:transactionId
              withCompletionHandler:nil];
}

- (NSString*)createTXNId {
  NSString* transactionId;
  long long CurrentTime =
      (long long)([[NSDate date] timeIntervalSince1970] * 1000);
  transactionId = [NSString stringWithFormat:@"%lld", CurrentTime];
  // transactionId = [NSString stringWithFormat:@"%lld", 820];

  return transactionId;
}

- (void)doGuestPaymentCard {
  NSString* transactionId = [self createTXNId];

  NSString* signature =
      [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];

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
                                  withAddress:addressInfo
                                withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                withSignature:signature
                                    withTxnId:transactionId
                                   isDoSignup:NO
                        withCompletionHandler:nil];
}

- (void)doGuestPaymentNetbanking {
  NSString* transactionId = [self createTXNId];
  NSLog(@"transactionId:%@", transactionId);
  NSString* signature =
      [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];

  CTSPaymentDetailUpdate* guestFlowNetBankingUpdate =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* guestflownetbank = [[CTSNetBankingUpdate alloc] init];
  guestflownetbank.code = TEST_NETBAK_CODE;
  [guestFlowNetBankingUpdate addNetBanking:guestflownetbank];

  [paymentlayerinfo makePaymentUsingGuestFlow:guestFlowNetBankingUpdate
                                  withContact:contactInfo
                                       amount:@"1"
                                  withAddress:addressInfo
                                withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                withSignature:signature
                                    withTxnId:transactionId
                                   isDoSignup:NO
                        withCompletionHandler:nil];
}

- (void)doTokenizedPaymentNetbanking {
  NSString* transactionId = [self createTXNId];
  NSLog(@"transactionId:%@", transactionId);
  NSString* signature =
      [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
  CTSPaymentDetailUpdate* tokenizedNetbankingInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSNetBankingUpdate* tokenizednetbank = [[CTSNetBankingUpdate alloc] init];
  tokenizednetbank.token = @"29b296cb33e3087865f16de923144bed";
  [tokenizedNetbankingInfo addNetBanking:tokenizednetbank];

  [paymentlayerinfo makeTokenizedPayment:tokenizedNetbankingInfo
                             withContact:contactInfo
                             withAddress:addressInfo
                                  amount:@"1"
                           withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                           withSignature:signature
                               withTxnId:transactionId
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

  /*[paymentlayerinfo
       makeTokenizedPayment:tokenizedCardInfo
                withContact:contactInfo
                     amount:@"1"
              withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                  withTxnId:@"PPTX000000003946"
      withCompletionHandler:nil];*/
}

- (void)doTokenizedPaymentCreditCard {
  CTSPaymentDetailUpdate* tokenizedCardInfo =
      [[CTSPaymentDetailUpdate alloc] init];
  CTSElectronicCardUpdate* tokenizedCard =
      [[CTSElectronicCardUpdate alloc] initCreditCard];
  tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
  tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
  [tokenizedCardInfo addCard:tokenizedCard];

  /* [paymentlayerinfo
        makeTokenizedPayment:tokenizedCardInfo
                 withContact:contactInfo
                      amount:@"1"
               withSignature:@"d894b17023fd49867bc84022188130482e9c9e1b"
                   withTxnId:@"PPTX000000003946"
       withCompletionHandler:nil];*/
}

#pragma mark - Payment layer delegates

- (void)payment:(CTSPaymentLayer*)layer
    didRequestMerchantPgSettings:(CTSPgSettings*)pgSettings
                           error:(NSError*)error {
  NSLog(@"%@", pgSettings);

  LogTrace(@" pgSettings %@ ", pgSettings);
  for (NSString* val in pgSettings.creditCard) {
    LogTrace(@"CC %@ ", val);
  }

  for (NSString* val in pgSettings.creditCard) {
    LogTrace(@"DC %@ ", val);
  }

  for (NSDictionary* arr in pgSettings.netBanking) {
    LogTrace(@"bankName %@ ", [arr valueForKey:@"bankName"]);
    LogTrace(@"issuerCode %@ ", [arr valueForKey:@"issuerCode"]);
  }

  LogTrace(@" error %@ ", error);
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
  LogTrace(@" %@ ", error);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)testCardSchemes {
  for (NSString* cardNumber in TextCreditCards) {
    LogTrace(@" card scheme %@ for card number %@",
             [CTSUtility fetchCardSchemeForCardNumber:cardNumber],
             cardNumber);
  }
}

@end
