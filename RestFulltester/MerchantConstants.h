//
//  MerchantConstants.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/08/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//


#ifndef CTS_iOS_Sdk_MerchantConstants_h
#define CTS_iOS_Sdk_MerchantConstants_h

/*
 Sandbox Environment
 OAUTH KEYS
*/
//// Keys

#warning Enter your Keys & URLs here

//// Keys
#define SignInId @"citrus-cube-mobile-app"
#define SignInSecretKey @"bd63aa06f797f73966f4bcaa4bba00fe"
#define SubscriptionId @"citrus-native-mobile-subscription"
#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93373884d2ca1"
//
//// URLs
#define VanityUrl @"nativeSDK"
#define ReturnUrl @"http://localhost:8888/return.php"
#define BillUrl @"http://localhost:8888/bill.php"
#define BaseUrl @"https://sandboxadmin.citruspay.com"




//set to 0 to disable logging, logs remain off in production
#define ENABLE_LOGGING 1


#endif
