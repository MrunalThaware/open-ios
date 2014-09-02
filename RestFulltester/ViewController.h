//
//  ViewController.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusDevKit/CitrusSdk.h"

@interface ViewController : UIViewController<CTSAuthenticationProtocol,
                                             CTSPaymentProtocol,
                                             CTSProfileProtocol> {
  CTSAuthLayer* authLayer;
  CTSPaymentLayer* paymentlayerinfo;
  CTSContactUpdate* contactInfo;
  CTSProfileLayer* profileLayer;
  CTSUserAddress* addressInfo;

  CTSProfilePaymentRes* paymentSavedResponse;
}

@end
