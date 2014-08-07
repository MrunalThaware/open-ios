//
//  CTSPaymentTransactionRes.h
//  RestFulltester
//
//  Created by Raji Nair on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface CTSPaymentTransactionRes : JSONModel
@property(nonatomic, strong) NSString* redirectUrl, *pgRespCode, *txMsg;
@end
