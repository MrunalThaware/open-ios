//
//  PrepaidViewController.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 11/03/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface PrepaidViewController : UIViewController{
    CTSAuthLayer *authLayer;
    CTSProfileLayer *proifleLayer;
    CTSPaymentLayer *paymentLayer;
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
    int seedState;
    NSDictionary *customParams;
}
@end
