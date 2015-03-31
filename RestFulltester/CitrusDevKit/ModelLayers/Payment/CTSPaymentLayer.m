//
//  CTSPaymentLayer.m
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//
#import "CTSPaymentDetailUpdate.h"
#import "CTSContactUpdate.h"
#import "CTSPaymentLayer.h"
#import "CTSPaymentMode.h"
#import "CTSPaymentRequest.h"
#import "CTSAmount.h"
#import "CTSPaymentToken.h"
#import "CTSPaymentMode.h"
#import "CTSUserDetails.h"
#import "CTSUserAddress.h"
#import "CTSPaymentTransactionRes.h"
#import "CTSGuestCheckout.h"
#import "CTSPaymentNetbankingRequest.h"
#import "CTSTokenizedCardPayment.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSProfileLayer.h"
#import "CTSAuthLayer.h"
#import "CTSRestCoreRequest.h"
#import "CTSUtility.h"
#import "CTSOauthManager.h"
#import "CTSTokenizedPaymentToken.h"
#import "NSObject+logProperties.h"
#import "MerchantConstants.h"
#import "CTSUserAddress.h"
//#import "WebViewViewController.h"
//#import "UIUtility.h"
@interface CTSPaymentLayer ()
@end

@implementation CTSPaymentLayer
@synthesize merchantTxnId;
@synthesize signature;
@synthesize delegate;

- (CTSPaymentRequest*)configureReqPayment:(CTSPaymentDetailUpdate*)paymentInfo
                                  contact:(CTSContactUpdate*)contact
                                  address:(CTSUserAddress*)address
                                   amount:(NSString*)amount
                                returnUrl:(NSString*)returnUrl
                                signature:(NSString*)signatureArg
                                    txnId:(NSString*)txnId
                           merchantAccess:(NSString *)merchantAccessKey
{
  CTSPaymentRequest* paymentRequest = [[CTSPaymentRequest alloc] init];

  paymentRequest.amount = [self ctsAmountForAmount:amount];
  paymentRequest.merchantAccessKey = merchantAccessKey;
  paymentRequest.merchantTxnId = txnId;
  paymentRequest.notifyUrl = @"";
  paymentRequest.requestSignature = signatureArg;
  paymentRequest.returnUrl = returnUrl;
  paymentRequest.paymentToken =
      [[paymentInfo.paymentOptions objectAtIndex:0] fetchPaymentToken];

  paymentRequest.userDetails =
      [[CTSUserDetails alloc] initWith:contact address:address];

  return paymentRequest;
}

- (CTSAmount*)ctsAmountForAmount:(NSString*)amount {
  CTSAmount* ctsAmount = [[CTSAmount alloc] init];
  ctsAmount.value = amount;
  ctsAmount.currency = CURRENCY_INR;
  return ctsAmount;
}

//- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
//              withContact:(CTSContactUpdate*)contactInfo
//              withAddress:(CTSUserAddress*)userAddress
//                   amount:(NSString*)amount
//            withReturnUrl:(NSString*)returnUrl
//            withSignature:(NSString*)signatureArg
//                withTxnId:(NSString*)merchantTxnIdArg
//    withCompletionHandler:(ASMakeUserPaymentCallBack)callback {
//  [self addCallback:callback forRequestId:PaymentUsingSignedInCardBankReqId];
//
//  CTSPaymentRequest* paymentrequest =
//      [self configureReqPayment:paymentInfo
//                        contact:contactInfo
//                        address:userAddress
//                         amount:amount
//                      returnUrl:returnUrl
//                      signature:signatureArg
//                          txnId:merchantTxnIdArg];
//
//  CTSErrorCode error = [paymentInfo validate];
//
//  LogTrace(@"validation error %d ", error);
//
//  if (error != NoError) {
//    [self makeUserPaymentHelper:nil error:[CTSError getErrorForCode:error]];
//    return;
//  }
//
//  long index = [self addDataToCacheAtAutoIndex:paymentInfo];
//
//  CTSRestCoreRequest* request =
//      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
//                                     requestId:PaymentUsingSignedInCardBankReqId
//                                       headers:nil
//                                    parameters:nil
//                                          json:[paymentrequest toJSONString]
//                                    httpMethod:POST
//                                     dataIndex:index];
//
//  [restCore requestAsyncServer:request];
//}

//- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
//                 withContact:(CTSContactUpdate*)contactInfo
//                 withAddress:(CTSUserAddress*)userAddress
//                      amount:(NSString*)amount
//               withReturnUrl:(NSString*)returnUrl
//               withSignature:(NSString*)signatureArg
//                   withTxnId:(NSString*)merchantTxnIdArg
//       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback {
//  [self addCallback:callback forRequestId:PaymentUsingtokenizedCardBankReqId];
//
//  CTSPaymentRequest* paymentrequest =
//      [self configureReqPayment:paymentInfo
//                        contact:contactInfo
//                        address:userAddress
//                         amount:amount
//                      returnUrl:returnUrl
//                      signature:signatureArg
//                          txnId:merchantTxnIdArg];
//
//  CTSErrorCode error = [paymentInfo validateTokenized];
//  LogTrace(@" validation error %d ", error);
//
//  if (error != NoError) {
//    [self makeTokenizedPaymentHelper:nil
//                               error:[CTSError getErrorForCode:error]];
//    return;
//  }
//
//  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
//      initWithPath:MLC_CITRUS_SERVER_URL
//         requestId:PaymentUsingtokenizedCardBankReqId
//           headers:nil
//        parameters:nil
//              json:[paymentrequest toJSONString]
//        httpMethod:POST];
//  [restCore requestAsyncServer:request];
//}
//

- (void)requestChargeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                        bill:(CTSBill *)bill
       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback{

    [self addCallback:callback forRequestId:PaymentUsingtokenizedCardBankReqId];
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentInfo
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
     merchantAccess:bill.merchantAccessKey];
    
    CTSErrorCode error = [paymentInfo validateTokenized];
    LogTrace(@" validation error %d ", error);
    
    if (error != NoError) {
        [self makeTokenizedPaymentHelper:nil
                                   error:[CTSError getErrorForCode:error]];
        return;
    }
    if(![CTSUtility validateBill:bill]){
        [self makeTokenizedPaymentHelper:nil
                               error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_CITRUS_SERVER_URL
                                   requestId:PaymentUsingtokenizedCardBankReqId
                                   headers:nil
                                   parameters:nil
                                   json:[paymentrequest toJSONString]
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];


}


//- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
//                      withContact:(CTSContactUpdate*)contactInfo
//                           amount:(NSString*)amount
//                      withAddress:(CTSUserAddress*)userAddress
//                    withReturnUrl:(NSString*)returnUrl
//                    withSignature:(NSString*)signatureArg
//                        withTxnId:(NSString*)merchantTxnIdArg
//            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback {
//  [self addCallback:callback forRequestId:PaymentAsGuestReqId];
//
//  CTSErrorCode error = [paymentInfo validate];
//  LogTrace(@"validation error %d ", error);
//
//  if (error != NoError) {
//    [self makeGuestPaymentHelper:nil
//                               error:[CTSError getErrorForCode:error]];
//    return;
//  }
//  CTSAuthLayer* authLayer = [[CTSAuthLayer alloc] init];
//  __block CTSPaymentDetailUpdate* _paymentDetailUpdate = paymentInfo;
//  __block NSString* email = contactInfo.email;
//  __block NSString* mobile = contactInfo.mobile;
//  __block NSString* password = contactInfo.password;
//  dispatch_queue_t backgroundQueue =
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//
//  dispatch_async(backgroundQueue, ^(void) {
//      [authLayer
//          requestSignUpWithEmail:email
//                          mobile:mobile
//                        password:password
//               completionHandler:^(NSString* userName,
//                                   NSString* token,
//                                   NSError* error) {
//                   if (error == nil) {
//                     dispatch_queue_t backgroundQueueBlock =
//                         dispatch_get_global_queue(
//                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//
//                     dispatch_async(backgroundQueueBlock, ^(void) {
//                         CTSProfileLayer* profileLayer =
//                             [[CTSProfileLayer alloc] init];
//                         [profileLayer
//                             updatePaymentInformation:_paymentDetailUpdate
//                                withCompletionHandler:nil];
//                         _paymentDetailUpdate = nil;
//                     });
//                   }
//               }];
//  });
//
//  CTSPaymentRequest* paymentrequest =
//      [self configureReqPayment:paymentInfo
//                        contact:contactInfo
//                        address:userAddress
//                         amount:amount
//                      returnUrl:returnUrl
//                      signature:signatureArg
//                          txnId:merchantTxnIdArg];
//
//  CTSRestCoreRequest* request =
//      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
//                                     requestId:PaymentAsGuestReqId
//                                       headers:nil
//                                    parameters:nil
//                                          json:[paymentrequest toJSONString]
//                                    httpMethod:POST];
//  [restCore requestAsyncServer:request];
//}

- (void)requestChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                      withAddress:(CTSUserAddress*)userAddress
                             bill:(CTSBill *)bill
            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback{

    [self addCallback:callback forRequestId:PaymentAsGuestReqId];
    
    CTSErrorCode error = [paymentInfo validate];
    LogTrace(@"validation error %d ", error);
    
    if (error != NoError) {
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
        return;
    }
    if(![CTSUtility validateBill:bill]){
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentInfo
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
                  merchantAccess:bill.merchantAccessKey];
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                   requestId:PaymentAsGuestReqId
                                     headers:nil
                                  parameters:nil
                                        json:[paymentrequest toJSONString]
                                  httpMethod:POST];
    [restCore requestAsyncServer:request];



}



- (void)requestChargeCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                               withAddress:(CTSUserAddress*)userAddress
                                      bill:(CTSBill *)bill
                      returnViewController:(UIViewController *)controller
                     withCompletionHandler:(ASCitruspayCallback)callback{
    
    [self addCallback:callback forRequestId:PaymentAsCitruspayReqId];
    
    //vallidate
    //check if signed in if no then return error accordigly(from handler)
    //save controller
    //save callback
    //when the reply comesback
    //redirect it on web controller
    //from webcontroller keep detecting if verifypage has come if yes then reutrn for signin error
    //when webview controller returns with proper callback from ios get the reply back
    if(![CTSUtility validateBill:bill]){
        [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:WrongBill]];
        return;
    
    }
    if(controller == nil){
        [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
    
    }
    
    
    citrusCashBackViewController = controller;
    
    

    [self requestChargeInternalCitrusCashWithContact:contactInfo withAddress:userAddress bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        NSLog(@"paymentInfo %@",paymentInfo);
        NSLog(@"error %@",error);
        [self handlePaymentResponse:paymentInfo error:error] ;
    }];

    
    
}


- (void)requestChargeInternalCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                               withAddress:(CTSUserAddress*)userAddress
                                      bill:(CTSBill *)bill
                     withCompletionHandler:(ASMakeCitruspayCallBackInternal)callback{
    [self addCallback:callback forRequestId:PaymentAsCitruspayInternalReqId];


    CTSPaymentDetailUpdate *paymentCitrus = [[CTSPaymentDetailUpdate alloc] initCitrusPayWithEmail:contactInfo.email];

    
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentCitrus
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
               merchantAccess:bill.merchantAccessKey];
    

    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                   requestId:PaymentAsCitruspayInternalReqId
                                     headers:nil
                                  parameters:nil
                                        json:[paymentrequest toJSONString]
                                  httpMethod:POST];
    [restCore requestAsyncServer:request];

}


- (void)requestLoadMoneyInCitrusPay:(CTSPaymentDetailUpdate *)paymentInfo
                        withContact:(CTSContactUpdate*)contactInfo
                                       withAddress:(CTSUserAddress*)userAddress
                                        amount:( NSString *)amount
                                     returnUrl:(NSString *)returnUrl
withCompletionHandler:(ASLoadMoneyCallBack)callback{
    [self addCallback:callback forRequestId:PaymentLoadMoneyCitrusPayReqId];
    
    __block NSString *amountBlock = amount;
    
    [self requestGetPrepaidBillForAmount:amount returnUrl:returnUrl withCompletionHandler:^(CTSPrepaidBill *prepaidBill, NSError *error) {
       
        if(error == nil){
        CTSPaymentRequest* paymentrequest =
        [self configureReqPayment:paymentInfo
                          contact:contactInfo
                          address:userAddress
                           amount:amountBlock
                        returnUrl:prepaidBill.returnUrl
                        signature:prepaidBill.signature
                            txnId:prepaidBill.merchantTransactionId
                   merchantAccess:prepaidBill.merchantAccessKey];
        
        paymentrequest.notifyUrl = prepaidBill.notifyUrl;
        
        CTSRestCoreRequest* request =
        [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                       requestId:PaymentLoadMoneyCitrusPayReqId
                                         headers:nil
                                      parameters:nil
                                            json:[paymentrequest toJSONString]
                                      httpMethod:POST];
        [restCore requestAsyncServer:request];
        }
        else {
            [self loadMoneyHelper:nil error:[CTSError getErrorForCode:PrepaidBillFetchFailed]];
        }
    }];
    
    
    
    
    
    
    

    
}





- (void)requestMerchantPgSettings:(NSString*)vanityUrl
            withCompletionHandler:(ASGetMerchantPgSettingsCallBack)callback {
  [self addCallback:callback forRequestId:PaymentPgSettingsReqId];

  if (vanityUrl == nil) {
    [self getMerchantPgSettingsHelper:nil
                                error:[CTSError
                                          getErrorForCode:InvalidParameter]];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PAYMENT_GET_PGSETTINGS_PATH
         requestId:PaymentPgSettingsReqId
           headers:nil
        parameters:@{
          MLC_PAYMENT_GET_PGSETTINGS_QUERY_VANITY : vanityUrl
        } json:nil
        httpMethod:POST];
  [restCore requestAsyncServer:request];
}

-(void)requestGetPrepaidBillForAmount:(NSString *)amount returnUrl:(NSString *)returnUrl withCompletionHandler:(ASGetPrepaidBill)callback{

    [self addCallback:callback forRequestId:PaymentGetPrepaidBillReqId];
    
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self getPrepaidBillHelper:nil error:oauthStatus.error];
        return;
    }
    
    if(returnUrl == nil){
        [self getPrepaidBillHelper:nil error:[CTSError
                                              getErrorForCode:ReturnUrlNotValid]];
    }

    if(amount == nil){
        [self getPrepaidBillHelper:nil error:[CTSError
                                              getErrorForCode:ReturnUrlNotValid]];
    
    }

    NSDictionary *params = @{MLC_PAYMENT_GET_PREPAID_BILL_QUERY_AMOUNT:amount,
                                MLC_PAYMENT_GET_PREPAID_BILL_QUERY_CURRENCY:MLC_PAYMENT_GET_PREPAID_BILL_QUERY_CURRENCY_INR,
                                MLC_PAYMENT_GET_PREPAID_BILL_QUERY_REDIRECT:returnUrl};

    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PAYMENT_GET_PREPAID_BILL_PATH
                                   requestId:PaymentGetPrepaidBillReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:params
                                   json:nil
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];


}




#pragma mark - authentication protocol mehods
- (void)signUp:(BOOL)isSuccessful
    accessToken:(NSString*)token
          error:(NSError*)error {
  if (isSuccessful) {
  }
}

enum {
  PaymentAsGuestReqId,
  PaymentUsingtokenizedCardBankReqId,
  PaymentUsingSignedInCardBankReqId,
  PaymentPgSettingsReqId,
    PaymentAsCitruspayInternalReqId,
    PaymentAsCitruspayReqId,
    PaymentGetPrepaidBillReqId,
    PaymentLoadMoneyCitrusPayReqId

};
- (instancetype)init {
    finished = YES;
  NSDictionary* dict = @{
    toNSString(PaymentAsGuestReqId) : toSelector(handleReqPaymentAsGuest
                                                 :),
    toNSString(PaymentUsingtokenizedCardBankReqId) :
        toSelector(handleReqPaymentUsingtokenizedCardBank
                   :),
    toNSString(PaymentUsingSignedInCardBankReqId) :
        toSelector(handlePaymentUsingSignedInCardBank
                   :),
    toNSString(PaymentPgSettingsReqId) : toSelector(handleReqPaymentPgSettings
                                                    :),
    
    toNSString(PaymentAsCitruspayInternalReqId) : toSelector(handlePayementUsingCitruspayInternal
                                                    :),
    toNSString(PaymentAsCitruspayReqId) : toSelector(handlePayementUsingCitruspay
                                                             :),
    toNSString(PaymentGetPrepaidBillReqId) : toSelector(handleGetPrepaidBill
                                                     :),
    toNSString(PaymentLoadMoneyCitrusPayReqId) : toSelector(handleLoadMoneyCitrusPay
                                                        :)
    
    
  };
  self = [super initWithRequestSelectorMapping:dict
                                       baseUrl:CITRUS_PAYMENT_BASE_URL];
  return self;
}

-(NSDictionary *)getRegistrationDict{
    return @{
             toNSString(PaymentAsGuestReqId) : toSelector(handleReqPaymentAsGuest
                                                          :),
             toNSString(PaymentUsingtokenizedCardBankReqId) :
                 toSelector(handleReqPaymentUsingtokenizedCardBank
                            :),
             toNSString(PaymentUsingSignedInCardBankReqId) :
                 toSelector(handlePaymentUsingSignedInCardBank
                            :),
             toNSString(PaymentPgSettingsReqId) : toSelector(handleReqPaymentPgSettings
                                                             :),
             
             toNSString(PaymentAsCitruspayInternalReqId) : toSelector(handlePayementUsingCitruspayInternal
                                                                      :),
             toNSString(PaymentAsCitruspayReqId) : toSelector(handlePayementUsingCitruspay:),
             toNSString(PaymentGetPrepaidBillReqId) : toSelector(handleGetPrepaidBill
                                                                 :),
             toNSString(PaymentLoadMoneyCitrusPayReqId) : toSelector(handleLoadMoneyCitrusPay
                                                                     :)

             };
    
    
}


- (instancetype)initWithUrl:(NSString *)url
{
    
    if(url == nil){
        url = CITRUS_PAYMENT_BASE_URL;
    }
    self = [super initWithRequestSelectorMapping:[self getRegistrationDict]
                                         baseUrl:url];
    return self;
}



#pragma mark - response handlers methods


-(void)handleGetPrepaidBill:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPrepaidBill* bill = nil;
    if (error == nil) {
        bill =
        [[CTSPrepaidBill alloc] initWithString:response.responseString
                                                   error:&jsonError];
        
        [bill logProperties];
    }
    
    [self getPrepaidBillHelper:bill error:error];

}



- (void)handleReqPaymentAsGuest:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (error == nil) {
    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];

    [payment logProperties];
    //    [delegate payment:self
    //        didMakePaymentUsingGuestFlow:resultObject
    //                               error:error];
  }
  [self makeGuestPaymentHelper:payment error:error];
}

- (void)handleReqPaymentUsingtokenizedCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (error == nil) {
    NSLog(@"error:%@", jsonError);
    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [payment logProperties];
  }
  [self makeTokenizedPaymentHelper:payment error:error];
}

- (void)handlePaymentUsingSignedInCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (response.indexData > -1) {
    CTSPaymentDetailUpdate* paymentDetail =
        [self fetchAndRemoveDataFromCache:response.indexData];
    [paymentDetail logProperties];
    __block CTSProfileLayer* profile = [[CTSProfileLayer alloc] init];
    [profile updatePaymentInformation:paymentDetail
                withCompletionHandler:^(NSError* error) {
                    LogTrace(@" error %@ ", error);
                }];

    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
  }
  [self makeUserPaymentHelper:payment error:error];
}


-(void)handleLoadMoneyCitrusPay:(CTSRestCoreResponse *)response {
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        NSLog(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self loadMoneyHelper:payment error:error];
    
}

-(void)handlePayementUsingCitruspayInternal:(CTSRestCoreResponse*)response  {

    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        NSLog(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self makeCitrusPayInternalHelper:payment error:error];



}

-(void)handlePayementUsingCitruspay:(CTSRestCoreResponse*)response  {
    
    //call back view controller
    // or delegate
    //reset view controller and callback
    
    
    
    
}



- (void)handleReqPaymentPgSettings:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPgSettings* pgSettings = nil;
  if (error == nil) {
    pgSettings = [[CTSPgSettings alloc] initWithString:response.responseString
                                                 error:&jsonError];
    [pgSettings logProperties];
  }
  [self getMerchantPgSettingsHelper:pgSettings error:error];
}

#pragma mark -helper methods
- (void)makeUserPaymentHelper:(CTSPaymentTransactionRes*)payment
                        error:(NSError*)error {
  ASMakeUserPaymentCallBack callback = [self
      retrieveAndRemoveCallbackForReqId:PaymentUsingSignedInCardBankReqId];

  if (callback != nil) {
    callback(payment, error);
  } else {
    [delegate payment:self didMakeUserPayment:payment error:error];
  }
}

- (void)makeTokenizedPaymentHelper:(CTSPaymentTransactionRes*)payment
                             error:(NSError*)error {
  ASMakeTokenizedPaymentCallBack callback = [self
      retrieveAndRemoveCallbackForReqId:PaymentUsingtokenizedCardBankReqId];
  if (callback != nil) {
    callback(payment, error);
  } else {
    [delegate payment:self didMakeTokenizedPayment:payment error:error];
  }
}

- (void)makeGuestPaymentHelper:(CTSPaymentTransactionRes*)payment
                         error:(NSError*)error {
  ASMakeGuestPaymentCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:PaymentAsGuestReqId];
  if (callback != nil) {
    callback(payment, error);
  } else {
    [delegate payment:self didMakePaymentUsingGuestFlow:payment error:error];
  }
}

-(void)makeCitrusPayInternalHelper:(CTSPaymentTransactionRes*)payment
                     error:(NSError*)error{

    ASMakeCitruspayCallBackInternal callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsCitruspayInternalReqId];
    if (callback != nil) {
        callback(payment, error);
    } 

}
- (void)loadMoneyHelper:(CTSPaymentTransactionRes*)payment
                        error:(NSError*)error {
    ASLoadMoneyCallBack callback = [self
                                          retrieveAndRemoveCallbackForReqId:PaymentLoadMoneyCitrusPayReqId];
    
    if (callback != nil) {
        callback(payment, error);
    } else {
        [delegate payment:self didLoadMoney:payment error:error];
    }
}


-(void)makeCitrusPayHelper:(CTSCitrusCashRes*)paymentRes
                             error:(NSError*)error{
    
    ASCitruspayCallback callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsCitruspayReqId];
    
    if (callback != nil) {
        callback(paymentRes, error);
    }
    else{
        [delegate payment:self
             didPaymentCitrusCash:paymentRes
                    error:error];
    }
    [self resetCitrusPay];
}



- (void)getMerchantPgSettingsHelper:(CTSPgSettings*)pgSettings
                              error:(NSError*)error {
  ASGetMerchantPgSettingsCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:PaymentPgSettingsReqId];
  if (callback != nil) {
    callback(pgSettings, error);
  } else {
    [delegate payment:self didRequestMerchantPgSettings:pgSettings error:error];
  }
}

-(void)getPrepaidBillHelper:(CTSPrepaidBill*)bill
                     error:(NSError*)error{
    
    ASGetPrepaidBill callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentGetPrepaidBillReqId];
    
    if (callback != nil) {
        callback(bill, error);
    }
    else{
        [delegate payment:self
     didGetPrepaidBill:bill error:error];
    }
    [self resetCitrusPay];
}




-(void)handlePaymentResponse:(CTSPaymentTransactionRes *)paymentInfo error:(NSError *)error{
    
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    if(hasSuccess){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPaymentWebview:paymentInfo.redirectUrl];
        });
        
    }
    else{
        //TODO: add the helper call
        [self makeCitrusPayHelper:nil error:[CTSError convertToError:paymentInfo]];

    }
}



-(void)resetCitrusPay{

    if( [citrusPayWebview isLoading]){
        [citrusPayWebview stopLoading];
    }
    [citrusPayWebview removeFromSuperview];
    citrusPayWebview.delegate = nil;
    citrusPayWebview = nil;
    citrusCashBackViewController = nil;
}

#pragma mark -  CitrusPayWebView

- (void)webViewDidStartLoad:(UIWebView*)webView {
    NSLog(@"webViewDidStartLoad ");
}


-(void)loadPaymentWebview:(NSString *)url{

    citrusPayWebview = [[UIWebView alloc] init];
    citrusPayWebview.delegate = self;
    [citrusCashBackViewController.view addSubview:citrusPayWebview];
    [citrusPayWebview loadRequest:[[NSURLRequest alloc]
                               initWithURL:[NSURL URLWithString:url]]];
    citrusPayWebview.frame = CGRectMake(0, 0, citrusCashBackViewController.view.frame.size.width, citrusCashBackViewController.view.frame.size.height);

//    while(finished) {
//        NSLog(@" run loop");
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
    //[self loadRedirectUrl:url];
}

//- (void)loadRedirectUrl:(NSString*)redirectURL {
//    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
//    webViewViewController.redirectURL = redirectURL;
//    [UIUtility dismissLoadingAlertView:YES];
//    [citrusCashBackViewController.navigationController pushViewController:webViewViewController animated:YES];
//}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    NSLog(@"did finish loading");
   // NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
//    if(responseDict){
//        CTSCitrusCashRes *response = [[CTSCitrusCashRes alloc] init];
//        response.responseDict = responseDict;
//       // [self makeCitrusPayHelper:response error:nil];
//       // finished = NO;
//    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request url %@",[request URL]);
    
    
    NSArray* cookies =
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]];
    NSLog(@"cookie array:%@", cookies);
    if([CTSUtility isVerifyPage:[[request URL] absoluteString]]){
            [self makeCitrusPayHelper:nil
                            error:[CTSError getErrorForCode:UserNotSignedIn]];
    
    }
    
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody];
    
    if(responseDict){
        CTSCitrusCashRes *response = [[CTSCitrusCashRes alloc] init];
        response.responseDict = responseDict;
        [self makeCitrusPayHelper:response error:nil];
    }

    LogTrace(@"responseDict %@",responseDict);
    
    return YES;
}




//-(void)transactionComplete:(NSDictionary *)responseDictionary{
//    if([responseDictionary valueForKey:@"TxStatus"] != nil){
//        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[responseDictionary valueForKey:@"TxStatus"] ]];
//    }
//    else{
//        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n Response: %@",responseDictionary]];
//    }
//}

@end
