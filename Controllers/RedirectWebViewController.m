//
//  WebViewViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 09/09/14.
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    NSLog(@"webView %@",[webView.request URL].absoluteString);
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [indicator stopAnimating];
    
    //for payment proccessing return url finish
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
    if(responseDict){
        //responseDict> contains all the information related to transaction
        [self transactionComplete:responseDict];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request url %@ scheme %@",[request URL],[[request URL] scheme]);

    //for load balance return url finish
    NSArray *loadMoneyResponse = [CTSUtility getLoadResponseIfSuccesfull:request];
    NSLog(@"loadMoneyResponse %@",loadMoneyResponse);
    if(loadMoneyResponse){
        LogTrace(@"loadMoneyResponse %@",loadMoneyResponse);

        [self loadMoneyComplete:loadMoneyResponse];
    }
    
    
    
    //for general payments
  //  NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody];
//    if(responseDict){
//        //responseDict> contains all the information related to transaction
//        [self transactionComplete:responseDict];
//    }
    
    return YES;
    
}



-(void)transactionComplete:(NSDictionary *)responseDictionary{
    if([responseDictionary valueForKey:@"TxStatus"] != nil){
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[responseDictionary valueForKey:@"TxStatus"] ]];
    }
    else{
        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n Response: %@",responseDictionary]];
    
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    [self finishWebView];
}


-(void)loadMoneyComplete:(NSArray *)resPonseArray{
    [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" load Money Complete\n Response: %@",resPonseArray]];
    [self.navigationController popViewControllerAnimated:YES];

}


-(void)finishWebView{
    
    if( [self.webview isLoading]){
        [self.webview stopLoading];
    }
    [self.webview removeFromSuperview];
    self.webview.delegate = nil;
    self.webview = nil;
}
@end
