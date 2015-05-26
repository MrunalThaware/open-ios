//
//  CTSPaymentLayer.h
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSPaymentLayerConstants.h"
#import "CTSPaymentDetailUpdate.h"
#import "CTSAuthLayerConstants.h"
#import "CTSUtility.h"
#import "CTSPaymentRes.h"
#import "CTSPaymentDetailUpdate.h"
#import "CTSContactUpdate.h"
#import "CTSPaymentUpdate.h"
#import "CTSPaymentRequest.h"
#import "CTSPaymentTransactionRes.h"
#import "CTSPgSettings.h"
#import "CTSAuthLayer.h"
#import "CTSRestPluginBase.h"
#import "CTSUserAddress.h"
#import "CTSBill.h"
#import "CitrusCashRes.h"
#import "CTSPrepaidBill.h"
#import "CTSCashoutBankAccount.h"
#import "CTSCashoutBankAccountResp.h"
#import "CTSCashoutToBankRes.h"
#import "PaymentWebViewController.h"

enum {
    PaymentAsGuestReqId,
    PaymentUsingtokenizedCardBankReqId,
    PaymentUsingSignedInCardBankReqId,
    PaymentPgSettingsReqId,
    PaymentAsCitruspayInternalReqId,
    PaymentAsCitruspayReqId,
    PaymentGetPrepaidBillReqId,
    PaymentLoadMoneyCitrusPayReqId,
    PaymentCashoutToBankReqId,
    PaymentChargeInnerWebNormalReqId,
    PaymentChargeInnerWeblTokenReqId,
    PaymentChargeInnerWebLoadMoneyReqId
    
    
};
#define LoadMoneyResponeKey @"loadMoneyResponseKey"
@class CTSAuthLayer;
@class CTSAuthenticationProtocol;
@class CTSPaymentLayer;
@protocol CTSPaymentProtocol<NSObject>
@optional
- (void)payment:(CTSPaymentLayer*)layer
    didMakeUserPayment:(CTSPaymentTransactionRes*)paymentInfo
                 error:(NSError*)error;

/**
 *  Guest payment callback
 *
 *  @param layer
 *  @param paymentInfo
 *  @param error
 */
@optional
- (void)payment:(CTSPaymentLayer*)layer
    didMakePaymentUsingGuestFlow:(CTSPaymentTransactionRes*)paymentInfo
                           error:(NSError*)error;

/**
 *  response for tokenized payment
 *
 *  @param layer
 *  @param paymentInfo
 *  @param error
 */
@optional
- (void)payment:(CTSPaymentLayer*)layer
    didMakeTokenizedPayment:(CTSPaymentTransactionRes*)paymentInfo
                      error:(NSError*)error;

/**
 *  pg setting are recived for merchant
 *
 *  @param pgSetting pegsetting,nil in case of error
 *  @param error     ctserror
 */
@optional
- (void)payment:(CTSPaymentLayer*)layer
    didPaymentCitrusCash:(CTSCitrusCashRes*)pgSettings
                           error:(NSError*)error;

@optional
- (void)payment:(CTSPaymentLayer*)layer
didRequestMerchantPgSettings:(CTSPgSettings*)pgSettings
          error:(NSError*)error;


@optional
- (void)payment:(CTSPaymentLayer*)layer
didGetPrepaidBill:(CTSPrepaidBill*)bill
          error:(NSError*)error;




@optional
- (void)payment:(CTSPaymentLayer*)layer
didLoadMoney:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error;


@optional
- (void)payment:(CTSPaymentLayer*)layer
didCashoutToBank:(CTSCashoutToBankRes *)cashoutToBankRes
          error:(NSError*)error;

@end
@interface CTSPaymentLayer : CTSRestPluginBase<CTSAuthenticationProtocol,UIWebViewDelegate> {
    UIWebView *citrusPayWebview;
    PaymentWebViewController *paymentWebViewController;
    BOOL finished;
    NSString *cCashReturnUrl;
}
@property(strong,nonatomic)UIViewController *citrusCashBackViewController;

@property(strong) NSString* merchantTxnId;
@property(strong) NSString* signature;
@property(weak) id<CTSPaymentProtocol> delegate;

- (instancetype)initWithUrl:(NSString *)url;


typedef void (^ASMakeUserPaymentCallBack)(CTSPaymentTransactionRes* paymentInfo,
                                          NSError* error);

typedef void (^ASMakeTokenizedPaymentCallBack)(
    CTSPaymentTransactionRes* paymentInfo,
    NSError* error);

typedef void (^ASMakeGuestPaymentCallBack)(
    CTSPaymentTransactionRes* paymentInfo,
    NSError* error);

typedef void (^ASMakeCitruspayCallBackInternal)(CTSPaymentTransactionRes* paymentInfo,
                                           NSError* error);

typedef void (^ASCitruspayCallback)(CTSCitrusCashRes* citrusCashResponse,
                                                NSError* error);

typedef void (^ASGetMerchantPgSettingsCallBack)(CTSPgSettings* pgSettings,
                                                NSError* error);

typedef void (^ASGetPrepaidBill)(CTSPrepaidBill* prepaidBill,
                                                NSError* error);

typedef void (^ASLoadMoneyCallBack)(CTSPaymentTransactionRes* paymentInfo,
                                          NSError* error);

typedef void (^ASCashoutToBankCallBack)(CTSCashoutToBankRes *cashoutRes,
                                    NSError* error);

/**
 * called when client request to make payment through credit card/debit card

 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
/*- (void)makePaymentByCard:(CTSPaymentDetailUpdate*)paymentInfo
 withContact:(CTSContactUpdate*)contactInfo
 amount:(NSString*)amount
 withSignature:(NSString*)signature
 withTxnId:(NSString*)merchantTxnId;
 */

/**
 *  to make signed user's payment for netbanking/credit/debit card depending on
 *paymentInfo configuration
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */

//- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
//              withContact:(CTSContactUpdate*)contactInfo
//              withAddress:(CTSUserAddress*)userAddress
//                   amount:(NSString*)amount
//            withReturnUrl:(NSString*)returnUrl
//            withSignature:(NSString*)signature
//                withTxnId:(NSString*)merchantTxnId
//    withCompletionHandler:(ASMakeUserPaymentCallBack)callback;


/**
 *  called when client request to make a tokenized payment
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
//- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
//                 withContact:(CTSContactUpdate*)contactInfo
//                 withAddress:(CTSUserAddress*)userAddress
//                      amount:(NSString*)amount
//               withReturnUrl:(NSString*)returnUrl
//               withSignature:(NSString*)signature
//                   withTxnId:(NSString*)merchantTxnId
//       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback;



/**
 *  called when client request to make payment as a guest user
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 *  @param isDoSignup  send YES if signup should be done simultaneously for this
 *user
 */
//- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
//                      withContact:(CTSContactUpdate*)contactInfo
//                           amount:(NSString*)amount
//                      withAddress:(CTSUserAddress*)userAddress
//                    withReturnUrl:(NSString*)returnUrl
//                    withSignature:(NSString*)signature
//                        withTxnId:(NSString*)merchantTxnId
//            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback;


- (void)requestChargeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                          withContact:(CTSContactUpdate*)contactInfo
                          withAddress:(CTSUserAddress*)userAddress
                                 bill:(CTSBill *)bill
                withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback DEPRECATED_ATTRIBUTE;


- (void)requestChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                      withAddress:(CTSUserAddress*)userAddress
                             bill:(CTSBill *)bill
            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback DEPRECATED_ATTRIBUTE;

- (void)requestLoadMoneyInCitrusPay:(CTSPaymentDetailUpdate *)paymentInfo
                        withContact:(CTSContactUpdate*)contactInfo
                        withAddress:(CTSUserAddress*)userAddress
                             amount:( NSString *)amount
                          returnUrl:(NSString *)returnUrl
              withCompletionHandler:(ASLoadMoneyCallBack)callback DEPRECATED_ATTRIBUTE;





- (void)requestChargeCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                               withAddress:(CTSUserAddress*)userAddress
                                      bill:(CTSBill *)bill
                      returnViewController:(UIViewController *)controller
                     withCompletionHandler:(ASCitruspayCallback)callback;


- (void)requestChargeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                          withContact:(CTSContactUpdate*)contactInfo
                          withAddress:(CTSUserAddress*)userAddress
                                 bill:(CTSBill *)bill
                 returnViewController:(UIViewController *)controller
                withCompletionHandler:(ASCitruspayCallback)callback;


- (void)requestChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                        bill:(CTSBill *)bill
        returnViewController:(UIViewController *)controller
       withCompletionHandler:(ASCitruspayCallback)callback;



- (void)requestLoadMoneyInCitrusPay:(CTSPaymentDetailUpdate *)paymentInfo
                        withContact:(CTSContactUpdate*)contactInfo
                        withAddress:(CTSUserAddress*)userAddress
                             amount:( NSString *)amount
                          returnUrl:(NSString *)returnUrl
               returnViewController:(UIViewController *)controller
              withCompletionHandler:(ASCitruspayCallback)callback;



//- (void)requestChargeInternalCitrusCashWithContact:(CTSContactUpdate*)contactInfo
//                 withAddress:(CTSUserAddress*)userAddress
//                        bill:(CTSBill *)bill
//       withCompletionHandler:(ASMakeGuestPaymentCallBack)callback;



/**
 *  request card pament options(visa,master,debit) and netbanking settngs for
 *the merchant
 *
 *  @param vanityUrl: pass in unique vanity url obtained from Citrus Payment
 *sol.
 */
- (void)requestMerchantPgSettings:(NSString*)vanityUrl
            withCompletionHandler:(ASGetMerchantPgSettingsCallBack)callback;


-(void)requestGetPrepaidBillForAmount:(NSString *)amount returnUrl:(NSString *)returnUrl withCompletionHandler:(ASGetPrepaidBill)callback;


-(void)requestCashoutToBank:(CTSCashoutBankAccount *)bankAccount amount:(NSString *)amount completionHandler:(ASCashoutToBankCallBack)callback;



@end
