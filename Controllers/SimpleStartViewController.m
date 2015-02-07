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
    //[self testCookie];
    self.title = @"iOS Native SDKs kit Demo";
   // [self loadRedirectUrl:@"http://192.168.2.34:8888/return.php"];
    
    [self loadRedirectUrl:@"http://192.168.2.34:8080/JSPTest/NewFile.jsp"];

    
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
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't bind %@\nerror: %@",userName,[error description]]];
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
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" couldn't find saved cards \nerror: %@",[error description]]];
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
    creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
    [paymentInfo addCard:creditCard];
    paymentInfo.defaultOption = TEST_CREDIT_CARD_BANK_NAME;
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
    tokenizedCard.token = TEST_TOKENIZED_CARD_TOKEN;
    tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
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
//    CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
//    // Update card for card payment.
//    CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
//    creditCard.number = TEST_CREDIT_CARD_NUMBER;
//    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
//    creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
//    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
//    creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
//    creditCard.cvv = TEST_CREDIT_CARD_CVV;
//    [creditCardInfo addCard:creditCard];
//    
//    // Get your bill here.
//    CTSBill *bill = [SimpleStartViewController getBillFromServer];
//    
//    // Configure your request here.
//    [paymentLayer requestChargePayment:creditCardInfo withContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
//        [self handlePaymentResponse:paymentInfo error:error];
//    }];
    
    
    CTSBill *bill = [SimpleStartViewController getBillFromServer];

    [paymentLayer requestChargeCitrusCashWithContact:contactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        NSLog(@"paymentInfo %@",paymentInfo);
        NSLog(@"error %@",error);
        //[self handlePaymentResponse:paymentInfo error:error];

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
    NSLog(@"signature %@ ", sampleBill);
    return sampleBill;
}







//sandbox
#define EMAIL @"raji.nair@citruspay.com"
#define PASSWORD @"tester@123"


//#define EMAIL @"foo@bar.com"
//#define PASSWORD @"fubar"


//staging
//#define EMAIL @"monish.correia@citruspay.com"
//#define PASSWORD @"tester@123"

-(void)testCookie{
    
    [authLayer requestCitrusPaySignin:EMAIL password:PASSWORD completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@" error %@  ",error);
        
        }
        else {
        
            NSLog(@"signin Succesfull");
        }
    }];
//
    
    
    
    
    
    
//    
//    NSMutableURLRequest *originalRequest =
//    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseUrl, @"/prepaid/pg/_verify"]]
//                            cachePolicy:NSURLRequestUseProtocolCachePolicy
//                        timeoutInterval:30.0];
//    
//    [originalRequest setHTTPMethod:@"POST"];
//    
//    [originalRequest setHTTPBody:[[CTSRestCore serializeParams:@{@"email":EMAIL,@"password":PASSWORD,@"rmcookie":@"true"}]
//                                  dataUsingEncoding:NSUTF8StringEncoding]];
//    //[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    
//    //
//    //        [request.headers setObject:@"application/json" forKey:@"Content-Type"];
//    //
//    //
//    //    request = [self requestByAddingHeaders:request headers:restRequest.headers];
//    //    return request;
//    
//    
//    
//    
//    NSOperationQueue* mainQueue = [[NSOperationQueue alloc] init];
//    [mainQueue setMaxConcurrentOperationCount:5];
//    
//    
//    LogTrace(@"URL > %@ ", originalRequest);
//    LogTrace(@"URL data> %@ ", [[NSString alloc] initWithData:[originalRequest HTTPBody] encoding:NSUTF8StringEncoding]);
//    
//    
//    // LogTrace(@"allHeaderFields %@", [request allHeaderFields]);
//    
//    
//    NSURLConnection *urlConn = [[NSURLConnection alloc] initWithRequest:originalRequest delegate:self];
//    [urlConn start];
//    
//    
//    //    [NSURLConnection
//    //     sendAsynchronousRequest:request
//    //     queue:mainQueue
//    //     completionHandler:^(NSURLResponse* response,
//    //                         NSData* data,
//    //                         NSError* connectionError) {
//    //         NSLog(@"response %@",response);
//    //         NSLog(@"data %@",response);
//    //         NSLog(@"connectionError %@",connectionError);
//    //
//    //     }];
    
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) redirectResponse
{
    
    NSLog(@"connection %@",connection);
    
    NSLog(@"redirect request %@",request);
    NSLog(@"redirect redirectResponse %@",redirectResponse);
    LogTrace(@"URL data> %@ ", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    
    NSURLResponse* response = redirectResponse;// the response, from somewhere
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString *cookie = [SimpleStartViewController proccessAndsaveAuthCookieFromHeader:headers];
    
    if(cookie != nil ){
        NSLog(@" cookie saved ");
        NSArray* httpscookies =
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseUrl, @"/prepaid/pg/_verify"]]];
        
        NSHTTPCookie* cookie = [httpscookies objectAtIndex:1];
        NSLog(@"coockies array %@",cookie);
        [SimpleStartViewController setAuthCookie:cookie];
        
    }
    NSLog(@" headers %@ ",headers);
    NSLog(@"  setCookie %@ ",[headers valueForKey:@"Set-Cookie"]);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) redirectResponse;

    if (httpResponse.statusCode == 302 ) {
        request = nil;
    }
    
    return request;
}



#define AUTH_COOKIE_KEY @"AuthenticationCookie"

//what to store in cookie
//what to store in

#define SandBox @"sandbox.citruspay.com"
+(void )setAuthCookie:(NSHTTPCookie *)cookie{
//    
//    NSMutableDictionary* cookieProperties = [NSMutableDictionary dictionary];
//    [cookieProperties setObject:[cookie name] forKey:NSHTTPCookieName];
//    [cookieProperties setObject:[cookie value] forKey:NSHTTPCookieValue];
//    [cookieProperties setObject:SandBox
//                         forKey:NSHTTPCookieDomain];  // Without http://
//    [cookieProperties setObject:SandBox
//                         forKey:NSHTTPCookieOriginURL];  // Without http://
//    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
//    
//    [cookieProperties
//     setObject:[[NSDate date] dateByAddingTimeInterval:2629743]
//     forKey:NSHTTPCookieExpires];
//    
//    NSHTTPCookie *cookie1 = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    
    
}

+(NSString *)proccessAndsaveAuthCookieFromHeader:(NSDictionary *)headers{
    NSString *setCookieString = nil;
    setCookieString = [headers valueForKey:@"Set-Cookie"];
    if(setCookieString){
        [CTSUtility saveToDisk:setCookieString as:AUTH_COOKIE_KEY];
    }
    
    

    
    return setCookieString;
}


- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response{
    
    NSLog(@"didReceiveResponse response %@",response);
    
    
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@" didReceiveData ");
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSLog(@" did finish loading connection %@",connection);
    
}

-(void)connection:(NSURLConnection *)connection didFailLoadingWithError:(NSError *)error{
    
    NSLog(@" did error loading connection %@",connection);
    
    NSLog(@" error %@ ",error);
}


@end
