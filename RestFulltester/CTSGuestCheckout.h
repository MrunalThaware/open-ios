//
//  CTSGuestCheckout.h
//  RestFulltester
//
//  Created by Raji Nair on 27/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSGuestCheckout : NSObject
@property(nonatomic, strong) NSString* returnUrl, *expiryYear, *amount,
    *addressState, *paymentMode, *lastName, *addressCity, *address, *email,
    *cardHolderName, *firstName, *cvvNumber, *cardType, *issuerCode,
    *merchantTxnId, *addressZip, *expiryMonth, *mobile, *cardNumber;

@end
