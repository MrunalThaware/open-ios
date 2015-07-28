//
//  CTSDyPPaymentInfo.h
//  CTS iOS Sdk
//
//  Created by Yadnesh on 7/27/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"

@interface CTSDyPPaymentInfo : JSONModel
@property(nonatomic,strong)NSString* cardNo,*cardType,*issuerId,*paymentMode,*paymentToken;
@end
