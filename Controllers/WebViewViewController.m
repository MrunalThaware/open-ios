//
//  WebViewViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 09/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "WebViewViewController.h"
#import "CTSUtility.h"
#import "UIUtility.h"

@interface WebViewViewController ()

@property(nonatomic,strong) UIWebView *webview;

@end

@implementation WebViewViewController
@synthesize redirectURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
    if(responseDict){
        //responseDict> contains all the information related to transaction
        [self transactionComplete:responseDict];
    }
    
    
//    NSString *iosResponse = [webView stringByEvaluatingJavaScriptFromString:@"callTojavaFn3()"];
//    NSLog(@"callTojavaFn1() iosResponse %@",iosResponse);
    
    
//    id iosResponse2 = [webView stringByEvaluatingJavaScriptFromString:@"callToiOS()"];
//    NSLog(@"callToiOS() iosResponse %@",iosResponse2);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request url %@ scheme %@",[request URL],[[request URL] scheme]);
    //NSString *iosResponse = [webView stringByEvaluatingJavaScriptFromString:@"callTojavaFn()"];

    if ([[[request URL] scheme] isEqualToString:@"closewebview"]) {
        NSLog(@"found url");
    
    }
    NSArray* cookies =
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]];
    NSLog(@"cookie array:%@", cookies);
    [WebViewViewController isVerifyPage:[[request URL] absoluteString]];
    return YES;
}

+(BOOL)isVerifyPage:(NSString *)urlString{
    BOOL isVerifyPage = NO;
    if([urlString containsString:@"prepaid/pg/verify/"]){
        NSLog(@"not logged in");
        isVerifyPage = YES;
    }
    return isVerifyPage;
}


-(void)transactionComplete:(NSDictionary *)responseDictionary{
    if([responseDictionary valueForKey:@"TxStatus"] != nil){
            [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[responseDictionary valueForKey:@"TxStatus"] ]];
    }
    else{
        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n Response: %@",responseDictionary]];
    
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
