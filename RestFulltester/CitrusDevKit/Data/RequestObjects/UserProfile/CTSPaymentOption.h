//
//  CTSPaymentOption.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 20/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSElectronicCardUpdate.h"
#import "CTSNetBankingUpdate.h"
#import "CTSTokenizedPayment.h"

@interface CTSPaymentOption : CTSObject
//@property(nonatomic, strong) NSString* type, *cardName, *ownerName, *number,
//    *bankName, *expiryDate, *scheme;

@property(nonatomic, strong) NSString* type, *name, *owner, *number,
    *expiryDate, *scheme, *bank, *token, *mmid, *impsRegisteredMobile, *cvv,
    *code;
- (instancetype)initWithNetBanking:(CTSNetBankingUpdate*)bankDetails;
- (instancetype)initWithCard:(CTSElectronicCardUpdate*)eCard;
- (instancetype)initWithTokenized:(CTSTokenizedPayment*)tokenizedPayment;

@end
