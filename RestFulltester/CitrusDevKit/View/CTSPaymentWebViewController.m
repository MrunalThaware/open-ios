//
//  PaymentWebViewController.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSPaymentWebViewController.h"
#import "CTSUtility.h"
#import "UIUtility.h"
#import "CTSError.h"
#import "CTSPaymentLayer.h"

@interface CTSPaymentWebViewController ()
@property( strong) UIWebView *webview;
@end

@implementation CTSPaymentWebViewController
@synthesize redirectURL,reqId,response;

#define toNSString(cts) [NSString stringWithFormat:@"%d", cts]

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
    NSLog(@" viewDidLoad ");
    LogThread
    self.title = @"3D Secure";
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    self.webview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webview.backgroundColor = [UIColor orangeColor];
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(160, 300, 30, 30);
    [self.view addSubview:self.webview];
    [self.webview addSubview:indicator];
    transactionOver = NO;
    [self.webview loadRequest:[[NSURLRequest alloc]
                               initWithURL:[NSURL URLWithString:redirectURL]]];
    
    
    //    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissController)];
    //
    //
    //    self.navigationController.navigationItem.leftBarButtonItem = closeButton;
    //
    //
    
    [self addBackButton];
}



-(void)addBackButton{
    UIButton*back = [UIButton buttonWithType:UIButtonTypeSystem];
    [back addTarget:self action:@selector(promptForCancelTransaction) forControlEvents:UIControlEventTouchUpInside];
    back.frame = CGRectMake(10, 10, 50, 22);
//    back.frame = CGRectMake(0, 0, 34, 26);
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:back ];
}

-(void)dismissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@" view will desappear ");
    LogThread

    [super viewWillDisappear:animated];
    [self finishWebView];
    if(transactionOver == NO){
        NSDictionary* responseDict = [CTSUtility errorResponseTransactionForcedClosedByUser];
        if(responseDict){
            [self transactionComplete:(NSMutableDictionary *)responseDict];
        }
    }
}

#pragma mark - webview delegates

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    LogTrace(@"error %@ ",error);
    [self transactionComplete:(NSMutableDictionary *)[CTSUtility errorResponseDeviceOffline:error]];

}

- (void)webViewDidStartLoad:(UIWebView*)webView {
    NSLog(@" webViewDidStartLoad ");
    LogThread
    NSLog(@"webView  URL %@",[webView.request URL].absoluteString);
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    
    NSLog(@" webViewDidFinishLoad ");
    LogThread
    NSURL *currentURL = [[webView request] URL];

    [indicator stopAnimating];
    if(reqId != PaymentChargeInnerWebLoadMoneyReqId){
        NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
        NSLog(@"currentURL %@ return url %@",[currentURL description], _returnUrl);
        responseDict = [CTSUtility errorResponseIfReturnUrlDidntRespond:_returnUrl webViewUrl:[currentURL absoluteString] currentResponse:responseDict];
        if(responseDict){
            [self transactionComplete:(NSMutableDictionary *)responseDict];
        }
    }
    else{
        if([CTSUtility isURL:currentURL toUrl:[NSURL URLWithString:_returnUrl]]){
            NSArray *loadMoneyResponse = [CTSUtility getLoadResponseIfSuccesfull:[webView request]];
            NSDictionary *loadMoneyResponseDict = [NSDictionary dictionaryWithObject:loadMoneyResponse forKey:LoadMoneyResponeKey];
            transactionOver = YES;
            [self transactionComplete:(NSMutableDictionary *)loadMoneyResponseDict];
        }
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
   
    NSLog(@" shouldStartLoadWithRequest ");
    
    LogThread
    NSLog(@"request url %@ scheme %@",[request URL],[[request URL] scheme]);
    //  for load balance return url finish
//    NSLog(@"reqId %d",reqId);
//    if(reqId == PaymentChargeInnerWebLoadMoneyReqId){
//        NSArray *loadMoneyResponse = [CTSUtility getLoadResponseIfSuccesfull:request];
 //       NSLog(@"loadMoneyResponse %@",loadMoneyResponse);
//        if(loadMoneyResponse){
//            LogTrace(@"loadMoneyResponse %@",loadMoneyResponse);
//            NSDictionary *loadMoneyResponseDict = [NSDictionary dictionaryWithObject:loadMoneyResponse forKey:LoadMoneyResponeKey];
//            [self transactionComplete:(NSMutableDictionary *)loadMoneyResponseDict];
//        }
//    }
    
    
    NSLog(@"response Should %@",[CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody]);
    
    return YES;
}


#pragma mark - Payment handler

-(void)transactionComplete:(NSMutableDictionary *)responseDictionary{
    NSLog(@" transactionComplete ");
    LogThread
    [pleaseWait dismissWithClickedButtonIndex:10 animated:YES];

    transactionOver = YES;
    responseDictionary = [NSMutableDictionary dictionaryWithDictionary:responseDictionary];
    [self finishWebView];
    [responseDictionary setValue:toNSString(reqId) forKey:@"reqId"];
    [self setValue:responseDictionary forKey:@"response"];
}


-(void)finishWebView{
    NSLog(@" finishWebView ");
    LogThread
    if( [self.webview isLoading]){
        [self.webview stopLoading];
    }
    [self.webview removeFromSuperview];
    self.webview.delegate = nil;
    self.webview = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


-(void)promptForCancelTransaction{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Do you Really Want to Cancel the Transaction?" delegate:self cancelButtonTitle:@"NO"otherButtonTitles:@"YES", nil];
        
        alert.tag = 1;
        [alert show];
    });
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:10 animated:YES];

    NSLog(@"clicked button %d",buttonIndex);
    if(buttonIndex == 0){
    }
    else if (buttonIndex == 1){
       // [self pleaseWaitPrompt];
        [self cancelTransaction];
    }
}


-(void)pleaseWaitPrompt{
    dispatch_async(dispatch_get_main_queue(), ^{
        pleaseWait = [[UIAlertView alloc] initWithTitle:@"Please Wait !" message:@"Safely Ending the Transaction ..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [pleaseWait show];
    });

}

-(void)cancelTransaction{
    LogThread
    if(transactionOver == NO){
    NSLog(@" CancelTransaction ");
    if( [self.webview isLoading]){
        [self.webview stopLoading];
    }
    [self.webview loadRequest:[[NSURLRequest alloc]
                               initWithURL:[NSURL URLWithString:redirectURL]]];
    }
}
@end
