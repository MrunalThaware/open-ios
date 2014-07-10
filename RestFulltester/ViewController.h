//
//  ViewController.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "CTSAuthLayer.h"
#import "CTSProfileLayer.h"
#import "CTSPaymentLayer.h"
#import "CTSOauthTokenRes.h"
#import "CTSAuthLayerConstants.h"
#import "Logging.h"
#import "CTSPaymentDetailUpdate.h"
#import "CTSContactUpdate.h"
#import "CTSProfileLayerConstants.h"

@class CTSOauthTokenRes;
@protocol sampleDelegate<NSObject>
@required
- (NSString*)getDataValue;
@end

@interface ViewController : UIViewController<CTSAuthenticationProtocol,
                                             CTSProfileProtocol,
                                             CTSPaymentProtocol> {
  CTSProfileLayer* profileService;
  CTSPaymentLayer* paymentlayerinfo;
  CTSAuthLayer* authLayer;
}
@property(strong) CTSOauthTokenRes* subRes;
@property(readwrite, assign) id<sampleDelegate> delegate;

@end
