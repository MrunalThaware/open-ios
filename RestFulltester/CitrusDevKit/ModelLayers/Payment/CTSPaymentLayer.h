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
#import "CTSPrepaidBill.h"
#import "CTSCitrusCashRes.h"
#import "CTSVaultToken.h"

enum {
    PaymentAsGuestReqId,
    PaymentUsingtokenizedCardBankReqId,
    PaymentUsingSignedInCardBankReqId,
    PaymentPgSettingsReqId,
    PaymentGetPrepaidBillReqId,
    PaymentLoadMoneyCitrusPayReqId,
    PaymentAsCitruspayReqId,
    PaymentAsCitruspayInternalReqId,
    GetVaultTokenReqId
};

@class RKObjectManager;
@class CTSAuthLayer;
@class CTSAuthenticationProtocol;
@class CTSPaymentLayer;

@interface CTSPaymentLayer : CTSRestPluginBase<UIWebViewDelegate> {
    UIViewController *citrusCashBackViewController;
    UIWebView *citrusPayWebview;
}
@property(strong) NSString* merchantTxnId;
@property(strong) NSString* signature;
@property(nonatomic, strong) RKObjectManager* objectManager;

typedef void (^ASMakeUserPaymentCallBack)(CTSPaymentTransactionRes* paymentInfo,
                                          NSError* error);

typedef void (^ASMakeTokenizedPaymentCallBack)(
    CTSPaymentTransactionRes* paymentInfo,
    NSError* error);

typedef void (^ASMakeGuestPaymentCallBack)(
    CTSPaymentTransactionRes* paymentInfo, NSError* error);

typedef void (^ASGetMerchantPgSettingsCallBack)(CTSPgSettings* pgSettings,
                                                NSError* error);

typedef void (^ASGetPrepaidBill)(CTSPrepaidBill* prepaidBill,
                                 NSError* error);

typedef void (^ASLoadMoneyCallBack)(CTSPaymentTransactionRes* paymentInfo,
                                    NSError* error);

typedef void (^ASCitruspayCallback)(CTSCitrusCashRes* citrusCashResponse,
                                    NSError* error);

typedef void (^ASMakeCitruspayCallBackInternal)(CTSPaymentTransactionRes* paymentInfo,
                                                NSError* error);

typedef void (^ASGetVaultTokenCallback)(CTSVaultToken *, NSError *);

- (instancetype)initWithUrl:(NSString *)url;

/**
 *  to make signed user's payment for netbanking/credit/debit card depending on
 *paymentInfo configuration
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */

- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
              withContact:(CTSContactUpdate*)contactInfo
              withAddress:(CTSUserAddress*)userAddress
                   amount:(NSString*)amount
            withReturnUrl:(NSString*)returnUrl
            withSignature:(NSString*)signature
                withTxnId:(NSString*)merchantTxnId
         withCustParams:(NSDictionary *)custParams
    withCompletionHandler:(ASMakeUserPaymentCallBack)callback;

/**
 *  called when client request to make a tokenized payment
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                      amount:(NSString*)amount
               withReturnUrl:(NSString*)returnUrl
               withSignature:(NSString*)signature
                   withTxnId:(NSString*)merchantTxnId
              withCustParams:(NSDictionary *)custParams
       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback;

/**
 *  called when client request to make payment as a guest user
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 *  @param isDoSignup  send YES if signup should be done simultaneously for this
 *user
 */
- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount
                      withAddress:(CTSUserAddress*)userAddress
                    withReturnUrl:(NSString*)returnUrl
                    withSignature:(NSString*)signature
                        withTxnId:(NSString*)merchantTxnId
                   withCustParams:(NSDictionary *)custParams
            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback;

/**
 *  request card pament options(visa,master,debit) and netbanking settngs for
 *the merchant
 *
 *  @param vanityUrl: pass in unique vanity url obtained from Citrus Payment
 *sol.
 */
- (void)requestMerchantPgSettings:(NSString*)vanityUrl
            withCompletionHandler:(ASGetMerchantPgSettingsCallBack)callback;

/**
 @brief                 Load cash into Citrus Pay account.
 @param paymentInfo     Set payment related information.
 @param contactInfo     Set contact related information.
 @param userAddress     Set user address details.
 @param amount          Set transction amount.
 @param returnUrl       Set redirect URL navigate 3D Secure page.
 @param callback        Set success/failure callBack.
 @details               Using this method user can load money using Debit/Credit Card, Net Banking & Tokenized bank into Citrus cash account.
 */
- (void)requestLoadMoneyInCitrusPay:(CTSPaymentDetailUpdate *)paymentInfo
                        withContact:(CTSContactUpdate*)contactInfo
                        withAddress:(CTSUserAddress*)userAddress
                             amount:( NSString *)amount
                          returnUrl:(NSString *)returnUrl
              withCompletionHandler:(ASLoadMoneyCallBack)callback;



/**
 @brief                 Make payment with Citrus pay.
 @param contactInfo     Set contact related information.
 @param userAddress     Set user address details.
 @param bill            Set bill values from bill generator URL Viz, merchantTxnId/amo
 unt/requestSignature/merchantAccessKey/returnUrl.
 @param controller      Set view controller for navigate to webview.
 @param callback        Set success/failure callBack.
 @details               Using this method user can pay money from Citrus Pay account for any online transcton.
 */
- (void)requestChargeCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                               withAddress:(CTSUserAddress*)userAddress
                                    amount:(NSString*)amount
                             withReturnUrl:(NSString*)returnUrl
                             withSignature:(NSString*)signatureArg
                                 withTxnId:(NSString*)merchantTxnIdArg
                      returnViewController:(UIViewController *)controller
                     withCompletionHandler:(ASCitruspayCallback)callback;


/**
 @brief                         getVaultTokenWithPAN.
 @param WithPAN                 cardNumber.
 @param withHolder              holder.
 @param withExpiry              expiry
 @param withUserID              userID.
 @param withCompletionHandler   ASGetVaultTokenCallback callBack.
 @details                       get vault token for credit card.
*/
-(void)getVaultTokenWithPAN:(NSString *)cardNumber
                 withHolder:(NSString *)holder
                 withExpiry:(NSString *)expiry
                 withUserID:(NSString *)userID
      withCompletionHandler:(ASGetVaultTokenCallback)callback;

@end
