//
//  MerchantConstants.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/08/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#ifndef CTS_iOS_Sdk_MerchantConstants_h
#define CTS_iOS_Sdk_MerchantConstants_h


#ifdef SANDBOX_MODE
// for sandbox envirement
#define VanityUrl @"nativeSDK"
#define SignInId @""
#define SignInSecretKey @""
#define SubscriptionId @""
#define SubscriptionSecretKey @""
#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
#define BaseUrl @"https://sandboxadmin.citruspay.com"
#define MerchantAccessKey @"F2VZD1HBS2VVXJPMWO77"

#elif STAGING_MODE
// for staging envirement
#define VanityUrl @"stgcube"
#define SignInId @""
#define SignInSecretKey @""
#define SubscriptionId @""
#define SubscriptionSecretKey @""
#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
#define BaseUrl @"https://stg1admin.citruspay.com"
#define MerchantAccessKey @"F2VZD1HBS2VVXJPMWO77"

#else 
// for production envirement
#define VanityUrl @"rio"
#define SignInId @""
#define SignInSecretKey @""
#define SubscriptionId @""
#define SubscriptionSecretKey @""
#define ReturnUrl @"http://clients.vxtindia.net/citrus/"
#define BaseUrl @"https://admin.citruspay.com"
#define MerchantAccessKey @"2GPZFO5FDDLTQY0O98JT"
#endif
#endif
