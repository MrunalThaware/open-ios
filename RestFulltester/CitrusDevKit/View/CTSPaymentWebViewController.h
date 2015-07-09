//
//  PaymentWebViewController.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTSPaymentWebViewController : UIViewController <UIWebViewDelegate>
{
    UIActivityIndicatorView* indicator;
    BOOL transactionOver;
    UIAlertView *pleaseWait;
}
@property( strong) NSString *redirectURL,*returnUrl;
@property(assign) int reqId;
@property( strong) NSMutableDictionary *response;
-(void)finishWebView;
@end
