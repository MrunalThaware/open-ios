//
//  CTSAnalyticsManager.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 16/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const CTSSDKErrorCategory;
FOUNDATION_EXPORT NSString *const CTSGeneralCategoryName;

@interface CTSAnalyticsManager : NSObject

- (void)trackScreenNamed:(NSString *)screenName;
- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action;
- (void)trackTransactionWithIdentifier:(NSString *)transactionId amount:(NSString *)amount forCategoryName:(NSString *)categoryName providerName:(NSString *)providerName accountType:(NSString*)accountType;
- (void)trackCampaignURL:(NSURL *)url;
- (void)trackTransactionWithDictionary:(NSDictionary *)transactionDictionary;

@end
