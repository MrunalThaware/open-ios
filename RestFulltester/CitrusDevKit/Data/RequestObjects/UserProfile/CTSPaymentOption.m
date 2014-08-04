//
//  CTSPaymentOption.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 20/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSPaymentOption.h"
/**
 *  internal class should not be used by consumer
 */
//@implementation CTSPaymentOption
//@synthesize type, cardName, ownerName, number, expiryDate, scheme, bankName;
//
//- (instancetype)initWithCard:(CTSElectronicCardUpdate*)card {
//  self = [super init];
//  if (self) {
//    type = card.type;
//    cardName = card.name;
//    ownerName = card.ownerName;
//    number = card.number;
//    expiryDate = card.expiryDate;
//    scheme = card.scheme;
//  }
//  return self;
//}
//
//- (instancetype)initWithNetBanking:(CTSNetBankingUpdate*)bankDetails {
//  self = [super init];
//  if (self) {
//    type = bankDetails.type;
//    bankName = bankDetails.name;
//  }
//  return self;
//}
//@end

@implementation CTSPaymentOption
@synthesize type, name, owner, number, expiryDate, scheme, bank, token, mmid,
    impsRegisteredMobile, cvv, code;

- (instancetype)initWithCard:(CTSElectronicCardUpdate*)eCard {
  self = [super init];
  if (self) {
    type = eCard.type;
    name = eCard.name;
    owner = eCard.ownerName;
    number = eCard.number;
    expiryDate = eCard.expiryDate;
    scheme = eCard.scheme;
    cvv = eCard.cvv;
    token = eCard.token;
    code = eCard.bankcode;
  }
  return self;
}

- (instancetype)initWithNetBanking:(CTSNetBankingUpdate*)bankDetails {
  self = [super init];
  if (self) {
    type = bankDetails.type;
    code = bankDetails.code;
    token = bankDetails.token;
  }
  return self;
}

- (instancetype)initWithTokenized:(CTSTokenizedPayment*)tokenizedPayment {
  self = [super init];
  if (self) {
    type = tokenizedPayment.type;
    token = tokenizedPayment.token;
    cvv = tokenizedPayment.cvv;
  }
  return self;
}

- (CTSErrorCode)validate {
  CTSErrorCode error = NoError;

  if ([type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]) {
    error = [self validateCard];
  }
  if ([type isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE]) {
    error = [self validateCard];
  }
  return error;
}
- (CTSErrorCode)validateCard {
  CTSErrorCode error = NoError;
  if ([CTSUtility validateCardNumber:number] == NO) {
    error = CardNumberNotValid;
  } else if ([CTSUtility validateExpiryDate:expiryDate] == NO) {
    error = ExpiryDateNotValid;
  } else if ([CTSUtility validateCVV:cvv cardNumber:number] == NO) {
    error = CvvNotValid;
  }
  return error;
}

@end