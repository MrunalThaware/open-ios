//
//  SampleViewController.m
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 08/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "SampleViewController.h"
#import "NSObject+logProperties.h"
#import "TestParams.h"
#import "ServerSignature.h"
#import "CTSUtility.h"
#import "UIUtility.h"
#import "RedirectWebViewController.h"
#import "CTSProfileUpdate.h"

@interface SampleViewController ()
@property (strong, nonatomic) IBOutlet UITextField *otp;
@end

#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CitrusPay iOS Native Payment SDK Kit";
    
    [self initialize];
    
//    [self generateMobileVerificationCode];
    
//    [self validateMobileVerficationCode:@"6k31"];

}


// Initialize the SDK layer viz CTSAuthLayer/CTSProfileLayer/CTSPaymentLayer
- (void)initialize {
#warning Enter your Keys & URLs here

    // 010615 Dynamic Oauth keys init with base URL
#ifdef SANDBOX_MODE
    // for Sandbox environment
    authLayer = [[CTSAuthLayer alloc] initWithBaseURLAndDynamicVanityOauthKeysURLs:@"https://sandboxadmin.citruspay.com" vanityUrl:@"nativeSDK" signInId:@"citrus-cube-mobile-app" signInSecretKey:@"bd63aa06f797f73966f4bcaa4bba00fe" subscriptionId:@"test-signup" subscriptionSecretKey:@"c78ec84e389814a05d3ae46546d16d2e" returnUrl:@"http://clients.vxtindia.net/citrus/" merchantAccessKey:@"F2VZD1HBS2VVXJPMWO77"];
#elif STAGING_MODE
    // for Staging environment
    authLayer = [[CTSAuthLayer alloc] initWithBaseURLAndDynamicVanityOauthKeysURLs:@"https://stg1admin.citruspay.com" vanityUrl:@"stgcube" signInId:@"citrus-cube-mobile-app" signInSecretKey:@"bd63aa06f797f73966f4bcaa4bba00fe" subscriptionId:@"citrus-native-mobile-subscription" subscriptionSecretKey:@"3e2288d3a1a3f59ef6f93373884d2ca1" returnUrl:@"http://clients.vxtindia.net/citrus/" merchantAccessKey:@"F2VZD1HBS2VVXJPMWO77"];
#else
    // for Production environment
    authLayer = [[CTSAuthLayer alloc] initWithBaseURLAndDynamicVanityOauthKeysURLs:@"https://admin.citruspay.com" vanityUrl:@"rio" signInId:@"citrus-cube-mobile-app" signInSecretKey:@"bd63aa06f797f73966f4bcaa4bba00fe" subscriptionId:@"citrus-native-mobile-subscription" subscriptionSecretKey:@"3e2288d3a1a3f59ef6f93373884d2ca1" returnUrl:@"http://clients.vxtindia.net/citrus/" merchantAccessKey:@"2GPZFO5FDDLTQY0O98JT"];
#endif

    profileLayer = [[CTSProfileLayer alloc] init];
    paymentlayerinfo = [[CTSPaymentLayer alloc] init];
    
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

// Sign up for new user
- (IBAction)signUp {
    [UIUtility didPresentLoadingAlertView:@"Loading..." withActivity:YES];
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
                        LogDebug(@"userName %@ ", userName);
                        LogDebug(@"token %@ ", token);
                        LogDebug(@"signin %d ",isSignedIn );
                        
                        
                        NSString *toastMessage;
                        if(error){
                            [self logError:error];
                            toastMessage = error.localizedDescription;
                        }
                        else if (isSignedIn == NO){
                            LogDebug(@"signup success,signin failed");//take user to signin page
                            toastMessage = @"signup success,signin failed";
                        }
                        else if(isSignedIn ==YES){
                            [self getBalance];
                            LogDebug(@"signup success,signin success");
                            toastMessage = @"signup success,signin success";
                        }
                        [UIUtility dismissLoadingAlertView:YES];
                        [UIUtility toastMessageOnScreen:toastMessage];
                    }];
}

// Bind for user
-(IBAction)bindUser{
    [authLayer requestBindSigninUsername:TEST_EMAIL completionHandler:^(NSError *error) {
        [self logError:error];
    }];
}

// Sign in for use if he has account
- (IBAction)signIn {
    [UIUtility didPresentLoadingAlertView:@"Loading..." withActivity:YES];
    [authLayer requestSigninWithUsername:TEST_EMAIL
                                password:TEST_PASSWORD
                       completionHandler:^(NSString* userName,
                                           NSString* token,
                                           NSError* error) {
                           
                           NSString *toastMessage;
                           if (error) {
                               [self logError:error];
                               toastMessage = error.localizedDescription;
                           }
                           else{
                               LogDebug(@" Success!! ");
                               LogDebug(@"userName %@ ", userName);
                               LogDebug(@"token %@ ", token);
                               toastMessage = [NSString stringWithFormat:@"Success!!\nuserName:%@\ntoken:%@",userName, token];
                           }
                           [UIUtility dismissLoadingAlertView:YES];
                           [UIUtility toastMessageOnScreen:toastMessage];
                       }];
}

-(void)validateOTP:(NSString *)otp{
    [authLayer requestOTPVerificationUserName:TEST_MOBILE otp:otp completionHandler:^(BOOL isVerified, NSError *error) {
        LogDebug(@" isVerified %d ",isVerified);
        LogDebug(@" error %@  ",error);
    }];
}

-(void)isMobileVerified{
    [authLayer requestIsMobileVerified:TEST_MOBILE completionHandler:^(BOOL isVerified, NSError *error) {
        LogDebug(@" isVerified %d ",isVerified);
        LogDebug(@" error %@ ",error);
        
    }];
}

-(void)verifyUser{
    [authLayer requestVerifyUser:TEST_MOBILE completionHandler:^(CTSUserVerificationRes *verificationRes, NSError *error) {
        if(error){
            [self logError:error];
        }
        else{
            LogDebug(@" status %d",verificationRes.status);//status 0 when this username is not used(can be used for mobile and email), else 1
            LogDebug(@" response Message %@ ",verificationRes.respMsg);
            LogDebug(@" user name type %@ ",verificationRes.userType);
        }
    }];
}

-(void)isUserVerifedWithOauth{
    [authLayer requestIsUserVerified:TEST_MOBILE completionHandler:^(CTSUserVerificationRes *verificationRes, NSError *error) {
        if(error){
            [self logError:error];
        }
        else{
            LogDebug(@" status %d",verificationRes.status);//status 0 when this username is not used(can be used for mobile and email), else 1
            LogDebug(@" response Message %@ ",verificationRes.respMsg);
            LogDebug(@" user name type %@ ",verificationRes.userType);
            
        }
    }];
}


-(void)regenerateOTP{
    [authLayer requestOTPRegenerateMobile:@"9811112211" completionHandler:^(NSError *error) {
        LogDebug(@" requestOTPRegenerateMobile error %@ ",error);
        [self logError:error];
    }];
}

- (void)isUserCitrusMember {
    [authLayer requestIsUserCitrusMemberUsername:TEST_EMAIL
                               completionHandler:^(BOOL isUserCitrusMember,
                                                   NSError* error) {
                                   LogDebug(@" isUserCitrusMember %d",
                                        isUserCitrusMember);
                                   LogDebug(@" error %@ ", error);
                               }];
}

- (void)requestResetPassword {
    [authLayer requestResetPassword:TEST_EMAIL completionHandler:^(NSError *error) {
        [self logError:error];
    }];
}


/**********************************************|PROFILELAYER|*****************************************************/

#pragma mark - Profile Sample implementation

// update PaymentInfo.
-(IBAction)updatePaymentInfo{
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
    
    // debit card
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initDebitCard];
    debitCard.number = TEST_DEBIT_CARD_NUMBER;
    debitCard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
    debitCard.scheme = TEST_DEBIT_SCHEME;
    debitCard.ownerName = TEST_DEBIT_OWNER_NAME;
    debitCard.name = TEST_DEBIT_CARD_BANK_NAME;
    [paymentInfo addCard:debitCard];
    
    // netbaking
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    netBank.name = @"Yadnesh Wankhede";
    netBank.bank = @"YES Bank";
    [paymentInfo addNetBanking:netBank];
    
    // Configure your request here.
    [profileLayer updatePaymentInformation:paymentInfo withCompletionHandler:^(NSError *error) {
        NSString *toastMessage;
        if (error) {
            LogDebug(@"error %@",[error localizedDescription]);
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@"Success!!");
            toastMessage = @"Success!!";
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}


// get PaymentInfo.
-(IBAction)getPaymentInfo{
    // Configure your request here.
    [profileLayer requestPaymentInformationWithCompletionHandler:^(CTSProfilePaymentRes *paymentInfo, NSError *error) {
        NSString *toastMessage;
        if (error) {
            [self logError:error];
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@" Success!! ");
            LogDebug(@"paymentInfo %@ ", paymentInfo.paymentOptions.lastObject);
            toastMessage = [NSString stringWithFormat:@"Success!!\npaymentInfo:%@ ", paymentInfo.paymentOptions.lastObject];
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}

-(IBAction)saveDefaultPaymentOption{
    
    [UIUtility didPresentLoadingAlertView:@"Updating..." withActivity:YES];
    //first get all the saved payment options
    [profileLayer requestPaymentInformationWithCompletionHandler:^(CTSProfilePaymentRes *paymentInfo, NSError *error) {
        __block id toastMessage;
        if (error == nil) {
            LogDebug(@" paymentInfo.type %@", paymentInfo.type);
            LogDebug(@" paymentInfo.defaultOption %@", paymentInfo.defaultOption);
            
            //get the name of the option that you want to set as default(server only populated this name)> here assuming that we want to set payment option at recently used as default, this will usually come from UI
            CTSPaymentOption *toBeDefaultOption = [paymentInfo.paymentOptions lastObject];
            NSString *name = toBeDefaultOption.name;
            CTSPaymentDetailUpdate* option = [[CTSPaymentDetailUpdate alloc] init];
            option.defaultOption = name;
            
            //this call saves the option as default
            // Configure your request here.
            [profileLayer updatePaymentInformation:option withCompletionHandler:^(NSError *error) {
                if (error) {
                    LogDebug(@"error %@",[error localizedDescription]);
                    toastMessage = error.localizedDescription;
                }
                else{
                    LogDebug(@"Success!!");
                    NSString *defaultOption = paymentInfo.defaultOption;
                    
                    for (CTSPaymentOption *object in paymentInfo.paymentOptions) {
                        if ([object.name isEqualToString:defaultOption]) {
//                            toastMessage = object;
                            toastMessage = @"Success!!";
                        }
                    }
                }
                if (toastMessage) {
                    [UIUtility dismissLoadingAlertView:YES];
                    [UIUtility toastMessageOnScreen:toastMessage];
                }
            }];
        } else {
            LogDebug(@"error received %@", error);
            toastMessage = error.localizedDescription;
        }
        if (toastMessage) {
            [UIUtility dismissLoadingAlertView:YES];
            [UIUtility toastMessageOnScreen:toastMessage];
        }
    }];
}


- (void)updateContactInformation {
    CTSContactUpdate* contactUpdate = [[CTSContactUpdate alloc] init];
    contactUpdate.firstName = @"Yadnesh";
    contactUpdate.lastName = @"Wankhedeqq";
    contactUpdate.mobile = @"9167291274";
    contactUpdate.email = @"yaddy@gmail.com";
    
    [profileLayer updateContactInformation:contactUpdate withCompletionHandler:^(NSError* error) {
         [profileLayer requestContactInformationWithCompletionHandler:nil];
     }];
}

/****************************************|PAYMENTLAYER|**************************************************/

#pragma mark - PaymentLayer Sample implementation

- (void)doUserNetbankingPayment {
    CTSPaymentDetailUpdate* netBankingPaymentInfo =
    [[CTSPaymentDetailUpdate alloc] init];
    CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
    netbank.code = @"CID001";
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
     withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                             NSError* error) {
         [self handlePaymentResponse:paymentInfo error:error];
     }];
}


- (void)doUserDebitCardPayment {
    CTSPaymentDetailUpdate* debitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    debitCard.number = TEST_DEBIT_CARD_NUMBER;
    debitCard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
    debitCard.scheme = TEST_DEBIT_SCHEME;
    debitCard.ownerName = TEST_DEBIT_OWNER_NAME;
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
     withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                             NSError* error) {
         [self handlePaymentResponse:paymentInfo error:error];
     }];
}


- (IBAction)doUserCreditCardPayment {
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
    LogDebug(@"transactionId:%@", transactionId);
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
                withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                                        NSError* error) {
                    [self handlePaymentResponse:paymentInfo error:error];
                }];
}


- (NSString*)createTXNId {
    NSString* transactionId;
    long long CurrentTime =
    (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    transactionId = [NSString stringWithFormat:@"CTS%lld", CurrentTime];
    return transactionId;
}


- (void)doTokenizedPaymentNetbanking {
    NSString* transactionId = [self createTXNId];
    LogDebug(@"transactionId:%@", transactionId);
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
                     withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                                             NSError* error) {
                         [self handlePaymentResponse:paymentInfo error:error];
                     }];
}

- (void)doTokenizedPaymentCreditCard {
    
    
    NSString* transactionId = [self createTXNId];
    LogDebug(@"transactionId:%@", transactionId);
    
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
                     withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                                             NSError* error) {
                         [self handlePaymentResponse:paymentInfo error:error];
                     }];
}

/**********************************************|PREPAID API|*****************************************************/


#pragma mark - Prepaid API
// Prepaid API

// get Cookie
-(IBAction)getCookie {
    LogDebug(@"Is cookie set already %d",   [authLayer isCookieSetAlready]);
    [UIUtility didPresentLoadingAlertView:@"Loading..." withActivity:YES];
    [authLayer requestCitrusPaySignin:TEST_EMAIL password:TEST_PASSWORD completionHandler:^(NSError *error) {
        LogDebug(@"requestCitrusPaySignin");
        NSString *toastMessage;
        if (error) {
            LogDebug(@"error %@",[error localizedDescription]);
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@"Success!!");
            toastMessage = @"Success!!";
        }
        [UIUtility dismissLoadingAlertView:YES];
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}


// get Balance
-(IBAction)getBalance{
    [profileLayer requestGetBalance:^(CTSAmount *amount, NSError *error) {
        NSString *toastMessage;
        if (error) {
            LogDebug(@"error %@",[error localizedDescription]);
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@" Success ");
            LogDebug(@" value %@ ",amount.value);
            LogDebug(@" currency %@ ",amount.currency);
            toastMessage = [NSString stringWithFormat:@"Success!!\nvalue:%@\ncurrency:%@",amount.value, amount.currency];
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}


// activate Prepaid User
-(void)activatePrepaidUser{
    [profileLayer requestActivatePrepaidAccount:^(BOOL isActivated, NSError *error) {
        NSString *toastMessage;
        if (error) {
            [self logError:error];
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@" Success!! ");
            LogDebug(@"isActivated %d",isActivated);
            toastMessage = [NSString stringWithFormat:@"Success!!\nisActivated:%i", isActivated];
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}

// load Money In CitrusPay Using Card
-(IBAction)loadMoneyInCitrusPayUsingCard{
    
    CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for card payment.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = @"VISA";
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    //creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    [creditCardInfo addCard:creditCard];
    
    [paymentlayerinfo requestLoadMoneyInCitrusPay:creditCardInfo withContact:contactInfo withAddress:addressInfo amount:@"1000" returnUrl:CTSAuthLayer.getReturnUrl withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
}


// load Money InCitrusPay Using CardToken
-(IBAction)loadMoneyInCitrusPayUsingCardToken{
    
    CTSPaymentDetailUpdate *tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for tokenized payment.
    CTSElectronicCardUpdate *tokenizedCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    tokenizedCard.cvv= TEST_CREDIT_CARD_CVV;
    tokenizedCard.token= TEST_TOKENIZED_CARD_TOKEN;
    [tokenizedCardInfo addCard:tokenizedCard];
    
    [paymentlayerinfo requestLoadMoneyInCitrusPay:tokenizedCardInfo withContact:contactInfo withAddress:addressInfo amount:@"1" returnUrl:CTSAuthLayer.getReturnUrl withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
}


// load Money In CitrusPay Using Netbank
-(IBAction)loadMoneyInCitrusPayUsingNetbank{
    
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update bank details for net banking payment.
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    netBank.code = TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];
    
    [paymentlayerinfo requestLoadMoneyInCitrusPay:paymentInfo withContact:contactInfo withAddress:addressInfo amount:@"10" returnUrl:CTSAuthLayer.getReturnUrl withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
}


// pay Using Citrus Cash
-(IBAction)payUsingCitrusCash{
    if ([authLayer isCookieSetAlready]) {
        NSString* transactionId = [self createTXNId];
        NSString* signature = [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
        
        [paymentlayerinfo requestChargeCitrusCashWithContact:contactInfo withAddress:addressInfo
                                                      amount:@"1"
                                               withReturnUrl:CTSAuthLayer.getReturnUrl
                                               withSignature:signature
                                                   withTxnId:transactionId
                                        returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *paymentInfo, NSError *error) {
                                            NSString *toastMessage;
                                            if (error) {
                                                [self logError:error];
                                                toastMessage = error.localizedDescription;
                                            }
                                            else{
                                                LogDebug(@" Success!! ");
                                                LogDebug(@" paymentInfo: %@",paymentInfo.responseDict);
                                                toastMessage = [NSString stringWithFormat:@"Success!!\npaymentInfo:%@ ", paymentInfo.responseDict];
                                            }
                                            [UIUtility toastMessageOnScreen:toastMessage];
                                        }];
    }else{
        [UIUtility toastMessageOnScreen:@"Cookie is getting set now!"];
        [self getCookie];
        [UIUtility toastMessageOnScreen:@"Now, try again"];
    }
}



-(void)handlePaymentResponse:(CTSPaymentTransactionRes *)paymentInfo error:(NSError *)error{
    
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    if(hasSuccess){
        // Your code to handle success.
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIUtility dismissLoadingAlertView:YES];
            if (hasSuccess && error.code != ServerErrorWithCode) {
                [UIUtility didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
                [self loadRedirectUrl:paymentInfo.redirectUrl];
            }else{
                [UIUtility didPresentErrorAlertView:error];
            }
        });
        
    }
    else{
        // Your code to handle error.
        NSString *errorToast;
        if(error== nil){
            errorToast = [NSString stringWithFormat:@" payment failed : %@",paymentInfo.txMsg] ;
        }else{
            errorToast = [NSString stringWithFormat:@" payment failed : %@",toErrorDescription(error)] ;
        }
        [UIUtility toastMessageOnScreen:errorToast];
    }
}


- (void)loadRedirectUrl:(NSString*)redirectURL {
    RedirectWebViewController* redirectWebViewController = [[RedirectWebViewController alloc] init];
    redirectWebViewController.redirectURL = redirectURL;
    [UIUtility dismissLoadingAlertView:YES];
    [self.navigationController pushViewController:redirectWebViewController animated:YES];
}


-(void)logError:(NSError *)error{
    LogDebug(@" error %@  ",error);
    CTSRestError *errorCTS = [[error userInfo] objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
    LogDebug(@" error description %@ ",[[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
    LogDebug(@" errorCTS type %@",errorCTS.type);
    LogDebug(@" errorCTS description %@",errorCTS.description);
    LogDebug(@" errorCTS responseString %@",errorCTS.serverResponse);
}

/**************************************************************************************************************************************/
/**************************************************************************************************************************************/

// 23062015 New API
-(void)generateMobileVerificationCode{
    [authLayer requestGenerateMobileVerificationCode:@"9011094323" completionHandler:^(NSError *error) {
        NSString *toastMessage;
        if (error) {
            [self logError:error];
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@"Success!!");
            toastMessage = @"Success!!";
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}

// 23062015 New API
-(void)validateMobileVerficationCode:(NSString *)mobileOTP{
    [authLayer requestVerifyMobileCodeWithMobile:@"9011094323" mobileOTP:mobileOTP completionHandler:^(BOOL isVerified, NSError *error) {
        NSString *toastMessage;
        if (error) {
            [self logError:error];
            LogDebug(@" error %@  ",error);
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@"Success!!");
            LogDebug(@" isVerified %d ",isVerified);
            toastMessage = @"Success!!";
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}


// sign In With e or m OTP
- (IBAction)signInWithOTP {
    [UIUtility didPresentLoadingAlertView:@"Loading..." withActivity:YES];
    [authLayer requestSignInWithOTP:self.otp.text
                  withEmailORMobile:TEST_MOBILE
              withCompletionHandler:^(NSString* userName,
                                      NSString* token,
                                      NSError* error) {
                  NSString *toastMessage;
                  if (error) {
                      [self logError:error];
                      toastMessage = error.localizedDescription;
                  }
                  else{
                      LogDebug(@" Success!! ");
                      LogDebug(@"userName %@ ", userName);
                      LogDebug(@"token %@ ", token);
                      toastMessage = [NSString stringWithFormat:@"Success!!\nuserName:%@\ntoken:%@",userName, token];
                  }
                  [UIUtility dismissLoadingAlertView:YES];
                  [UIUtility toastMessageOnScreen:toastMessage];
              }];
}


// generate sign In OTP
- (IBAction)generateSignInOTP {
    [authLayer requestGenerateOTPWithEmailORMobile:TEST_MOBILE
                                    withSourceType:RIO_SRC_TYPE
                             withCompletionHandler:^(CTSResponseData *responseData, NSError *error) {
                                 NSString *toastMessage;
                                 if (error) {
                                     [self logError:error];
                                     toastMessage = error.localizedDescription;
                                 }
                                 else{
                                     LogDebug(@" Success!! ");
                                     LogDebug(@"responseData.responseData %@ ", responseData.responseData);
                                     toastMessage = responseData.responseMessage;
                                 }
                                 [UIUtility dismissLoadingAlertView:YES];
                                 [UIUtility toastMessageOnScreen:toastMessage];
                             }];
}


// get PaymentInfo.
-(IBAction)getMemberInfo{
    // Configure your request here.
    [profileLayer requestMemberInfoWithMobile:nil withEmail:TEST_EMAIL withCompletionHandler:^(CTSNewContactProfile *profile, NSError *error) {
        NSString *toastMessage;
        if (error) {
            [self logError:error];
            toastMessage = error.localizedDescription;
        }
        else{
            LogDebug(@" Success!! ");
            LogDebug(@"profile %@ ", profile.responseData);
            toastMessage = [NSString stringWithFormat:@"%@", profile.responseData];
        }
        [UIUtility toastMessageOnScreen:toastMessage];
    }];
}

#pragma mark - Vault API

// get get vault token for Credit card only.
-(IBAction)getMetaDataForCard{
    // Configure your request here.
    [paymentlayerinfo getMetaDataForCardWithPAN:@"554637" withCompletionHandler:^(CTSMetaDataCard *metaDataCard, NSError *error) {
        if (error) {
            [self logError:error];
            [UIUtility toastMessageOnScreen:error.localizedDescription];
        }
        else{
            LogDebug(@" Success!! ");
            LogDebug(@"metaDataCard %@ ", metaDataCard.description);
            [UIUtility toastMessageOnScreen:metaDataCard.description];
        }
    }];
}

// get get vault token for Credit card only.
-(IBAction)getVaultToken{
    // Configure your request here.
    [paymentlayerinfo getVaultTokenWithPAN:@"4444333322221111" withHolder:@"Mukesh Patil" withExpiry:@"08/34" withUserID:TEST_EMAIL withCompletionHandler:^(CTSVaultToken *vaultToken, NSError *error) {
        if (error) {
            [self logError:error];
            [UIUtility didPresentErrorAlertView:error];
        }
        else{
            LogDebug(@" Success!! ");
            LogDebug(@"vaultToken %@ ", vaultToken.description);
            [UIUtility toastMessageOnScreen:vaultToken.description];
        }
    }];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    LogDebug(@"You entered %@",self.otp.text);
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    LogDebug(@"You entered %@",self.otp.text);
    [textField resignFirstResponder];
}

@end



