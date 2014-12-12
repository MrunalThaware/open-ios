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
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *field =  [webView stringByEvaluatingJavaScriptFromString:@"var field = document.getElementById('field_2');"
     "field.value='Multiple statements - OK';"];
    
    
    [webView stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function myFunction() { "
     "var field = document.getElementById('field_3');"
     "field.value='Calling function - OK';"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    
   NSString *field2 = [webView stringByEvaluatingJavaScriptFromString:@"myFunction();"];
    NSString *iosResponse = [webView stringByEvaluatingJavaScriptFromString:@"postResponseiOS()"];

    NSLog(@" title %@ ",title);
    NSLog(@" field %@ ",field);
    NSLog(@" field2 %@ ",field2);
    NSLog(@" iosResponse %@ ",iosResponse);


}

- (BOOL)webView:(UIWebView*)webView
shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSDictionary* responseDict =
    [CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody];
    NSLog(@" request final %@ ",request.URL);
    if (responseDict != nil) {
        //your code for success goes here
        //responseDict> contains all the information related to transaction
        [self transactionComplete:responseDict];
    }
    
    return YES;
}

-(void)transactionComplete:(NSDictionary *)responseDictionary{
    [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n txStatus: %@",[responseDictionary valueForKey:@"TxStatus"] ]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
