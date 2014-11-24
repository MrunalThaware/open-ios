//
//  SimpleStartViewController.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/11/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface SimpleStartViewController : UIViewController{
    CTSAuthLayer *authLayer;
    CTSProfileLayer *proifleLayer;
    CTSPaymentLayer *paymentLayer;
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
}

@end
