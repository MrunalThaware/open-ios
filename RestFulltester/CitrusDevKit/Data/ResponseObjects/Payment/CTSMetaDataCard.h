//
//  CTSMetaDataCard.h
//  CitrusPay-iOS-SDK-Sample-App
//
//  Created by Mukesh Patil on 21/07/15.
//  Copyright (c) 2015 CitrusPay. All rights reserved.
//

#import "JSONModel.h"

@interface CTSMetaDataCard : JSONModel
@property(nonatomic, strong) NSString *iin;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *scheme;
@property(nonatomic, strong) NSString *issuer;
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *currency;
+ (CTSMetaDataCard *)returnCTSMetaDataCardObjectModel:(id)JSON;
@end
