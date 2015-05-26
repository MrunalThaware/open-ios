//
//  SampleViewController.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 08/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface SampleViewController : UIViewController{
    CTSAuthLayer* authLayer;
    CTSPaymentLayer* paymentlayerinfo;
    CTSContactUpdate* contactInfo;
    CTSProfileLayer* profileLayer;
    CTSUserAddress* addressInfo;
    NSDictionary *customParams;
}

@end
