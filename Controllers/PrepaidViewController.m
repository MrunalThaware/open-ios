//
//  PrepaidViewController.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 11/03/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "PrepaidViewController.h"
#import "TestParams.h"
#import "UIUtility.h"
#import "RedirectWebViewController.h"

@interface PrepaidViewController ()

@end

@implementation PrepaidViewController
#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeLayers];
    self.title = @"Citrus iOS Native SDK";
}

#pragma mark - initializers

// Initialize the SDK layer viz CTSAuthLayer/CTSProfileLayer/CTSPaymentLayer
-(void)initializeLayers{
    authLayer = [[CTSAuthLayer alloc] init];
    proifleLayer = [[CTSProfileLayer alloc] init];
    paymentLayer = [[CTSPaymentLayer alloc] init];
    
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


#pragma mark - button handlers

// check if anyone is SignedIn
-(IBAction)isUserSignedIn:(id)sender{
    if([authLayer isAnyoneSignedIn]){
        [UIUtility toastMessageOnScreen:@"user is signed in"];
        
    }
    else{
        [UIUtility toastMessageOnScreen:@"no one is logged in"];
    }
}

// Link user creates a Citrus Account of the user. It returns if the user password is already set or not.
-(IBAction)linkUser:(id)sender{
    [authLayer requestLinkUser:TEST_EMAIL mobile:TEST_MOBILE completionHandler:^(CTSLinkUserRes *linkUserRes, NSError *error) {
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"User is now Linked, %@",linkUserRes.message]];
        }
    }];
}

// You can set user password if link user returns field “isPasswordAlreadySet” as NO, it means user is created and now needs to set his/her password
-(IBAction)setPassword:(id)sender{
    [authLayer requestSetPassword:TEST_PASSWORD userName:TEST_EMAIL completionHandler:^(NSError *error) {
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Password is now set"]];
        }
    }];

}

// Forgot password if the user forgets password.
-(IBAction)forgotPassword:(id)sender{
    [authLayer requestResetPassword:TEST_EMAIL completionHandler:^(NSError *error) {
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"reset link sent to email address"]];
        }
    }];
}

// If Link user returns that the “isPasswordAlreadySet == YES”, show SignIn screen.
-(IBAction)signin:(id)sender{
    [authLayer requestSigninWithUsername:TEST_EMAIL password:TEST_PASSWORD completionHandler:^(NSString *userName, NSString *token, NSError *error) {
        LogTrace(@"userName %@",userName);
        LogTrace(@"error %@",error);
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"%@ is now logged in",userName]];
        }
    }];
}


// Sign out loged in user
-(IBAction)signOut:(id)sender{
    [authLayer signOut];
    [UIUtility toastMessageOnScreen:@"Only local tokens & Citrus cookies are cleared"];
}


// You can get user’s citrus cash balance after you have done Link User.
-(IBAction)getBalance:(id)sender{
    [proifleLayer requetGetBalance:^(CTSAmount *amount, NSError *error) {
        LogTrace(@" value %@ ",amount.value);
        LogTrace(@" currency %@ ",amount.currency);
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Balance is %@ %@",amount.value,amount.currency]];
        }
    }];
}

// You can load/add money as per following way
-(IBAction)loadUsingCard:(id)sender{
    // Credit card
    CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for card payment.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    
    [creditCardInfo addCard:creditCard];


    
[paymentLayer requestLoadMoneyInCitrusPay:creditCardInfo withContact:contactInfo withAddress:addressInfo amount:@"100" returnUrl:ReturnUrl customParams:customParams  returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
    if(error){
        [UIUtility toastMessageOnScreen:error.localizedDescription];
    }
    else {
        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Load Money Status %@",[citrusCashResponse.responseDict valueForKey:LoadMoneyResponeKey]]];
    }
}];
}

// You can load/add money as per following way
-(IBAction)loadUsingCardToken:(id)sender{
    // Card token
    CTSPaymentDetailUpdate *tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for tokenized payment.
    CTSElectronicCardUpdate *tokenizedCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    tokenizedCard.cvv= TEST_CREDIT_CARD_CVV;
    tokenizedCard.token= TEST_TOKENIZED_CARD_TOKEN;
    [tokenizedCardInfo addCard:tokenizedCard];


    [paymentLayer requestLoadMoneyInCitrusPay:tokenizedCardInfo withContact:contactInfo withAddress:addressInfo amount:@"100" returnUrl:ReturnUrl customParams:customParams  returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:error.localizedDescription];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Load Money Status %@",[citrusCashResponse.responseDict valueForKey:LoadMoneyResponeKey]]];
        }
    }];
}

// You can load/add money as per following way
-(IBAction)loadUsingNetbank:(id)sender{
    // Net Banking
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update bank details for net banking payment.
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];

    netBank.code = TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];

    [paymentLayer requestLoadMoneyInCitrusPay:paymentInfo withContact:contactInfo withAddress:addressInfo amount:@"100" returnUrl:ReturnUrl customParams:customParams returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:error.localizedDescription];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Load Money Status %@",[citrusCashResponse.responseDict valueForKey:LoadMoneyResponeKey]]];
        }
    }];
}

// make payment using Citrus cash account
-(IBAction)payUsingCitrusCash:(id)sender{
    // Get Bill
    CTSBill *bill = [PrepaidViewController getBillFromServer];

    [paymentLayer requestChargeCitrusCashWithContact:contactInfo withAddress:addressInfo  bill:bill customParams:customParams returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *paymentInfo, NSError *error) {
        NSLog(@"paymentInfo %@",paymentInfo);
        NSLog(@"error %@",error);
        if(error){
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }     
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[paymentInfo.responseDict valueForKey:@"TxStatus"] ]];
        }
    }];
 
}

// This API call fetches the payment options such as VISA, MASTER (in credit and debit  cards) and net banking options available to the merchant.
-(void)requestPaymentModes{
    [paymentLayer requestMerchantPgSettings:VanityUrl withCompletionHandler:^(CTSPgSettings *pgSettings, NSError *error) {
        if(error){
        //handle error
        }
        else {
            LogTrace(@" pgSettings %@ ", pgSettings);
            for (NSString* val in pgSettings.creditCard) {
                LogTrace(@"CC %@ ", val);
            }
            
            for (NSString* val in pgSettings.debitCard) {
                LogTrace(@"DC %@ ", val);
            }
            
            for (NSDictionary* arr in pgSettings.netBanking) {
                LogTrace(@"bankName %@ ", [arr valueForKey:@"bankName"]);
                LogTrace(@"issuerCode %@ ", [arr valueForKey:@"issuerCode"]);
            }
        }
    }];
}

// This is when we want to store bank account for cashout into users profile. At the max there can be only one account saved at a time, so if you want store new account just call this method with new details (previous one will get overridden).
-(IBAction)saveCashoutBankAccount{
    CTSCashoutBankAccount *bankAccount = [[CTSCashoutBankAccount alloc] init];
    bankAccount.owner = @"Yadnesh Wankhede";
    bankAccount.branch = @"HSBC0000123";
    bankAccount.number = @"123456789987654";
    
    [proifleLayer requestUpdateCashoutBankAccount:bankAccount withCompletionHandler:^(NSError *error) {
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:@"Succesfully stored bank account"];
        }
    }];
}

// To get/fetch the cash-out account that’s was saved earlier.
-(IBAction)fetchCashoutBankAccount{
    [proifleLayer requestCashoutBankAccountCompletionHandler:^(CTSCashoutBankAccountResp *bankAccount, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"%@\n number: %@\n ifsc: %@",bankAccount.cashoutAccount.owner,bankAccount.cashoutAccount.number,bankAccount.cashoutAccount.branch]];
        }
    }];

}

// This is when user wants to withdraw money from his/her prepaid account into the bank account, so this needs bank account info to be sent to this method.
-(IBAction)cashOutToBank{
    CTSCashoutBankAccount *bankAccount = [[CTSCashoutBankAccount alloc] init];
    bankAccount.owner = @"Yadnesh Wankhede";
    bankAccount.branch = @"HSBC0000123";
    bankAccount.number = @"123456789987654";
    
    [paymentLayer requestCashoutToBank:bankAccount amount:@"5" completionHandler:^(CTSCashoutToBankRes *cashoutRes, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"id:%@\n cutsomer:%@\n merchant:%@\n type:%@\n date:%@\n amount:%@\n status:%@\n reason:%@\n balance:%@\n ref:%@\n",cashoutRes.id, cashoutRes.cutsomer, cashoutRes.merchant, cashoutRes.type, cashoutRes.date, cashoutRes.amount, cashoutRes.status, cashoutRes.reason, cashoutRes.balance, cashoutRes.ref]];
        }
    }];
}


#pragma mark - Payment Helpers

// Handle payment response after any payment options call back
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

// Load redirect URL to Web view
- (void)loadRedirectUrl:(NSString*)redirectURL {
    RedirectWebViewController* webViewViewController = [[RedirectWebViewController alloc] init];
    webViewViewController.redirectURL = redirectURL;
    [UIUtility dismissLoadingAlertView:YES];
    [self.navigationController pushViewController:webViewViewController animated:YES];
}


/*
 You can modify this according to your needs.
 This is sample implementation.
 */
+ (CTSBill*)getBillFromServer{
    // Configure your request here.
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
                                   [NSURL URLWithString:BillUrl]];
    [urlReq setHTTPMethod:@"POST"];
    NSError* error = nil;
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];
    NSString* billJson = [[NSString alloc] initWithData:signatureData
                                               encoding:NSUTF8StringEncoding];
    JSONModelError *jsonError;
    CTSBill* sampleBill = [[CTSBill alloc] initWithString:billJson
                                                    error:&jsonError];
    NSLog(@"billJson %@",billJson);
    NSLog(@"signature %@ ", sampleBill);
    return sampleBill;

}


@end
