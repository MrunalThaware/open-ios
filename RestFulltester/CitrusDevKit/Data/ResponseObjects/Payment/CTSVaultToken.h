//
//  CTSVaultToken.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 20/07/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"

@interface CTSVaultToken : JSONModel
@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *expires;
@property(nonatomic,strong) NSString *holder;
@property(nonatomic,strong) NSString *expiry;
@property(nonatomic,strong) NSString *maskedPan;
@end
