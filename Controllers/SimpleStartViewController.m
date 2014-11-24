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
@interface SimpleStartViewController ()

@end

@implementation SimpleStartViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeLayers];
    [ServerSignature getSampleBill];
    //[self bindTest];
    //[self getSavedCards];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)bindTest{
    [authLayer requestBindUsername:TEST_EMAIL mobile:TEST_MOBILE completionHandler:^(NSString *userName, NSError *error) {
        if(error == nil){
            [self toastMessageOnScreen:[NSString stringWithFormat:@" %@ is bound",userName] ];
        }
        else {
            [self toastMessageOnScreen:[NSString stringWithFormat:@" couldn't bind %@\nerror: %@",userName,[error description]]];
        }
    }];
}

-(void)getSavedCards{
    
    [proifleLayer requestPaymentInformationWithCompletionHandler:^(CTSProfilePaymentRes *paymentInfo, NSError *error) {

            if (error == nil) {
                NSMutableString *toastString = nil;
                if([paymentInfo.paymentOptions count]){
                    
                    
                    NSMutableString *toastString = [NSMutableString stringWithFormat:@"paymentInfo.type %@", paymentInfo.type];
                    [toastString appendFormat:@"\npaymentInfo.defaultOption %@", paymentInfo.defaultOption];
                    
                    
                    for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
                        [toastString appendString:@"\n\noption:"];
                        [toastString appendString:[self convertToString:option]];
                    }
                }
                else{
                    toastString =(NSMutableString *) @" no saved cards ";
                }
                [self toastMessageOnScreen:toastString];
                // paymentSavedResponse = paymentInfo;
            } else {
                [self toastMessageOnScreen:[NSString stringWithFormat:@" couldn't find saved cards \nerror: %@",[error description]]];
            }
    }];
}

-(IBAction)bindUser:(id)sender{
    [authLayer requestBindUsername:TEST_EMAIL mobile:TEST_MOBILE completionHandler:^(NSString *userName, NSError *error) {
        if(error == nil){
            [self toastMessageOnScreen:[NSString stringWithFormat:@" %@ is bound",userName] ];
        }
        else {
            [self toastMessageOnScreen:[NSString stringWithFormat:@" couldn't bind %@\nerror: %@",userName,[error description]]];
        }
    }];
    
}

-(IBAction)getSavedCards:(id)sender{
    [proifleLayer requestPaymentInformationWithCompletionHandler:^(CTSProfilePaymentRes *paymentInfo, NSError *error) {
        
        if (error == nil) {
            NSMutableString *toastString = nil;
            if([paymentInfo.paymentOptions count]){
                
                
                toastString = [NSMutableString stringWithFormat:@"paymentInfo.type %@", paymentInfo.type];
                [toastString appendFormat:@"\npaymentInfo.defaultOption %@", paymentInfo.defaultOption];
                
                
                for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
                    [toastString appendString:@"\n\noption:"];
                    [toastString appendString:[self convertToString:option]];
                }
            }
            else{
                toastString =(NSMutableString *) @" no saved cards ";
            }
            [self toastMessageOnScreen:toastString];
            // paymentSavedResponse = paymentInfo;
        } else {
            [self toastMessageOnScreen:[NSString stringWithFormat:@" couldn't find saved cards \nerror: %@",[error description]]];
        }
    }];

    
}
#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]

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
            [self toastMessageOnScreen:@" succesfully card saved "];
        }
        else {
            [self toastMessageOnScreen:[NSString stringWithFormat:@" couldn't save card\n error: %@",toErrorDescription(error)]];
        }
    }];

}


-(IBAction)payWithSavedCard:(id)sender{

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
    
    NSString* transactionId;
    
    // transactionId = [self createTXNId];
    NSLog(@"transactionId:%@", transactionId);

    
    CTSBill *bill = [ServerSignature getSampleBill];
    
    [paymentLayer makePaymentUsingGuestFlow:creditCardInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        if(error == nil){
            
        }
        else{
            
            
        }
    }];



}

-(IBAction)payAsGuestBank:(id)sender{
    
    
    
}


-(void)toastMessageOnScreen:(NSString *)string{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                        message:string
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        [toast show];
        
        int duration = 5; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        
    });
    
    
    
    
}


-(NSString *)convertToString:(CTSPaymentOption *)option{
    
    NSMutableString *msgString = [[NSMutableString alloc] init];
    
    if(option.name){
        [msgString appendFormat:@"\n  name %@",option.name];
    }
    if(option.owner){
        [msgString appendFormat:@"\n  owner %@",option.owner];
    }
    if(option.bank){
        [msgString appendFormat:@"\n  bank %@",option.bank];
    }
    if(option.number){
        [msgString appendFormat:@"\n  number %@",option.number];
    }
    if(option.expiryDate){
        [msgString appendFormat:@"\n  expiryDate %@",option.expiryDate];
    }
    if(option.scheme){
        [msgString appendFormat:@"\n  scheme %@",option.scheme];
    }
    if(option.token){
        [msgString appendFormat:@"\n  token %@",option.token];
    }
    if(option.mmid){
        [msgString appendFormat:@"\n  mmid %@",option.mmid];
    }
    if(option.impsRegisteredMobile){
        [msgString appendFormat:@"\n  impsRegisteredMobile %@",option.impsRegisteredMobile];
    }
    if(option.code){
        [msgString appendFormat:@"\n  code %@",option.code];
    }
    
    return msgString;
    
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
