//
//  CTSPaymentRequest.h
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSAmount.h"
#import "CTSPaymentToken.h"
#import "CTSUserDetails.h"

@interface CTSPaymentRequest : NSObject
@property(nonatomic, strong) CTSAmount* amount;
@property(strong) NSString* merchantAccesskey, *merchantTxnId, *notifyUrl,
    *requestSignature, *returnUrl, *merchant, *merchantKey;
@property(nonatomic, strong) CTSPaymentToken* paymentToken;
@property(nonatomic, strong) CTSUserDetails* userDetails;

@end
