//
//  CTSMetaDataCard.m
//  CitrusPay-iOS-SDK-Sample-App
//
//  Created by Mukesh Patil on 21/07/15.
//  Copyright (c) 2015 CitrusPay. All rights reserved.
//

#import "CTSMetaDataCard.h"
#import "NSObject+logProperties.h"

@implementation CTSMetaDataCard
@synthesize iin, type, scheme, issuer, country, currency;
+ (CTSMetaDataCard *)returnCTSMetaDataCardObjectModel:(id)JSON{
    JSONModelError *jsonError;
    CTSMetaDataCard *resultObject = [[CTSMetaDataCard alloc] initWithDictionary:JSON
                                                                      error:&jsonError];
    [resultObject logProperties];
    return resultObject;
}
@end
