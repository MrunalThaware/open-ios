//
//  CTSPaymentMode.h
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSPaymentMode : NSObject
@property(strong) NSString* cvv, *expiry, *holder, *number, *scheme, *type,
    *code, *tokenid;

@end
