//
//  ServerSignature.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 02/09/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define SIGNATURE_URL @"http://sandbox.citruspay.com/namo/sign.php"
//#define SIGNATURE_URL @"http://localhost:8888/sign.php"
//#define SIGNATURE_URL @"http://um.citruspay.com/sign.php"
//#define SIGNATURE_URL @"https://testbilladmin.citruspay.com/sign.php"

//#define SIGNATURE_URL  @"http://testbilladmin.citruspay.com/rio/sign.php"

//#define SIGNATURE_URL  @"http://testbilladmin.citruspay.com/rio/sign.php"
#define SIGNATURE_URL  @"http://192.168.2.105:8888/sign.php"

//working staging
//#define SIGNATURE_URL @"http://testbilladmin.citruspay.com/billpayadmin/sign.php"

@interface ServerSignature : NSObject
+ (NSString*)getSignatureFromServerTxnId:(NSString*)txnId amount:(NSString*)amt;
@end
