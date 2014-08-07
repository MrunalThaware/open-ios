//
//  ViewController.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTSAuthLayer.h"
#import "CTSOauthTokenRes.h"
#import "CTSProfileLayer.h"
#import "CTSAuthLayerConstants.h"
#import "CTSPaymentLayer.h"
#import "CitrusDevKit/CitrusSdk.h"

@class CTSOauthTokenRes;

@interface ViewController
    : UIViewController<CTSAuthenticationProtocol, CTSPaymentProtocol> {
  CTSAuthLayer* authLayer;
  CTSPaymentLayer* paymentlayerinfo;
  CTSContactUpdate* contactInfo;
  CTSProfileLayer* profileLayer;
}

@end
