//
//  SimpleStartViewController.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/11/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "SimpleStartViewController.h"
#import "TestParams.h"
#import "UIUtility.h"

@interface SimpleStartViewController ()

@end

@implementation SimpleStartViewController
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

    customParams = nil;
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
    creditCard.number = @"5105105105105100";
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
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
     tokenizedCard.token= @"5115669e6129247a1e7a3599ea58e947";
    [tokenizedCardInfo addCard:tokenizedCard];
    //
    // Get your bill here.
    CTSBill *bill = [SimpleStartViewController getBillFromServer];

    [paymentLayer requestChargeTokenizedPayment:tokenizedCardInfo withContact:contactInfo withAddress:addressInfo bill:bill customParams:customParams returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:error.localizedDescription];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Payment Status %@",[citrusCashResponse.responseDict valueForKey:@"TxStatus"] ]];
        }
    }];
    
}

// Card payment debit/credit
-(IBAction)cardPayment:(id)sender{
    // Update card for card payment.
    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    [paymentInfo addCard:creditCard];

    // Get your bill here.
    CTSBill *bill = [SimpleStartViewController getBillFromServer];

    
    [paymentLayer requestChargePayment:paymentInfo withContact:contactInfo withAddress:addressInfo bill:bill customParams:@"" returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:error.localizedDescription];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Payment Status %@",[citrusCashResponse.responseDict valueForKey:@"TxStatus"] ]];
        }
    }];
}


// Netbanking
-(IBAction)netbankingPayment:(id)sender{
    CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    // Update bank details for net banking payment.
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    netBank.code = @"CID002";
    [paymentInfo addNetBanking:netBank];
    
    // Get your bill here.
    CTSBill *bill = [SimpleStartViewController getBillFromServer];
    
    [paymentLayer requestChargePayment:paymentInfo withContact:contactInfo withAddress:addressInfo bill:bill customParams:customParams returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
        if(error){
            [UIUtility toastMessageOnScreen:error.localizedDescription];
        }
        else {
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Payment Status %@",[citrusCashResponse.responseDict valueForKey:@"TxStatus"] ]];
        }
    }];
}


// String parser
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
    
//    
//    sampleBill.amount = [[CTSAmount alloc] init];
//    sampleBill.amount.value = @"1";
//    sampleBill.amount.value = @"INR";
//    sampleBill.requestSignature = @"b0a169132e022a6b46b24374483fe5b8d3869b24";
//    sampleBill.merchantAccessKey = @"GN5LNPT86TK4HVCZFENP";
//    sampleBill.merchantTxnId = @"SG213649122";
//    sampleBill.returnUrl = @"http://app-tech.tinyowl.com/restaurant/payment/online/response";
//    sampleBill.notifyUrl = @"www.google.com";
    
    

    
    
    LogTrace(@"billJson %@",billJson);
    LogTrace(@"signature %@ ", sampleBill);
    return sampleBill;
}

@end
