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
#define SANDBOX_SERVER @"https://sandboxadmin.citruspay.com"
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initializeLayers{
    authLayer = [[CTSAuthLayer alloc] init];
    proifleLayer = [[CTSProfileLayer alloc] init];
    paymentLayer = [[CTSPaymentLayer alloc] initWithUrl:SANDBOX_SERVER];
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


-(IBAction)bindUser:(id)sender{
    [authLayer requestBindUsername:TEST_EMAIL mobile:TEST_MOBILE completionHandler:^(NSString *userName, NSError *error) {
        if(error == nil){
            //your code to handle success
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" %@ is bound",userName] ];
        }
        else {
            //your code to handle error
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't bind %@\nerror: %@",userName,[error description]]];
        }
    }];
    
}

-(IBAction)getSavedCards:(id)sender{
    [proifleLayer requestPaymentInformationWithCompletionHandler:^(CTSProfilePaymentRes *paymentInfo, NSError *error) {
        if (error == nil) {
            NSMutableString *toastString = nil;
            if([paymentInfo.paymentOptions count]){

                for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
                    [toastString appendString:@"\n\noption:"];
                    [toastString appendString:[self convertToString:option]];
                }
            }
            else{
                toastString =(NSMutableString *) @" no saved cards ";
            }
            [UIUtility toastMessageOnScreen:toastString];
        } else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't find saved cards \nerror: %@",[error description]]];
        }
    }];
}

-(IBAction)saveCards:(id)sender{
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* creditCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
    [paymentInfo addCard:creditCard];
    paymentInfo.defaultOption = TEST_CREDIT_CARD_BANK_NAME;
    
    [paymentInfo addCard:creditCard];
    
    [proifleLayer updatePaymentInformation:paymentInfo withCompletionHandler:^(NSError *error) {
        if(error == nil){
            //your code to handle success
            [UIUtility toastMessageOnScreen:@" succesfully card saved "];
        }
        else {
            //your code to handle error
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't save card\n error: %@",toErrorDescription(error)]];
        }
    }];

}


-(IBAction)payWithSavedCard:(id)sender{

    CTSPaymentDetailUpdate* tokenizedCardInfo =
    [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* tokenizedCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
    tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
    [tokenizedCardInfo addCard:tokenizedCard];
 
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    [paymentLayer requestChargeTokenizedPayment:tokenizedCardInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        [self handlePaymentResponse:paymentInfo error:error];
    }];

}


-(IBAction)payAsGuestCard:(id)sender{

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
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    [paymentLayer requestChargePayment:creditCardInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
       
        [self handlePaymentResponse:paymentInfo error:error];
    }];



}



-(IBAction)payAsGuestBank:(id)sender{
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    
    netBank.code = TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    [paymentLayer requestChargePayment:paymentInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
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
        //your code to handle success

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
        //your code to handle error
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

//you can modify this according to your needs
//this is sample implementation
+ (CTSBill*)getBillFromServer{
    
    NSURL* url = [[NSURL alloc]
                  initWithString:
                  [NSString
                   stringWithFormat:BillUrl]];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
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
    NSLog(@"signature %@ ", sampleBill);
    return sampleBill;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
