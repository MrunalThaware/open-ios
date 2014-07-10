//
//  CTSPaymentLayer.h
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSRestIntergration.h"
#import "CTSRestLayer.h"
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

@class RKObjectManager;

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

/**
 *  pg setting are recived for merchant
 *
 *  @param pgSetting pegsetting,nil in case of error
 *  @param error     ctserror
 */
- (void)pgSetting:(CTSPgSettings*)pgSetting error:(NSError*)error;

@end
@interface CTSPaymentLayer : CTSRestIntergration<CTSRestLayerProtocol> {
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
- (void)makePaymentByCard:(CTSPaymentDetailUpdate*)paymentInfo
              withContact:(CTSContactUpdate*)contactInfo
                   amount:(NSString*)amount;

/**
 *  called when client request to make payment using net banking
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
- (void)makePaymentByNetBanking:(CTSPaymentDetailUpdate*)paymentInfo
                    withContact:(CTSContactUpdate*)contactInfo
                         amount:(NSString*)amount;

/**
 *  called when client request to make a tokenized payment
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
- (void)makeTokenizedCardPayment:(CTSPaymentDetailUpdate*)paymentInfo
                     withContact:(CTSContactUpdate*)contactInfo
                          amount:(NSString*)amount;

/**
 *  called when client request to make payment as a guest user
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount;

/**
 *  request card pament options(visa,master,debit) and netbanking settngs for
 *the merchant
 *
 *  @param vanityUrl: pass in unique vanity url obtained from Citrus Payment
 *sol.
 */
- (void)requestMerchantPgSettings:(NSString*)vanityUrl;

@end
