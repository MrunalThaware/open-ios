//
//  CTSAnalyticsManager.m
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 16/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSAnalyticsManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

NSString *const CTSSDKErrorCategory = @"SDKError";
NSString *const CTSGeneralCategoryName = @"Common";

@implementation CTSAnalyticsManager

- (instancetype)init {
    [[GAI sharedInstance] setDispatchInterval:20];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-33514461-4"];
    [[[GAI sharedInstance] defaultTracker] setAllowIDFACollection:YES];
    return self;
}


- (void)trackScreenNamed:(NSString *)screenName {
    id <GAITracker> tracker = [self tracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action {
    NSDictionary *eventDictionary = [[GAIDictionaryBuilder createEventWithCategory:category action:action label:nil value:@1] build];
    [[self tracker] send:eventDictionary];
}

- (void)trackTransactionWithIdentifier:(NSString *)transactionId amount:(NSString *)amount forCategoryName:(NSString *)categoryName providerName:(NSString *)providerName accountType:(NSString*)accountType {
    if ([transactionId isKindOfClass:[NSString class]] && [amount respondsToSelector:@selector(floatValue)]) {
        id <GAITracker> tracker = [self tracker];
        
        NSDictionary *transactionDictionary = [[GAIDictionaryBuilder createTransactionWithId:transactionId affiliation:@"iOS SDK" revenue:@([amount floatValue]) tax:@0 shipping:@0 currencyCode:@"INR"] build];
        [tracker send:transactionDictionary];
        
        NSDictionary *itemDictionary = [[GAIDictionaryBuilder createItemWithTransactionId:transactionId name:categoryName sku:providerName category:accountType price:@([amount floatValue]) quantity:@1 currencyCode:@"INR"] build];
        [tracker send:itemDictionary];
    }
}

- (void)trackTransactionWithDictionary:(NSDictionary *)transactionDictionary {
    if ([transactionDictionary isKindOfClass:[NSDictionary class]]) {
        id <GAITracker> tracker = [self tracker];
        [tracker send:transactionDictionary];
    }
}


- (void)trackCampaignURL:(NSURL *)url {
    
}

- (id <GAITracker>)tracker {
    return [[GAI sharedInstance] defaultTracker];
}

@end
