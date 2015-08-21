//
//  CTSDyPValidateRuleReq.h
//  CTS iOS Sdk
//
//  Created by Yadnesh on 7/27/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"
#import "CTSAmount.h"
#import "CTSDyPPaymentInfo.h"

@interface CTSDyPValidateRuleReq : JSONModel
@property(nonatomic,strong)NSString* ruleCode,*signature,*merchantTransactionId,*merchantAccessKey,*mobile,*userType;
@property(nonatomic,strong)NSString<Optional> *email;
@property(nonatomic,strong)NSMutableDictionary<Optional> *extraParams;
@property(nonatomic,strong)CTSAmount *originalAmount,*alteredAmount;
@property(nonatomic,strong)CTSDyPPaymentInfo* paymentInformation;

@end
