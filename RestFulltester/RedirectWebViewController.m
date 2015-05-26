//
//  RedirectWebViewController.m
//  Citrus-Open-iOS-SDK-Sample-App
//
//  Created by Mukesh Patil on 31/12/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "RedirectWebViewController.h"
#import "CTSUtility.h"
#import "UIUtility.h"

@interface RedirectWebViewController ()
@property(nonatomic,strong) UIWebView *webview;
@end

@implementation RedirectWebViewController
@synthesize redirectURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"3D Secure";
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    self.webview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webview.backgroundColor = [UIColor redColor];
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(160, 300, 30, 30);
    [self.view addSubview:self.webview];
    [self.webview addSubview:indicator];
    
    [self.webview loadRequest:[[NSURLRequest alloc]
                               initWithURL:[NSURL URLWithString:redirectURL]]];
}

#pragma mark - webview delegates

- (void)webViewDidStartLoad:(UIWebView*)webView {
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [indicator stopAnimating];
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
    if(responseDict){
        //responseDict> contains all the information related to transaction
        [self transactionComplete:responseDict];
    }
}


-(void)transactionComplete:(NSDictionary *)responseDictionary{
    if([responseDictionary valueForKey:@"TxStatus"] != nil){
        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[responseDictionary valueForKey:@"TxStatus"] ]];
    }
    else{
        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n Response: %@",responseDictionary]];
    }
}

@end
