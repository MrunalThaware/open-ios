//
//  CTSProfileLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSContactUpdate.h"
#import "CTSProfileContactRes.h"
#import "CTSProfilePaymentRes.h"
#import "CTSPaymentDetailUpdate.h"
#import "CTSRestCoreResponse.h"
#import "CTSRestPluginBase.h"
#import "CTSProfileLayerConstants.h"
#import "CTSProfileContactNewRes.h"
#import "CTSAmount.h"

@class CTSProfileLayer;

/**
 *  user profile related services
 */
@interface CTSProfileLayer : CTSRestPluginBase {
}

- (instancetype)initWithUrl:(NSString *)url;

typedef void (^ASGetContactInfoCallBack)(CTSProfileContactRes* contactInfo,
                                         NSError* error);

typedef void (^ASGetPaymentInfoCallBack)(CTSProfilePaymentRes* paymentInfo,
                                         NSError* error);

typedef void (^ASUpdatePaymentInfoCallBack)(NSError* error);

typedef void (^ASUpdateContactInfoCallBack)(NSError* error);

typedef void (^ASUpdateMobileNumberCallback)(NSError* error);

typedef void (^ASGetContactInfoNewCallback)(CTSProfileContactNewRes*contactInfo, NSError* error);

typedef void (^ASGetBalanceCallBack)(CTSAmount *amount, NSError* error);

typedef void (^ASActivatePrepaidCallBack)(BOOL isActivated, NSError* error);

/**
 *  update contact related information
 *
 *  @param contactInfo actual information to be updated
 */
- (void)updateContactInformation:(CTSContactUpdate*)contactInfo
           withCompletionHandler:(ASUpdateContactInfoCallBack)callback;

/**
 *  update payment related information
 *
 *  @param paymentInfo payment information
 */
- (void)updatePaymentInformation:(CTSPaymentDetailUpdate*)paymentInfo
           withCompletionHandler:(ASUpdatePaymentInfoCallBack)callback;

/**
 *  to request contact related information
 */
- (void)requestContactInformationWithCompletionHandler:
        (ASGetContactInfoCallBack)callback;

/**
 *  request user's payment information
 */
- (void)requestPaymentInformationWithCompletionHandler:
        (ASGetPaymentInfoCallBack)callback;

- (void)requestUpdateMobile:(NSString *)mobileNumber allowUnverified:(BOOL)allowUnverified WithCompletionHandler:
(ASUpdateMobileNumberCallback)callback;


-(void)requestContactInfoNewWithCompletionHandler:(ASGetContactInfoNewCallback)callback;


/**
 @brief                 Get Citrus cash balance.
 @param callback        Set success/failure callBack.
 @details               Using this method user will get Citrus cash Prepaid balance.
 */
-(void)requestGetBalance:(ASGetBalanceCallBack)calback;


/**
 @brief                 Getting activate prepaid user account.
 @param callback        Set success/failure callBack.
 @details               Using this method user will activate Citrus cash Prepaid account.
 */
-(void)requestActivatePrepaidAccount:(ASActivatePrepaidCallBack)callback;
@end
