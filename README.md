
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



### Installation From source code
Get the latest source code from github.com:
```bash
$ git clone https://github.com/citruspay/open-ios.git
```

### Xcode integration

To integrate the SDK you just have to drag drop file MerchantConstants.h & folder CitrusDevKit/  into your project as groups, import CitrusSdk.h and populate the macros in MerchantConstants.h with the parameters you obatained from your Citrus admin panel

![Drag Drop](https://dl.dropboxusercontent.com/u/6397934/citrus/GIT/Drag%20Drop.gif)

import "CitrusSdk.h"

![import](https://dl.dropboxusercontent.com/u/6397934/citrus/GIT/Import.png)

## Let's Start Programming now

SDK operates in two different modes Sandbox and Production mode. for both the enviroments Citrus PG Prerequisites key sets are different. keys from one enviroment wont work on other. so please make sure you are using correct set of keys.
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

		// URLs
		#define VanityUrl @"nativeSDK"					//this can be fetched from your Citrus Admin panel
		#define ReturnUrl @"http://192.168.0.5:8888/TestReturn.html"	//Load money reutnr URL, optional if you are not using prepaid functionality
		#define BillUrl @"http://192.168.0.5:8888/bill.php"		//this is your bill URL
		#define BaseUrl @"https://sandboxadmin.citruspay.com"  		//Citrus Server Url either prodcution or Sandbox



once you are done with all of the initial configuration you can proceed with following Guide

The SDK is logically divided into 3 modules/layers or interfacing classes
 * CTSAuthLayer - handles all of the user creation related tasks .
 * CTSProfileLayer - handles all of the user profile related tasks .
 * CTSPaymentLayer - handles all of the payment related tasks .
 
To use any of the above layers your need to declare them as a strong property like following,

		//declaration in your .h file
		 @property(strong)CTSPaymentLayer *paymentLayer ;
		
		// initialization in your .m file
		paymentLayer = [[CTSPaymentLayer alloc] init];
 
Following are the specific tasks related to each of the layer 

######[CTSAuthLayer](https://github.com/citruspay/open-ios/wiki/1.--Integrating-CTSAuthLayer)
 * [See if anyone is logged in](https://github.com/citruspay/open-ios/wiki/1.--Integrating-CTSAuthLayer#see-if-anyone-is-logged-in)
 * [Creating & Linking the User](https://github.com/citruspay/open-ios/wiki/1.--Integrating-CTSAuthLayer#creating--linking-the-user) 
 * [Signin the user for Prepaid level access](https://github.com/citruspay/open-ios/wiki/1.--Integrating-CTSAuthLayer#sign-in-the-user-for-prepaid-level-access)
 * [Reset User Password](https://github.com/citruspay/open-ios/wiki/1.--Integrating-CTSAuthLayer#reset-user-password)
 * [Sign Out](https://github.com/citruspay/open-ios/wiki/1.--Integrating-CTSAuthLayer#sign-out)
 
######[CTSProfileLayer](https://github.com/citruspay/open-ios/wiki/2.--Integrating-CTSProfileLayer)
 * [Save User Cards](https://github.com/citruspay/open-ios/wiki/2.--Integrating-CTSProfileLayer#save-user-cards)
 * [Get Saved Cards](https://github.com/citruspay/open-ios/wiki/2.--Integrating-CTSProfileLayer#get-saved-cards)
 * [Get User's Prepaid Balance](https://github.com/citruspay/open-ios/wiki/2.--Integrating-CTSProfileLayer#get-users-prepaid-balance)
 * [Save Cashout Bank Account](https://github.com/citruspay/open-ios/wiki/2.--Integrating-CTSProfileLayer#save-cash-out-bank-account)
 * [Get Saved Cashout Bank Acoount](https://github.com/citruspay/open-ios/wiki/2.--Integrating-CTSProfileLayer#get-saved-cashout-bank-acoount)
 
 
######[CTSPaymentLayer](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer)
  * [CC, DC, NB Direct Payments](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#cc-dc-nb-direct-payments)
  * [Saved CC, DC Payments (A.K.A. Tokenized payments)](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#saved-cc-dc-payments-aka-tokenized-payments)
  * [Loading Money into Users Citrus Prepaid Account](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#loading-money-into-users-citrus-prepaid-account)
  * [Paying via Prepaid account](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#paying-via-prepaid-accountcitrus-cash)
  * [Initiate Cashout Proccess into users Account from Citrus prepaid account](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#initiate-cashout-process-into-users-account-from-citrus-prepaid-account)
  * [Fetch Available Schemes and Banks for the Merchant](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#fetch-available-schemes-and-banks-for-the-merchant)
  * [Fetch the PG Health](https://github.com/citruspay/open-ios/wiki/3.--Integrating-CTSPaymentLayer#fetch-the-pg-health)

=====
####[Common Integration Issues](https://github.com/citruspay/open-ios/wiki/4.-Common-Errors)
* [Could Not Connect to Internet](https://github.com/citruspay/open-ios/wiki/4.-Common-Errors#could-not-connect-to-internet)
* [postResponseiOS() error](https://github.com/citruspay/open-ios/wiki/4.-Common-Errors#postresponseios-error)





