//
//  PaymentWebViewController.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentWebViewController : UIViewController <UIWebViewDelegate>
{
    NSString* redirectURL;
    UIActivityIndicatorView* indicator;
    
    
}
@property(nonatomic,strong) NSString *redirectURL;

@end
