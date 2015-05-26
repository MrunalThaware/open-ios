//
//  RedirectWebViewController.h
//  Citrus-Open-iOS-SDK-Sample-App
//
//  Created by Mukesh Patil on 31/12/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedirectWebViewController : UIViewController<UIWebViewDelegate>{
    NSString *redirectURL;
    UIActivityIndicatorView* indicator;
}
@property(nonatomic,strong) NSString *redirectURL;
@end
