//
//  MerchantConstants.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/08/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#ifndef CTS_iOS_Sdk_MerchantConstants_h
#define CTS_iOS_Sdk_MerchantConstants_h
//


// Sandbox
#ifdef SANDBOX_MODE
// for sandbox envirement
#define VanityUrl @"nativeSDK"
#define SignInId @"gogo-pre-wallet"
#define SignInSecretKey @"e6f1b840c652d2ffc46530faaac8b771"
#define SubscriptionId @"test-signup"
#define SubscriptionSecretKey @"c78ec84e389814a05d3ae46546d16d2e"
#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
#define BaseUrl @"https://sandboxadmin.citruspay.com"
#define MerchantAccessKey @"F2VZD1HBS2VVXJPMWO77"

#elif STAGING_MODE
// for staging envirement
#define VanityUrl @"stgcube"
#define SignInId @"citrus-native-mobile-app-v1"
#define SignInSecretKey @"83df0e4db17fa7b206f4c36d3f19d6c1"
#define SubscriptionId @"citrus-native-mobile-subscription"
#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93373884d2ca1"
#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
#define BaseUrl @"https://stg1admin.citruspay.com"
#define MerchantAccessKey @"F2VZD1HBS2VVXJPMWO77"

#else 
// for production envirement
#define VanityUrl @"rio"
#define SignInId @"citrus-native-mobile-app-v1"
#define SignInSecretKey @"83df0e4db17fa7b206f4c36d3f19d6c1"
#define SubscriptionId @"citrus-native-mobile-subscription"
#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93373884d2ca1"
#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
#define BaseUrl @"https://admin.citruspay.com"
#define MerchantAccessKey @"2GPZFO5FDDLTQY0O98JT"
#endif

//#define VanityUrl @"nativeSDK"
//#define SignInId @"gogo-pre-wallet"
//#define SignInSecretKey @"e6f1b840c652d2ffc46530faaac8b771"
//#define SubscriptionId @"test-signup"
//#define SubscriptionSecretKey @"c78ec84e389814a05d3ae46546d16d2e"
//#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
//#define BaseUrl @"https://sandboxadmin.citruspay.com"
//#define MerchantAccessKey @"X5IHRVPY4FTYR3SA2QVK"

//live only for payments
//#define VanityUrl @"rio"
//#define SignInId @"citrus-native-mobile-app-v1"
//#define SignInSecretKey @"83df0e4db17fa7b206f4c36d3f19d6c1"
//#define SubscriptionId @"citrus-native-mobile-subscription"
//#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93373884d2ca1"
//#define MerchantAccessKey @"2GPZFO5FDDLTQY0O98JT"
//#define BaseUrl @"https://admin.citruspay.com"


//#define VanityUrl @"nativesdk"
//#define SignInId @"citrus-native-mobile-app-v1"
//#define SignInSecretKey @"83df0e4db17fa7b206f4c36d3f19d6c1"
//#define SubscriptionId @"citrus-native-mobile-subscription"
//#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93373884d2ca1"
//#define MerchantAccessKey @"F2VZD1HBS2VVXJPMWO77"
//#define BaseUrl @"https://testbilladmin.citruspay.com"



//// staging
//#define VanityUrl @"nativesdk"
//#define SignInId @"citrus-native-mobile-app-v1"
//#define SignInSecretKey @"83df0e4db17fa7b206f4c36d3f19d6c1"
//#define SubscriptionId @"citrus-native-mobile-subscription"
//#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93373884d2ca1"
//#define MerchantAccessKey @"14KZ1O3AGP8SUKPK8989"

#endif
