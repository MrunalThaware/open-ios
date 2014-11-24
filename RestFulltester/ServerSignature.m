//
//  ServerSignature.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 02/09/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "ServerSignature.h"
#import "CTSBill.h"

@implementation ServerSignature
+ (NSString*)getSignatureFromServerTxnId:(NSString*)txnId
                                  amount:(NSString*)amt {
    NSString* data =
    [NSString stringWithFormat:@"transactionId=%@&amount=%@", txnId, amt];
    NSURL* url = [[NSURL alloc]
                  initWithString:
                  [NSString
                   stringWithFormat:SIGNATURE_URL]];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [urlReq setHTTPMethod:@"POST"];
    
    NSError* error = nil;
    
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];
    NSString* signature = [[NSString alloc] initWithData:signatureData
                                                encoding:NSUTF8StringEncoding];
    NSLog(@"signature %@ ", signature);
    return signature;
}

+ (CTSBill*)getSampleBill{

    NSURL* url = [[NSURL alloc]
                  initWithString:
                  [NSString
                   stringWithFormat:@"http://103.13.97.20/citrus/sandbox/sign.php"]];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setHTTPMethod:@"POST"];
    
    NSError* error = nil;
    
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];

   NSString* billJson = [[NSString alloc] initWithData:signatureData
                                                encoding:NSUTF8StringEncoding];
    
    JSONModelError *jsonError;
   CTSBill* sampleBill = [[CTSBill alloc] initWithString:billJson
                                       error:&jsonError];
    NSLog(@"signature %@ ", sampleBill);
    return sampleBill;


}



@end
