//
//  CTSPaymentOption.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 20/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSPaymentOption.h"

@implementation CTSPaymentOption
@synthesize type, name, owner, number, expiryDate, scheme, bank, token, mmid,
    impsRegisteredMobile, cvv, code;

-(instancetype)initCitrusPayWithEmail:(NSString *)email{
    self = [super init];
    if (self) {
        type = MLC_CITRUS_PAY_TYPE;
        owner = email;//MLC_CITRUS_PAY_HOLDER;
        number = MLC_CITRUS_PAY_NUMBER;
        expiryDate = MLC_CITRUS_PAY_EXPIRY;
        scheme = MLC_CITRUS_PAY_SCHEME;
        cvv = MLC_CITRUS_PAY_CVV;
    }
    return self;
}

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
    bank = bankDetails.bank;
    owner = bankDetails.name;
    token = bankDetails.token;
    code = bankDetails.code;
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
    
    if ([type isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE]||[type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]) {
        error = [self validateCard];
        
        if(error != NoError){
            return error;
        }

        error = [self validateCardOwner];
    }
    
    if(error != NoError){
        return error;
    }
    
    return error;
}

+ (CTSErrorCode)validateCardDetailsForCardNumber:(NSString *)number
                                  withExpiryDate:(NSString *)expiryDate
                                       withOwner:(NSString *)owner{
    CTSErrorCode error = NoError;
    
    if ([CTSUtility validateCardNumber:number] == NO) {
        error = CardNumberNotValid;
    } else if ([CTSUtility validateExpiryDate:expiryDate] == NO) {
        error = ExpiryDateNotValid;
    }
    
    if ([CTSUtility stringContainsSpecialChars:owner exceptChars:@"" exceptCharSet:[NSCharacterSet whitespaceCharacterSet]] || [CTSUtility islengthInvalid:owner]||owner == nil) {
        error = CardHolderNameInvalid;
    }
    
    if(error != NoError){
        return error;
    }
    
    return error;
}


-(CTSErrorCode)validateCardOwner{
    CTSErrorCode error = NoError;
    if ([CTSUtility stringContainsSpecialChars:owner exceptChars:@"" exceptCharSet:[NSCharacterSet whitespaceCharacterSet]] || [CTSUtility islengthInvalid:owner]||owner == nil) {
        error = CardHolderNameInvalid;
    }
    return error;
    
}

- (CTSErrorCode)validateCard {
    CTSErrorCode error = NoError;
    if ([CTSUtility validateCardNumber:number] == NO) {
        error = CardNumberNotValid;
        return error;
    } else if ([CTSUtility isMaestero:number]== NO) {
        if ([CTSUtility validateExpiryDate:expiryDate] == NO) {
            error = ExpiryDateNotValid;
            return error;
        }
        
        if ([CTSUtility validateExpiryDateMonth:expiryDate] == NO) {
            error = ExpiryDateMonthYearExpired;
            return error;
        }
        
    } else if ([CTSUtility isMaestero:number]== NO &&[CTSUtility validateCVV:cvv cardNumber:number] == NO) {
        error = CvvNotValid;
        return error;
    }
    return error;
}

- (CTSPaymentType)fetchPaymentType {
  if (self.token != nil && self.cvv != nil) {
    return TokenizedCard;
  } else if (self.token != nil && self.cvv == nil) {
    return TokenizedNetbank;
  } else if (self.token == nil && self.cvv != nil) {
    return MemberCard;
  } else if (self.token == nil && self.cvv == nil) {
    return MemberNetbank;
  } else {
    return UndefinedPayment;
  }
}

- (CTSPaymentToken*)fetchPaymentToken {
  CTSPaymentToken* paymentToken = [[CTSPaymentToken alloc] init];
  CTSPaymentMode* paymentMode = nil;
  switch ([self fetchPaymentType]) {
    case TokenizedCard:
      paymentToken.id = token;
      paymentToken.cvv = cvv;
      paymentToken.type = TYPE_TOKENIZED;

      break;
    case TokenizedNetbank:
      paymentToken.id = token;
      paymentToken.type = TYPE_TOKENIZED;

      break;
    case MemberCard:
      paymentToken.type = TYPE_MEMBER;
      paymentMode = [[CTSPaymentMode alloc] init];
      paymentMode.cvv = cvv;
      paymentMode.holder = owner;
      paymentMode.number = number;
      paymentMode.scheme = scheme;
      paymentMode.expiry = expiryDate;
      paymentMode.type = type;

      break;
    case MemberNetbank:
      paymentToken.type = TYPE_MEMBER;
      paymentMode = [[CTSPaymentMode alloc] init];
      paymentMode.type = type;
      paymentMode.code = code;

      break;
    default:
      break;
  }
  paymentToken.paymentMode = paymentMode;
  return paymentToken;
}

@end