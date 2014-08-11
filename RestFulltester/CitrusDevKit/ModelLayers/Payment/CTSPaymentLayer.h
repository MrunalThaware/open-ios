//
//  CTSPaymentLayer.h
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CTSRestLayer.h"
#import "CTSPaymentLayerConstants.h"
#import "CTSRestRegister.h"
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

@class RKObjectManager;
@class CTSAuthLayer;
@class CTSAuthenticationProtocol;
@class CTSPaymentLayer;
@protocol CTSPaymentProtocol<NSObject>
/**
 *  when payment is successful
 *
 *  @param paymentinfo Payment Information
 */
- (void)transactionInfo:(CTSPaymentTransactionRes*)paymentinfo;

/**
 *  when transaction is initiated and transaction fails
 *
 *  @param transactionInfo nil in case of error
 *  @param error           error if happened
 */
- (void)transactionInformation:(CTSPaymentRes*)transactionInfo
                         error:(NSError*)error;

- (void)payment:(CTSPaymentLayer*)layer
    didMakeUserPayment:(CTSPaymentTransactionRes*)paymentInfo
                 error:(NSError*)error;

- (void)payment:(CTSPaymentLayer*)layer
    didMakePaymentUsingGuestFlow:(CTSPaymentTransactionRes*)paymentInfo
                           error:(NSError*)error;

- (void)payment:(CTSPaymentLayer*)layer
    didMakeTokenizedPayment:(CTSPaymentTransactionRes*)paymentInfo
                      error:(NSError*)error;

/**
 *  pg setting are recived for merchant
 *
 *  @param pgSetting pegsetting,nil in case of error
 *  @param error     ctserror
 */

- (void)payment:(CTSPaymentLayer*)layer
    didRequestMerchantPgSettings:(CTSPgSettings*)pgSettings
                           error:(NSError*)error;

@end
@interface CTSPaymentLayer : CTSRestPluginBase<CTSAuthenticationProtocol> {
  dispatch_queue_t backgroundQueue;
}
@property(strong) NSString* merchantTxnId;
@property(strong) NSString* signature;
@property(nonatomic, strong) RKObjectManager* objectManager;
@property(weak) id<CTSPaymentProtocol> delegate;
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
 *  called when client request to make payment using net banking
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
/*- (void)makePaymentByNetBanking:(CTSPaymentDetailUpdate*)paymentInfo
                    withContact:(CTSContactUpdate*)contactInfo
                         amount:(NSString*)amount
                  withSignature:(NSString*)signature
                      withTxnId:(NSString*)merchantTxnId;*/

- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
            withContact:(CTSContactUpdate*)contactInfo
                 amount:(NSString*)amount
          withSignature:(NSString*)signature
              withTxnId:(NSString*)merchantTxnId;

/**
 *  called when client request to make a tokenized payment
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                      amount:(NSString*)amount
               withSignature:(NSString*)signature
                   withTxnId:(NSString*)merchantTxnId;

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
                    withSignature:(NSString*)signature
                        withTxnId:(NSString*)merchantTxnId
                       isDoSignup:(BOOL)isDoSignup;

/**
 *  request card pament options(visa,master,debit) and netbanking settngs for
 *the merchant
 *
 *  @param vanityUrl: pass in unique vanity url obtained from Citrus Payment
 *sol.
 */
- (void)requestMerchantPgSettings:(NSString*)vanityUrl;

- (void)insertMemberValues:(CTSPaymentDetailUpdate*)paymentDetailInfo
               withContact:(CTSContactUpdate*)contactDetailInfo
                 withTxnId:(NSString*)merchanttxnId
             withSignature:(NSString*)signature
                withAmount:(NSString*)amt;

@end
