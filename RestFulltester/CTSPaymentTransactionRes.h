//
//  CTSPaymentTransactionRes.h
//  RestFulltester
//
//  Created by Raji Nair on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSPaymentTransactionRes : NSObject
@property(nonatomic, strong) NSString* redirectUrl, *pgRespCode, *txMsg;
@end
