
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
	* Secret Key
	* Access Key
	* SignIn Key
	* SignIn Secret
	* SignUp Key
	* SignUp Secret

Note: Please DO NOT PROCEED if the above mentioned requirements have not been met.

###Features
Citrus iOS SDK broadly offers following features.
* Prepaid Payments.
* Direct credit/debit card (CC, DC) or netbanking payments (NB)
* Saving Credit/Debit cards into user's account for easier future payments by abiding The Payment Card Industry Data Security Standard (PCI DSS).
* Loading Money into users Citrus prepaid account for Prepaid facility
* Withdraw the money back into User's bank account from the Prepaid account
* Creating Citrus account for the user





























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
