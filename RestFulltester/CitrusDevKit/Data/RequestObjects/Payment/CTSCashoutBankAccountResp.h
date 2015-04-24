//
//  CashoutBankAccountResp.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 24/04/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"
#import "CTSCashoutBankAccount.h"

@interface CTSCashoutBankAccountResp : JSONModel
@property(strong) NSString<Optional>* type;
@property(strong) NSString<Optional>* currency;
@property(strong) CTSCashoutBankAccount<Optional>* cashoutAccount;
@end
