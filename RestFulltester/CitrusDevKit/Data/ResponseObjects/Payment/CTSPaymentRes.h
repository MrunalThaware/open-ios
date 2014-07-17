//
//  CTSPaymentRes.h
//  RestFulltester
//
//  Created by Raji Nair on 20/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface CTSPaymentRes : NSObject
@property(strong) NSString* merchantTransactionId, *merchant, *customer,
    *amount, *description, *signature, *redirectUrl;
@end
