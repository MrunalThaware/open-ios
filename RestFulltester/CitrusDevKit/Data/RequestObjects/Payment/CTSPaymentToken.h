//
//  CTSPaymentToken.h
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CTSPaymentMode;

@interface CTSPaymentToken : NSObject
@property(strong) CTSPaymentMode* paymentMode;
@property(strong) NSString* type, *tokenid, *cvv;

@end
