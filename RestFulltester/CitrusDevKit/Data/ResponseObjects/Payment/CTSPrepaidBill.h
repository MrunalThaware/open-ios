//
//  CTSPrepaidBill.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 03/03/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"
#import "CTSAmount.h"
//"merchantTransactionId": "PPTX000000001317",
//"merchant": "citrusbank",
//"customer": "pandeymailinator123@mailinator.com",
//"amount": {
//    "value": 100,
//    "currency": "INR"
//},
//"description": "load money",
//"signature": "18ec08ae55b1d0ad50c6545e879fe2c73915d19b",
//"merchantAccessKey": "9S4YTSHSZPLQEYYUJAD0",
//"returnUrl": "https://sandboxadmin.citruspay.com/service/v2/prepayment/load/complete",
//"notifyUrl": "https://sandboxadmin.citruspay.com/service/v2/prepayment/load/notify"
@interface CTSPrepaidBill : JSONModel
@property(nonatomic,strong) NSString *merchantTransactionId;
@property(nonatomic,strong) NSString *merchant;
@property(nonatomic,strong) NSString *customer;
@property(nonatomic,strong) NSString *description;
@property(nonatomic,strong) NSString *signature;
@property(nonatomic,strong) NSString *merchantAccessKey;
@property(nonatomic,strong) NSString *returnUrl;
@property(nonatomic,strong) NSString *notifyUrl;
@property(nonatomic,strong) CTSAmount *amount;

@end
