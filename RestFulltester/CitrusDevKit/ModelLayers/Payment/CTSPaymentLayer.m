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
#import "CTSUserAddress.h"
#import "CTSBill.h"

@interface CTSPaymentLayer ()
@end

@implementation CTSPaymentLayer
@synthesize merchantTxnId;
@synthesize signature;
@synthesize objectManager;

- (CTSPaymentRequest*)configureReqPayment:(CTSPaymentDetailUpdate*)paymentInfo
                                  contact:(CTSContactUpdate*)contact
                                  address:(CTSUserAddress*)address
                                   amount:(NSString*)amount
                                returnUrl:(NSString*)returnUrl
                                signature:(NSString*)signatureArg
                           withCustParams:(NSDictionary *)custParams
                                    txnId:(NSString*)txnId {
  CTSPaymentRequest* paymentRequest = [[CTSPaymentRequest alloc] init];

  paymentRequest.amount = [self ctsAmountForAmount:amount];
  paymentRequest.merchantAccessKey = CTSAuthLayer.getMerchantAccessKey;
  paymentRequest.merchantTxnId = txnId;
  paymentRequest.notifyUrl = @"";
  paymentRequest.requestSignature = signatureArg;
  paymentRequest.returnUrl = returnUrl;
  paymentRequest.paymentToken =
      [[paymentInfo.paymentOptions objectAtIndex:0] fetchPaymentToken];
    paymentRequest.customParameters = custParams;
  paymentRequest.userDetails =
      [[CTSUserDetails alloc] initWith:contact address:address];

  return paymentRequest;
}


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

- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
              withContact:(CTSContactUpdate*)contactInfo
              withAddress:(CTSUserAddress*)userAddress
                   amount:(NSString*)amount
            withReturnUrl:(NSString*)returnUrl
            withSignature:(NSString*)signatureArg
                withTxnId:(NSString*)merchantTxnIdArg
         withCustParams:(NSDictionary *)custParams
    withCompletionHandler:(ASMakeUserPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentUsingSignedInCardBankReqId];

  CTSPaymentRequest* paymentrequest =
      [self configureReqPayment:paymentInfo
                        contact:contactInfo
                        address:userAddress
                         amount:amount
                      returnUrl:returnUrl
                      signature:signatureArg
                 withCustParams:custParams
                          txnId:merchantTxnIdArg];

  CTSErrorCode error = [paymentInfo validate];

  LogDebug(@"validation error %d ", error);

  if (error != NoError) {
    [self makeUserPaymentHelper:nil error:[CTSError getErrorForCode:error]];
    return;
  }

    [paymentInfo doCardCorrectionsIfNeeded];
    

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                     requestId:PaymentUsingSignedInCardBankReqId
                                       headers:nil
                                    parameters:nil
                                          json:[paymentrequest toJSONString]
                                    httpMethod:POST
                                     dataIndex:-1];

  [restCore requestAsyncServer:request];
}

- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                      amount:(NSString*)amount
               withReturnUrl:(NSString*)returnUrl
               withSignature:(NSString*)signatureArg
                   withTxnId:(NSString*)merchantTxnIdArg
              withCustParams:(NSDictionary*)custParams
       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentUsingtokenizedCardBankReqId];

  CTSPaymentRequest* paymentrequest =
      [self configureReqPayment:paymentInfo
                        contact:contactInfo
                        address:userAddress
                         amount:amount
                      returnUrl:returnUrl
                      signature:signatureArg
                 withCustParams:custParams
                          txnId:merchantTxnIdArg];

  CTSErrorCode error = [paymentInfo validateTokenized];
  LogDebug(@" validation error %d ", error);

  if (error != NoError) {
    [self makeTokenizedPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
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

- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount
                      withAddress:(CTSUserAddress*)userAddress
                    withReturnUrl:(NSString*)returnUrl
                    withSignature:(NSString*)signatureArg
                        withTxnId:(NSString*)merchantTxnIdArg
                   withCustParams:(NSDictionary *)custParams
            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentAsGuestReqId];

  CTSErrorCode error = [paymentInfo validate];
  LogDebug(@"validation error %d ", error);

  if (error != NoError) {
    [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
    return;
  }
  CTSPaymentRequest* paymentrequest =
      [self configureReqPayment:paymentInfo
                        contact:contactInfo
                        address:userAddress
                         amount:amount
                      returnUrl:returnUrl
                      signature:signatureArg
                 withCustParams:custParams
                          txnId:merchantTxnIdArg
       ];

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
                                    amount:(NSString*)amount
                             withReturnUrl:(NSString*)returnUrl
                             withSignature:(NSString*)signatureArg
                                 withTxnId:(NSString*)merchantTxnIdArg
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
        if(controller == nil){
        [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
        
    }
    
    citrusCashBackViewController = controller;
    
    [self requestChargeInternalCitrusCashWithContact:contactInfo
                                         withAddress:userAddress
                                              amount:amount
                                       withReturnUrl:returnUrl
                                       withSignature:signatureArg
                                           withTxnId:merchantTxnIdArg
                               withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        LogDebug(@"paymentInfo %@",paymentInfo);
        LogDebug(@"error %@",error);
        [self handlePaymentResponse:paymentInfo error:error] ;
    }];
}


- (void)requestChargeInternalCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                                       withAddress:(CTSUserAddress*)userAddress
                                            amount:(NSString*)amount
                                     withReturnUrl:(NSString*)returnUrl
                                     withSignature:(NSString*)signatureArg
                                         withTxnId:(NSString*)merchantTxnIdArg
                             withCompletionHandler:(ASMakeCitruspayCallBackInternal)callback{
    [self addCallback:callback forRequestId:PaymentAsCitruspayInternalReqId];
    
    
    CTSPaymentDetailUpdate *paymentCitrus = [[CTSPaymentDetailUpdate alloc] initCitrusPayWithEmail:contactInfo.email];
    
        CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentCitrus
                      contact:contactInfo
                      address:userAddress
                       amount:amount
                    returnUrl:returnUrl
                    signature:signatureArg
                        txnId:merchantTxnIdArg
               merchantAccess:CTSAuthLayer.getMerchantAccessKey];
    
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
                             MLC_PAYMENT_GET_PREPAID_BILL_QUERY_REDIRECT:returnUrl
                             };
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PAYMENT_GET_PREPAID_BILL_PATH
                                   requestId:PaymentGetPrepaidBillReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:params
                                   json:nil
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
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

// get get meta data for Credit card only.
- (void)getMetaDataForCardWithPAN:(NSString *)cardNumber
            withCompletionHandler:(ASGetMetaDataForCardCallback)callback{
    
    [self addCallback:callback forRequestId:GetMetaDataCardReqId];

    if ([cardNumber length] < 6) {
        [self getMetaDataCardHelper:nil
                            error:[CTSError getErrorForCode:CardNumberNotValid]];
        return;
    }else{
        cardNumber = [cardNumber substringToIndex:6];
    }
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:[MLC_GET_META_DATA_CARD_PATH stringByAppendingString:cardNumber]
                                   requestId:GetMetaDataCardReqId
                                   headers:[CTSUtility readMetaDataCardAsHeader]
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    
    [restCore requestAsyncServer:request];
}


// get get vault token for Credit card only.
-(void)getVaultTokenWithPAN:(NSString *)cardNumber
                 withHolder:(NSString *)holder
                 withExpiry:(NSString *)expiry
                 withUserID:(NSString *)userID
             withCompletionHandler:(ASGetVaultTokenCallback)callback{
    
    [self addCallback:callback forRequestId:GetVaultTokenReqId];
    
    expiry = [CTSUtility correctExpiryDate:expiry];
    
    CTSErrorCode error = [CTSPaymentOption validateCardDetailsForCardNumber:cardNumber
                                                             withExpiryDate:expiry
                                                                  withOwner:holder];
    
    if (error != NoError) {
        [self getVaultTokenHelper:nil
                            error:[CTSError getErrorForCode:error]];
        return;
    }

    if([CTSUtility isEmail:userID]){
        if (![CTSUtility validateEmail:userID]) {
            [self getVaultTokenHelper:nil
                                error:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
    }else {
        if (![CTSUtility mobileNumberToTenDigitIfValid:userID]) {
            [self getVaultTokenHelper:nil
                                error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
    }
    
    
    if (!userID) {
        [self getVaultTokenHelper:nil
                            error:[CTSError getErrorForCode:InvalidParameter]];
        return;
    }

    NSDictionary *params = @{
                             MLC_GET_VAULT_TOKEN_CARD : @{
                                 MLC_GET_VAULT_TOKEN_PAN : cardNumber,
                                 MLC_GET_VAULT_TOKEN_HOLDER : holder,
                                 MLC_GET_VAULT_TOKEN_EXPIRY : expiry
                             },
                             MLC_GET_VAULT_TOKEN_HINT : @{
                                 MLC_GET_VAULT_TOKEN_KEY : MLC_GET_VAULT_TOKEN_KEY_NAME,
                                 MLC_GET_VAULT_TOKEN_VALUE : userID
                             }
                             };

    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_GET_VAULT_TOKEN_PATH
                                   requestId:GetVaultTokenReqId
                                   headers:[CTSUtility readVaultTokenAsHeader]
                                   parameters:nil
                                   json:[CTSUtility convertDictToJSONStringForDictionary:params]
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



- (instancetype)init {
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
                           toNSString(PaymentLoadMoneyCitrusPayReqId) : toSelector(handleLoadMoneyCitrusPay
                                                                                   :),
                           toNSString(PaymentGetPrepaidBillReqId) : toSelector(handleGetPrepaidBill
                                                                               :),
                           toNSString(PaymentAsCitruspayReqId) : toSelector(handlePayementUsingCitruspay
                                                                            :),
                           toNSString(PaymentAsCitruspayInternalReqId) : toSelector(handlePayementUsingCitruspayInternal
                                                                                    :),
                           toNSString(GetVaultTokenReqId) : toSelector(handleGetVaultToken:),
                           toNSString(GetMetaDataCardReqId) : toSelector(handleGetMetaDataCard:)
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
             toNSString(PaymentLoadMoneyCitrusPayReqId) : toSelector(handleLoadMoneyCitrusPay
                                                                     :),
             toNSString(PaymentGetPrepaidBillReqId) : toSelector(handleGetPrepaidBill
                                                                 :),
             toNSString(PaymentAsCitruspayReqId) : toSelector(handlePayementUsingCitruspay
                                                              :),
             toNSString(PaymentAsCitruspayInternalReqId) : toSelector(handlePayementUsingCitruspayInternal
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

- (void)handleReqPaymentAsGuest:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (error == nil) {
    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [payment logProperties];
  }
  [self makeGuestPaymentHelper:payment error:error];
}

- (void)handleReqPaymentUsingtokenizedCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (error == nil) {
    LogDebug(@"error:%@", jsonError);
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
    payment =
    [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                               error:&jsonError];
  [self makeUserPaymentHelper:payment error:error];
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

-(void)handleLoadMoneyCitrusPay:(CTSRestCoreResponse *)response {
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        LogDebug(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self loadMoneyHelper:payment error:error];
    
}

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

-(void)handleGetVaultToken:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSVaultToken *vaultToken = nil;
    if (error == nil) {
        vaultToken = [[CTSVaultToken alloc] initWithString:response.responseString
                                         error:&jsonError];
        
        [vaultToken logProperties];
    }
    [self getVaultTokenHelper:vaultToken error:error];
}

-(void)handleGetMetaDataCard:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSMetaDataCard *metaDataCard = nil;
    if (error == nil) {
        metaDataCard = [[CTSMetaDataCard alloc] initWithString:response.responseString
                                                     error:&jsonError];
        
        [metaDataCard logProperties];
    }
    [self getMetaDataCardHelper:metaDataCard error:error];
}



-(void)handlePayementUsingCitruspay:(CTSRestCoreResponse*)response  {
    
    //call back view controller
    // or delegate
    //reset view controller and callback
}


-(void)handlePayementUsingCitruspayInternal:(CTSRestCoreResponse*)response  {
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        LogDebug(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self makeCitrusPayInternalHelper:payment error:error];
}



#pragma mark -helper methods

- (void)makeUserPaymentHelper:(CTSPaymentTransactionRes*)payment
                        error:(NSError*)error {
  ASMakeUserPaymentCallBack callback = [self
      retrieveAndRemoveCallbackForReqId:PaymentUsingSignedInCardBankReqId];

  if (callback != nil) {
    callback(payment, error);
  }
}

-(void)getVaultTokenHelper:(CTSVaultToken *)vaultToken error:(NSError *)error{
    ASGetVaultTokenCallback callback = [self retrieveAndRemoveCallbackForReqId:GetVaultTokenReqId];
    if (callback != nil) {
        callback(vaultToken, error);
    }
}


-(void)getMetaDataCardHelper:(CTSMetaDataCard *)metaDataCard error:(NSError *)error{
    ASGetMetaDataForCardCallback callback = [self retrieveAndRemoveCallbackForReqId:GetMetaDataCardReqId];
    if (callback != nil) {
        callback(metaDataCard, error);
    }
}


- (void)makeTokenizedPaymentHelper:(CTSPaymentTransactionRes*)payment
                             error:(NSError*)error {
  ASMakeTokenizedPaymentCallBack callback = [self
      retrieveAndRemoveCallbackForReqId:PaymentUsingtokenizedCardBankReqId];
  if (callback != nil) {
    callback(payment, error);
  }
}

- (void)makeGuestPaymentHelper:(CTSPaymentTransactionRes*)payment
                         error:(NSError*)error {
  ASMakeGuestPaymentCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:PaymentAsGuestReqId];
  if (callback != nil) {
    callback(payment, error);
  }
}

-(void)getPrepaidBillHelper:(CTSPrepaidBill*)bill
                      error:(NSError*)error{
    
    ASGetPrepaidBill callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentGetPrepaidBillReqId];
    
    if (callback != nil) {
        callback(bill, error);
    }
    [self resetCitrusPay];
}

- (void)loadMoneyHelper:(CTSPaymentTransactionRes*)payment
                  error:(NSError*)error {
    ASLoadMoneyCallBack callback = [self
                                    retrieveAndRemoveCallbackForReqId:PaymentLoadMoneyCitrusPayReqId];
    
    if (callback != nil) {
        callback(payment, error);
    }
}


- (void)getMerchantPgSettingsHelper:(CTSPgSettings*)pgSettings
                              error:(NSError*)error {
  ASGetMerchantPgSettingsCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:PaymentPgSettingsReqId];
  if (callback != nil) {
    callback(pgSettings, error);
  }
}


-(void)makeCitrusPayHelper:(CTSCitrusCashRes*)paymentRes
                     error:(NSError*)error{
    
    ASCitruspayCallback callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsCitruspayReqId];
    
    if (callback != nil) {
        callback(paymentRes, error);
    }
    [self resetCitrusPay];
}

-(void)makeCitrusPayInternalHelper:(CTSPaymentTransactionRes*)payment
                             error:(NSError*)error{
    ASMakeCitruspayCallBackInternal callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsCitruspayInternalReqId];
    if (callback != nil) {
        callback(payment, error);
    }
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
        if(paymentInfo){
        [self makeCitrusPayHelper:nil error:[CTSError convertToError:paymentInfo]];
        }
        else {
            [self makeCitrusPayHelper:nil error:error];
        }
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
    LogDebug(@"webViewDidStartLoad ");
}


-(void)loadPaymentWebview:(NSString *)url{
    
    citrusPayWebview = [[UIWebView alloc] init];
    citrusPayWebview.delegate = self;
    [citrusCashBackViewController.view addSubview:citrusPayWebview];
    [citrusPayWebview loadRequest:[[NSURLRequest alloc]
                                   initWithURL:[NSURL URLWithString:url]]];
    citrusPayWebview.frame = CGRectMake(0, 0, citrusCashBackViewController.view.frame.size.width, citrusCashBackViewController.view.frame.size.height);
}


- (void)webViewDidFinishLoad:(UIWebView*)webView {
    LogDebug(@"did finish loading");
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
    if(responseDict){
        CTSCitrusCashRes *response = [[CTSCitrusCashRes alloc] init];
        response.responseDict = responseDict;
        [self makeCitrusPayHelper:response error:nil];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    LogDebug(@"request url %@",[request URL]);
    
    NSArray* cookies =
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]];
    LogDebug(@"cookie array:%@", cookies);
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
    
    LogDebug(@"responseDict %@",responseDict);
    return YES;
}


@end
