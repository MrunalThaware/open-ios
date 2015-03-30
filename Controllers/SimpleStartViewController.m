//
//  SimpleStartViewController.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/11/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "SimpleStartViewController.h"
#import "TestParams.h"
#import "NSObject+logProperties.h"
#import "ServerSignature.h"
#import "UIUtility.h"
#import "WebViewViewController.h"

@interface SimpleStartViewController ()

@end

@implementation SimpleStartViewController
#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeLayers];
    self.title = @"Citrus iOS SDK";

    
   // [self linkUser];
   //[self signIn];
    //[self getPrepaidBill];
    //[self getCookie];
    //[self getbalance];
    
    //[self loadMoneyIntoCitrusAccount];
    
    [authLayer requestSignUpOauthToken];
//
    [proifleLayer requestGetNewProfileMobile:@"9920684710" email:@"shardullavekar@mailinator.com" WithCompletionHandler:^(CTSNewContactProfile *profile, NSError *error) {
        profile;
    }];
    
    

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


// Bind to the User.
-(IBAction)bindUser:(id)sender{
    // Configure your request here.
    [authLayer requestBindUsername:TEST_EMAIL mobile:TEST_MOBILE completionHandler:^(NSString *userName, NSError *error) {
        NSLog(@"error.code %ld ", (long)error.code);
        
        if(error == nil){
            // Your code to handle success.
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" %@ is now bound",userName]];
        }
        else {
            // Your code to handle error.
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't bind %@\nerror: %@",userName,[error localizedDescription]]];
        }
    }];
}

// Get the bind user cards.
-(IBAction)getSavedCards:(id)sender{
    // Configure your request here.
    [proifleLayer requestPaymentInformationWithCompletionHandler:^(CTSProfilePaymentRes *paymentInfo, NSError *error) {
        if (error == nil) {
            // Your code to handle success.
            NSMutableString *toastString = [[NSMutableString alloc] init];
            if([paymentInfo.paymentOptions count]){
                [toastString appendString:[self convertToString:[paymentInfo.paymentOptions objectAtIndex:0]]];
            }
            else{
                toastString =(NSMutableString *) @" no saved cards, please save card first";
            }
            [UIUtility toastMessageOnScreen:toastString];
        } else {
            // Your code to handle error.
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't find saved cards \nerror: %@",[error localizedDescription]]];
        }
    }];
}

// Save the cards.
-(IBAction)saveCards:(id)sender{
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Credit card info for card payment type.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    //creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    [paymentInfo addCard:creditCard];
    
    // Configure your request here.
    [proifleLayer updatePaymentInformation:paymentInfo withCompletionHandler:^(NSError *error) {
        if(error == nil){
            // Your code to handle success.
            [UIUtility toastMessageOnScreen:@" succesfully card saved "];
        }
        else {
            // Your code to handle error.
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't save card\n error: %@",toErrorDescription(error)]];
        }
    }];
}

// Tokenized card payment.
-(IBAction)tokenizedPayment:(id)sender{
    CTSPaymentDetailUpdate *tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for tokenized payment.
    CTSElectronicCardUpdate *tokenizedCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
     tokenizedCard.cvv= TEST_CREDIT_CARD_CVV;
     tokenizedCard.token= TEST_TOKENIZED_CARD_TOKEN;
    [tokenizedCardInfo addCard:tokenizedCard];
    
    // Get your bill here.
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    
    // Configure your request here.
    [paymentLayer requestChargeTokenizedPayment:tokenizedCardInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
}

// Card payment debit/credit
-(IBAction)cardPayment:(id)sender{
    CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for card payment.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    //creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    [creditCardInfo addCard:creditCard];
    
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];

    [paymentInfo addCard:creditCard];

    // Get your bill here.
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    
    // Configure your request here.
    [paymentLayer requestChargePayment:paymentInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
    

}


// Netbanking
-(IBAction)netbankingPayment:(id)sender{
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update bank details for net banking payment.
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    netBank.code = TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];
    
    // Get your bill here.
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    
    // Configure your request here.
    [paymentLayer requestChargePayment:paymentInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];
}


-(void)citrusPayPayment{
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    
    [paymentLayer requestChargeCitrusCashWithContact:contactInfo withAddress:addressInfo  bill:bill returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *paymentInfo, NSError *error) {
        NSLog(@"paymentInfo %@",paymentInfo);
        NSLog(@"error %@",error);
        //[self handlePaymentResponse:paymentInfo error:error];
        if(error){
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
    }];
}



-(void)linkUser{
    [authLayer requestLinkUser:TEST_EMAIL mobile:TEST_MOBILE completionHandler:^(CTSLinkUserRes *linkUserRes, NSError *error) {
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
         }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"User is now Linked, %@",linkUserRes.message]];
            
            if(!linkUserRes.isPasswordAlreadySet){
             [self setPassword];
            }

        }
    }];
}


-(void)setPassword{
    [authLayer requestSetPassword:TEST_PASSWORD userName:TEST_EMAIL completionHandler:^(NSError *error) {
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Password is now set"]];
        }
    }];
}





-(void)getCookie{
[authLayer requestCitrusPaySignin:TEST_EMAIL password:TEST_PASSWORD completionHandler:^(NSError *error) {
    LogTrace(@" error %@ ",error);
}];


}

-(void)signIn{
    [authLayer requestSigninWithUsername:TEST_EMAIL password:TEST_PASSWORD completionHandler:^(NSString *userName, NSString *token, NSError *error) {
        LogTrace(@"userName %@",userName);
        LogTrace(@"error %@",error);
        
    }];
  
}


-(void)loadMoneyIntoCitrusAccount{

    CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update card for card payment.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    //creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    [creditCardInfo addCard:creditCard];
    

    [paymentLayer requestLoadMoneyInCitrusPay:creditCardInfo withContact:contactInfo withAddress:addressInfo amount:@"1" returnUrl:ReturnUrl withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];

}



- (void)loadRedirectUrl:(NSString*)redirectURL {
    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
    webViewViewController.redirectURL = redirectURL;
    [UIUtility dismissLoadingAlertView:YES];
    [self.navigationController pushViewController:webViewViewController animated:YES];
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



-(NSString *)convertToString:(CTSPaymentOption *)option{
    
    NSMutableString *msgString = [[NSMutableString alloc] init];
    
    if(option.name){
        [msgString appendFormat:@"\n  name: %@",option.name];
    }
    if(option.owner){
        [msgString appendFormat:@"\n  owner: %@",option.owner];
    }
    if(option.bank){
        [msgString appendFormat:@"\n  bank: %@",option.bank];
    }
    if(option.number){
        [msgString appendFormat:@"\n  number: %@",option.number];
    }
    if(option.expiryDate){
        [msgString appendFormat:@"\n  expiryDate: %@",option.expiryDate];
    }
    if(option.scheme){
        [msgString appendFormat:@"\n  scheme: %@",option.scheme];
    }
    if(option.token){
        [msgString appendFormat:@"\n  token: %@",option.token];
    }
    if(option.mmid){
        [msgString appendFormat:@"\n  mmid: %@",option.mmid];
    }
    if(option.impsRegisteredMobile){
        [msgString appendFormat:@"\n  impsRegisteredMobile: %@",option.impsRegisteredMobile];
    }
    if(option.code){
        [msgString appendFormat:@"\n  code: %@",option.code];
    }
    
    return msgString;
    
}


-(void)getbalance{

    [proifleLayer requetGetBalance:^(CTSAmount *amount, NSError *error) {
        LogTrace(@" value %@ ",amount.value);
        LogTrace(@" currency %@ ",amount.currency);

    }];
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
