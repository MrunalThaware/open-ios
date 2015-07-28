//
//  CTSDyPResponse.h
//  CTS iOS Sdk
//
//  Created by Yadnesh on 7/27/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"
#import "CTSAmount.h"

@interface CTSDyPResponse : JSONModel
@property(nonatomic,assign)int resultCode;
@property(nonatomic,strong) CTSAmount *alteredAmount,*originalAmount;
@property(nonatomic,strong)NSString* resultMessage,*offerToken;
@property(nonatomic,strong)NSDictionary *extraParams;

@end
