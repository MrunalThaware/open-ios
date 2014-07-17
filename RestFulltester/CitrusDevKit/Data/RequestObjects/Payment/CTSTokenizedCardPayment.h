//
//  CTSTokenizedCardPayment.h
//  RestFulltester
//
//  Created by Raji Nair on 30/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSAmount.h"
#import "CTSUserDetails.h"
#import "CTSPaymentToken.h"

@interface CTSTokenizedCardPayment : NSObject
@property(nonatomic, strong) CTSAmount* amount;
@property(strong) NSString* merchantAccesskey, *merchantTxnId, *notifyUrl,
    *requestSignature, *returnUrl, *merchant, *merchantKey;
@property(nonatomic, strong) CTSUserDetails* userDetails;
@property(nonatomic, strong) CTSPaymentToken* paymentToken;
@end
