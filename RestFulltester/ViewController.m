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
#import "CTSUtility.h"


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
    //[self verifyUser];
   //[self testCardSchemes];
   // [self regenerateOTP];
//[paymentlayerinfo requestMerchantPgSettings:@"rio" withCompletionHandler:nil];
  //[self signIn];
[self signUp];
  //[self testCardSchemes];
  //[self doGuestPaymentCreditCard];
  //[self doGuestPaymentDebitCard];
//    [authLayer requestResetPassword:TEST_EMAIL completionHandler:^(NSError *error) {
//        [self logError:error];
//        
//    }];
  //[self doGuestPaymentNetbanking];
    //[self isMobileVerified];
    
//    NSString *message = @"Some message...that is very long\n\n\n\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\nthat is very long\n";
//    
//    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
//                                                    message:message
//                                                   delegate:nil
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:nil, nil];
//    [toast show];
//    
//    int duration = 5; // duration in seconds
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [toast dismissWithClickedButtonIndex:0 animated:YES];
//    });
    
   // [authLayer requestIsUserAlreadyRegisteredMobileOrEmail:TEST_EMAIL completionHandler:^(CTSUserVerificationRes *userVerification, NSError *error) {
      //  [self logError:error];
    //}];
    
    
//    NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"09702964502"]);
// NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"00919702964502"]);
//     NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"919702964502"]);
//     NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"+919702964502"]);
//    NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"970-296-4502"]);
//    
//    NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"0970-296-4502"]);
//    NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"00970-296-4502"]);
//    NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"91970-296-4502"]);
//    NSLog(@" CTSUtility mobile validate %d ",[CTSUtility validateMobile:@"+91970-296-4502"]);
    
    //[self validateOTP:@"ae2y"];
    
//    NSLog(@" CTSUtility mobile validate %@ ",[CTSUtility mobileNumberToTenDigitIfValid:@"1702964502"]);




}

- (void)initialize {
    webview = [[UIWebView alloc] init];
    webview.delegate = self;
    webview.frame =
    CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    webview.backgroundColor = [UIColor redColor];
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(160, 300, 30, 30);
    
    [webview addSubview:indicator];
    [self.view addSubview:webview];
    
    authLayer = [[CTSAuthLayer alloc] initWithUrl:BaseUrl];
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
    

    
    customParams = @{@"USERDATA2":@"MOB_RC|9988776655",
                                 @"USERDATA10":@"test",
                                 @"USERDATA4":@"MOB_RC|test@gmail.com",
                                 @"USERDATA3":@"MOB_RC|4111XXXXXXXX1111",
                                 };
    

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
                         [self logError:error];



                         //[self doUserDebitCardPayment];
                         //[self doGuestPaymentCard];
                         //[self doUserNetbankingPayment];
                         //[self doTokenizedPaymentNetbanking];
                         //[self doUserDebitCardPayment];
                         //[self updatePaymentInfo];
                         //[self updateContactInformation];
                         //[self doUserCreditCardPayment];
                         //[self doUserNetbankingPayment];
                         //[self doTokenizedPaymentCreditCard];
                         //[profileLayer requestPaymentInformationWithCompletionHandler:nil];
//                         [profileLayer requestUpdateMobile:@"9867836292" allowUnverified:NO WithCompletionHandler:^(NSError *error) {
//                            [self logError:error];
//                        }];
                         
                         //[self isUserVerifedWithOauth];
                         
                         [profileLayer requestContactInfoNewWithCompletionHandler:^(CTSProfileContactNewRes *contactInfo2, NSError *error) {
                             
                             if(!error){
                             NSLog(@"uuid %@",contactInfo2.uuid);
                              NSLog(@"type %@",contactInfo2.type);
                              NSLog(@"firstName %@",contactInfo2.firstName);
                              NSLog(@"lastName %@",contactInfo2.lastName);
                              NSLog(@"mobileVerified %d",contactInfo2.mobileVerified);
                              NSLog(@"mobile %@",contactInfo2.mobile);
                              NSLog(@"email %@",contactInfo2.email);
                              NSLog(@"emailVerified %d",contactInfo2.emailVerified);
                              NSLog(@"emailDate %@",contactInfo2.emailDate);
                              NSLog(@"mobileDate %@",contactInfo2.mobileDate);
                             }
                             else {
                                 [self logError:error];
                             }

                         }];
                     }];
}

- (void)signUp {
    [authLayer requestSignUpWithEmail:TEST_EMAIL
                               mobile:TEST_MOBILE
                             password:TEST_PASSWORD
                            firstName:TEST_FIRST_NAME
                             lastName:TEST_LAST_NAME
                           sourceType:RIO_SRC_TYPE 
                    completionHandler:^(NSString* userName,
                                        NSString* token,
                                        BOOL isSignedIn,
                                        NSError* error) {
                        LogTrace(@"userName %@ ", userName);
                        LogTrace(@"token %@ ", token);
                        LogTrace(@"signin %d ",isSignedIn );

                        [self logError:error];
                        
                        if(error){
                            LogTrace(@"Error is signup");
                        }
                        else if (isSignedIn == NO){
                          LogTrace(@"signup success,signin failed");//take user to signin page
                        }
                        else if(isSignedIn ==YES){
                            LogTrace(@"signup success,signin success");
                        }
                        
                        
                        // [self signIn];
                        //[self doUserCreditCardPayment];
                    }];
}


-(void)validateOTP:(NSString *)otp{
    [authLayer requestOTPVerificationUserName:TEST_MOBILE otp:otp completionHandler:^(BOOL isVerified, NSError *error) {
        LogTrace(@" isVerified %d ",isVerified);
        LogTrace(@" error %@  ",error);
    }];
}

-(void)isMobileVerified{
    
    [authLayer requestIsMobileVerified:TEST_MOBILE completionHandler:^(BOOL isVerified, NSError *error) {
        LogTrace(@" isVerified %d ",isVerified);
        LogTrace(@" error %@ ",error);
        
    }];
}
-(void)verifyUser{

    [authLayer requestVerifyUser:TEST_MOBILE completionHandler:^(CTSUserVerificationRes *verificationRes, NSError *error) {
    if(error){
        [self logError:error];
    }
    else{
        LogTrace(@" status %d",verificationRes.status);//status 0 when this username is not used(can be used for mobile and email), else 1
        LogTrace(@" response Message %@ ",verificationRes.respMsg);
        LogTrace(@" user name type %@ ",verificationRes.userType);

    
    }
    
    
}];

}


-(void)isUserVerifedWithOauth{
    [authLayer requestIsUserVerified:TEST_MOBILE completionHandler:^(CTSUserVerificationRes *verificationRes, NSError *error) {
        if(error){
            [self logError:error];
        }
        else{
            LogTrace(@" status %d",verificationRes.status);//status 0 when this username is not used(can be used for mobile and email), else 1
            LogTrace(@" response Message %@ ",verificationRes.respMsg);
            LogTrace(@" user name type %@ ",verificationRes.userType);
            
            
        }
        
        
    }];

}


-(void)regenerateOTP{
    [authLayer requestOTPRegenerateMobile:@"9811112211" completionHandler:^(NSError *error) {
        LogTrace(@" requestOTPRegenerateMobile error %@ ",error);
        [self logError:error];
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
    contactUpdate.lastName = @"Wankhedeqq";
    contactUpdate.mobile = @"9167291274";
    contactUpdate.email = @"yaddy@gmail.com";
//#define TEST_EMAIL @"Ganrang.Wala@gmail.com"
//#define TEST_PASSWORD @"tester@123"
//#define TEST_MOBILE @"9167291271"
    
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
    //netbank.name = TEST_NETBAK_OWNER_NAME;
    netbank.bank = TEST_NETBAK_NAME;
    [netBankingPaymentInfo addNetBanking:netbank];
    NSString* txnId = [self createTXNId];
    
    [paymentlayerinfo
     makeUserPayment:netBankingPaymentInfo
     withContact:contactInfo
     withAddress:addressInfo
     amount:@"1"
     withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
     withSignature:[ServerSignature getSignatureFromServerTxnId:txnId
                                                         amount:@"1"]
     withTxnId:txnId
     withCustParams:customParams
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
    //debitCard.name = TEST_DEBIT_CARD_BANK_NAME;
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
     withCustParams:customParams
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
                    withCustParams:customParams
                withCompletionHandler:nil];
}

- (NSString*)createTXNId {
    NSString* transactionId;
    long long CurrentTime =
    (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    transactionId = [NSString stringWithFormat:@"CTS%lld", CurrentTime];
    // transactionId = [NSString stringWithFormat:@"%lld", 820];
    
    return transactionId;
}

- (void)doGuestPaymentCreditCard {
    NSString* transactionId = [self createTXNId];
    
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    CTSElectronicCardUpdate* creditCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme =
    [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    
    [paymentInfo addCard:creditCard];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"1"
                                    withAddress:addressInfo
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                                 withCustParams:customParams
                          withCompletionHandler:nil];
}

- (void)doGuestPaymentDebitCard {
    NSString* transactionId = [self createTXNId];
    
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"10"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initDebitCard];
    debitCard.number = @"5555555555554444";//TEST_DEBIT_CARD_NUMBER;
    debitCard.expiryDate = @"10/2018";
    debitCard.scheme = @"MCRD";//TEST_DEBIT_SCHEME;
    debitCard.cvv = @"111";//TEST_DEBIT_CVV;
    debitCard.ownerName = @"Vinod Patel";//TEST_OWNER_NAME;
    
//    debitCard.number = TEST_DEBIT_CARD_NUMBER;
//    debitCard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
//    debitCard.scheme = TEST_DEBIT_SCHEME;
//    debitCard.cvv = TEST_DEBIT_CVV;
//    debitCard.ownerName = TEST_OWNER_NAME;
    

    
    
    [paymentInfo addCard:debitCard];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"10"
                                    withAddress:nil
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                                 withCustParams:customParams
                          withCompletionHandler:nil];
}

- (void)doGuestPaymentNetbanking {
    NSString* transactionId = [self createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    
    netBank.code = TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"1"
                                    withAddress:addressInfo
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                                 withCustParams:customParams
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
                            withCustParams:customParams
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
    
    
    NSString* transactionId = [self createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* tokenizedCardInfo =
    [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* tokenizedCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
    tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
    [tokenizedCardInfo addCard:tokenizedCard];
    
    [paymentlayerinfo makeTokenizedPayment:tokenizedCardInfo
                               withContact:contactInfo
                               withAddress:addressInfo
                                    amount:@"1"
                             withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                             withSignature:signature
                                 withTxnId:transactionId
                            withCustParams:customParams
                     withCompletionHandler:nil];
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
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    if (hasSuccess) {
        [self loadRedirectUrl:paymentInfo.redirectUrl];
    }
}

- (void)payment:(CTSPaymentLayer*)layer
didMakeTokenizedPayment:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error {
    NSLog(@"%@", paymentInfo);
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    if (hasSuccess) {
        [self loadRedirectUrl:paymentInfo.redirectUrl];
    }
    
    
    if(error != nil && error.code == ServerErrorWithCode){
        NSDictionary *userInfo = [error userInfo];
        CTSRestError *citrusError = (CTSRestError *)[userInfo objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
        NSLog(@" citrusError type %@",citrusError.type);
        NSLog(@" citrusError description %@",citrusError.description);
        NSLog(@" citrusError serverResponse %@",citrusError.serverResponse);
    }
}

- (void)payment:(CTSPaymentLayer*)layer
didMakePaymentUsingGuestFlow:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error {
    NSLog(@"%@", paymentInfo);
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    if (hasSuccess) {
        [self loadRedirectUrl:paymentInfo.redirectUrl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)testCardSchemes {
    for (NSString* cardNumber in TextCreditCards) {
        LogTrace(@" card scheme %@ for card number %@",
                 [CTSUtility fetchCardSchemeForCardNumber:cardNumber],
                 cardNumber);
    }
}

#pragma mark - helper methods

- (void)loadRedirectUrl:(NSString*)redirectURL {
    [self.view addSubview:webview];
    [webview loadRequest:[[NSURLRequest alloc]
                          initWithURL:[NSURL URLWithString:redirectURL]]];
}

- (void)transactionComplete:(NSDictionary*)transactionResult {
    LogTrace(@" transactionResult %@ ",
             [transactionResult objectForKey:@"TxStatus"]);
    [webview removeFromSuperview];
}


-(void)logError:(NSError *)error{

    LogTrace(@" error %@  ",error);
    CTSRestError *errorCTS = [[error userInfo] objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
    LogTrace(@" error description %@ ",[[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
    LogTrace(@" errorCTS type %@",errorCTS.type);
    LogTrace(@" errorCTS description %@",errorCTS.description);
    LogTrace(@" errorCTS responseString %@",errorCTS.serverResponse);

}

#pragma mark - webview delegates

- (void)webViewDidStartLoad:(UIWebView*)webView {
    [indicator startAnimating];
}

- (BOOL)webView:(UIWebView*)webView
shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSDictionary* responseDict =
    [CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody];
    if (responseDict != nil) {
        [self transactionComplete:responseDict];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [indicator stopAnimating];
}



@end
