//
//  PrepaidViewController.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 11/03/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "PrepaidViewControllerOld2.h"
#import "TestParams.h"
#import "NSObject+logProperties.h"
#import "ServerSignature.h"
#import "UIUtility.h"
#import "WebViewViewController.h"

@interface PrepaidViewControllerOld2 ()

@end

@implementation PrepaidViewControllerOld2
#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]

#pragma mark - initializers
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeLayers];
    self.title = @"Citrus iOS SDK";
//    [authLayer requestCitrusPaySignin:TEST_EMAIL password:TEST_PASSWORD completionHandler:^(NSError *error) {
//        LogTrace(@" requestCitrusPaySignin ");
//        LogTrace(@"%@", error);
//    }];

    //[PrepaidViewController getBillFromServer];
    
    // [self linkUser];
    //[self signIn];
    //[self getPrepaidBill];
    //[self getCookie];
    //[self getbalance];
    //[authLayer signOut];
    //[self loadMoneyIntoCitrusAccount];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - button handlers

-(IBAction)isUserSignedIn:(id)sender{
    if([authLayer isAnyoneSignedIn]){
                [UIUtility toastMessageOnScreen:@"user is signed in"];
    
    }
    else{
     [UIUtility toastMessageOnScreen:@"no one is logged in"];
    }
}

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


-(void)saveCashoutBankAccount{
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



-(void)fetchCashoutBankAccount{
    [proifleLayer requestCashoutBankAccountCompletionHandler:^(CTSCashoutBankAccountResp *bankAccount, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else {
            
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"%@\n number: %@\n ifsc: %@",bankAccount.cashoutAccount.owner,bankAccount.cashoutAccount.number,bankAccount.cashoutAccount.branch]];
            
        }
    }];
}


-(void)cashOutToBank{
    
    CTSCashoutBankAccount *bankAccount = [[CTSCashoutBankAccount alloc] init];
    bankAccount.owner = @"Yadnesh Wankhede";
    bankAccount.branch = @"HSBC0000123";
    bankAccount.number = @"123456789987654";
    [paymentLayer requestCashoutToBank:bankAccount amount:@"5" completionHandler:^(CTSCashoutToBankRes *cashoutRes, NSError *error) {
        [cashoutRes logProperties];
        [error logProperties];
    }];
}

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


-(IBAction)loadUsingCard:(id)sender{
    
    CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for card payment.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initDebitCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    
    
    
    [creditCardInfo addCard:creditCard];

    [paymentLayer requestLoadMoneyInCitrusPay:creditCardInfo withContact:contactInfo withAddress:addressInfo amount:@"1" returnUrl:ReturnUrl customParams:nil withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
    

}





-(IBAction)loadUsingCardToken:(id)sender{

    CTSPaymentDetailUpdate *tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for tokenized payment.
    CTSElectronicCardUpdate *tokenizedCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    tokenizedCard.cvv= TEST_CREDIT_CARD_CVV;
    tokenizedCard.token= TEST_TOKENIZED_CARD_TOKEN;
    [tokenizedCardInfo addCard:tokenizedCard];
    
    
    [paymentLayer requestLoadMoneyInCitrusPay:tokenizedCardInfo withContact:contactInfo withAddress:addressInfo amount:@"1" returnUrl:ReturnUrl customParams:nil withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
    

}

-(IBAction)loadUsingNetbank:(id)sender{

    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update bank details for net banking payment.
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    netBank.code = @"CID002";TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];
    
    [paymentLayer requestLoadMoneyInCitrusPay:paymentInfo withContact:contactInfo withAddress:addressInfo amount:@"10" returnUrl:ReturnUrl customParams:nil withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
    

}

-(IBAction)payUsingCitrusCash:(id)sender{
    
    CTSBill *bill = [PrepaidViewControllerOld2 getBillFromServer];
    [paymentLayer requestChargeCitrusCashWithContact:contactInfo withAddress:addressInfo  bill:bill customParams:nil returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *paymentInfo, NSError *error) {
        LogTrace(@"paymentInfo %@",paymentInfo);
        LogTrace(@"error %@",error);
        //[self handlePaymentResponse:paymentInfo error:error];
        if(error){
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }     
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[paymentInfo.responseDict valueForKey:@"TxStatus"] ]];
        
        }
    }];
}

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
#pragma mark - Payment Helpers
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
    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
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
    LogTrace(@"billJson %@",billJson);
    LogTrace(@"signature %@ ", sampleBill);
    return sampleBill;

}

//
//+ (CTSBill*)getBillFromServer{
//    // Configure your request here.
//    
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    
//    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"INR", @"currency", @"1", @"value", nil];
//    
//    [dict setObject:dict1 forKey:@"amount"];
//    [dict setObject:@"56OXQYRPH5WVR7YATIQD" forKey:@"merchantAccessKey"];
//    [dict setObject:@"142710952686155" forKey:@"merchantTxnId"];
//    [dict setObject:@"04aca6dec7450fddeae53e117dcf6430de5e499f" forKey:@"requestSignature"];
//    [dict setObject:@"https://demo.faasos.com/onlinepay.aspx" forKey:@"returnUrl"];
//    
//    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
//                                   [NSURL URLWithString:BillUrl]];
//    [urlReq setHTTPMethod:@"POST"];
//    [urlReq addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//    [urlReq setHTTPBody:[NSJSONSerialization dataWithJSONObject: @{@"amount": @"1"} options:NSJSONWritingPrettyPrinted error:nil]];
//    NSError* error = nil;
//    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
//                                                  returningResponse:nil
//                                                              error:&error];
//    NSString* billJson = [[NSString alloc] initWithData:signatureData
//                                               encoding:NSUTF8StringEncoding];
//    JSONModelError *jsonError;
//    CTSBill* sampleBill2 = [[CTSBill alloc] initWithDictionary:dict error:&jsonError];
//    CTSBill *sampleBill = [[CTSBill alloc] initWithString:billJson error:&jsonError];
//    
//    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:signatureData options:NSJSONWritingPrettyPrinted error:nil];
//    NSDictionary *billDict = [res objectForKey:@"data"];
//    
//    
//    [dict setObject:[billDict objectForKey:@"amount"] forKey:@"amount"];
//    [dict setObject:[billDict objectForKey:@"merchantAccessKey"] forKey:@"merchantAccessKey"];
//    [dict setObject:[billDict objectForKey:@"merchantTxnId"] forKey:@"merchantTxnId"];
//    [dict setObject:[billDict objectForKey:@"requestSignature"] forKey:@"requestSignature"];
//    [dict setObject:[billDict objectForKey:@"returnUrl"] forKey:@"returnUrl"];
//    
//     sampleBill2 = [[CTSBill alloc] initWithDictionary:dict error:&jsonError];
//
//    
//    
//    LogTrace(@"billJson %@",billJson);
//    LogTrace(@"signature %@ ", sampleBill);
//    LogTrace(@"signature %@ ", sampleBill2);
//   return sampleBill2;
//    //return sampleBill;
//
//}

@end
