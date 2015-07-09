
# This Wiki Is Obsolete, Please Refer To This [Guide](http://citruspay.com/DevelopersGuide/#/iossdk) For The Latest Installation And Integration Steps .



open-iOS
============
###SDK Installation Prerequisites
   * Xcode 6 or higher.
   
###Citrus PG Prerequisites
* You need to enroll with Citrus as a merchant.
* You need to host Bill generator on your server
* You need to host Return Url Page on your server. (After the transaction is complete, Citrus posts a response to this URL.)
* Make sure that you have obtained following parameters from your Citrus admin panel
	* Merchant Secret Key
	* Merchant Access Key
	* SignIn Key
	* SignIn Secret
	* SignUp Key
	* SignUp Secret

Note: Please DO NOT PROCEED if the above mentioned requirements have not been met.

###Features
Citrus iOS SDK broadly offers following features.
* Prepaid Payments.
* Direct credit/debit card (CC, DC) or netbanking payments (NB) .
* Saving Credit/Debit cards into user's account for easier future payments by abiding The Payment Card Industry Data Security Standard (PCI DSS).
* Loading Money into users Citrus prepaid account for Prepaid facility .
* Withdraw the money back into User's bank account from the Prepaid account .
* Creating Citrus account for the user .
*


### Installation From source code
Get the latest source code from github.com:
```bash
$ git clone https://github.com/citruspay/open-ios.git
```

### Xcode integration

To integrate the SDK you just have to drag drop file MerchantConstants.h & folder CitrusDevKit/  into your project as groups, import CitrusSdk.h and populate the macros in MerchantConstants.h with the parameters you obatained from your Citrus admin panel



## Let's Start Programming now

SDK operates in two different modes Sandbox and Production mode.
During the developement you would always want to use the Sandbox mode. once you are done with your App development you can switch to production mode . 

To operate in Sandbox mode you need to change the `BaseUrl` from MerchantConstants.h to 

		#define BaseUrl @"https://sandboxadmin.citruspay.com"

for production

		#define BaseUrl @"https://admin.citruspay.com"

A typical MerchantConstants.h file looks like following

		//// Keys
		#define SignInId @"citrus-mobile-app"
		#define SignInSecretKey @"bd63aa06f797f73966f4bcaa433300fe"
		#define SubscriptionId @"citrus-native-mobile-subscription"
		#define SubscriptionSecretKey @"3e2288d3a1a3f59ef6f93444484d2ca1"

		// URLs
		#define VanityUrl @"nativeSDK"		//this can be fetched from your Citrus Admin panel
		#define ReturnUrl @"http://192.168.0.5:8888/TestReturn.html"		//Load money reutnr URL, optional if you are not using prepaid functionality
		#define BillUrl @"http://192.168.0.5:8888/bill.php"		//this is your bill URL
		#define BaseUrl @"https://sandboxadmin.citruspay.com"		//Citrus Server Url either prodcution or Sandbox




























# PG Prerequisites
* You need to enroll with Citrus as a merchant.
* Have an HMAC generator installed on your server
* Make sure that you have the following parameters from Citrus

Following can be obtained from our support team. Do write a mail to tech.support@citruspay.com or call on +91-87-677-099-00 Extn: 2 (Technical Support)

	** Secret Key 

	** Access Key

	** SignIn Key
 
	** SignIn Secret

	** SignUp Key

	** SignUp Secret
  	

# SDK Prerequisites

You need to have installed and configured:
* Apple iOS SDK
* A `git` client
* All Citrus PG Prerequisites.

In case you do not have these details, DO NOT proceed.

# Installation
## From source code
Get the latest source code from github.com:
```bash
$ git clone https://github.com/citruspay/open-ios.git
```
## IDE integration
### Xcode

To integrate the SDK you just have to drag drop folder CitrusDevKit/ to your project as groups, import CitrusSdk.h and populate macros in MerchantConstants.h, you have to obtain these from Citrus.

# Wiki

Please refer to [git wiki](https://github.com/citruspay/open-ios/wiki) to get started.
