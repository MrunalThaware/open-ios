//
//  CTSRestCore.m
//  CTSRestKit
//
//  Created by Yadnesh Wankhede on 29/07/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CTSRestCore.h"
#import "NSObject+logProperties.h"
#import "CTSAuthLayerConstants.h"
#import "CTSPaymentLayer.h"

@implementation CTSRestCore
@synthesize baseUrl, delegate;

- (instancetype)initWithBaseUrl:(NSString*)url {
  self = [super init];
  if (self) {
    baseUrl = url;
    finished = YES;
  }
  return self;
}

// request to server
- (void)requestAsyncServer:(CTSRestCoreRequest*)restRequest {
//  NSMutableURLRequest* request = [CTSRestCore toNSMutableRequest:restRequest withBaseUrl:baseUrl];

    NSMutableURLRequest* request;
    if (restRequest.requestId != GetVaultTokenReqId) {
        request = [CTSRestCore toNSMutableRequest:restRequest withBaseUrl:baseUrl];
    }else{
        if ([baseUrl isEqualToString:PRODUCTION_BASEURL]) {
            request = [CTSRestCore toNSMutableRequest:restRequest withBaseUrl:VAULT_PRODUCTION_BASEURL];
        }else{
            request = [CTSRestCore toNSMutableRequest:restRequest withBaseUrl:VAULT_TEST_BASEURL];
        }
    }

  __block int requestId = restRequest.requestId;

  NSOperationQueue* mainQueue = [[NSOperationQueue alloc] init];
  [mainQueue setMaxConcurrentOperationCount:5];

  __block id<CTSRestCoreDelegate> blockDelegate = delegate;
  __block long dataIndex = restRequest.index;
  LogDebug(@"URL > %@ ", request);
  LogDebug(@"restRequest JSON> %@", restRequest.requestJson);

  [NSURLConnection
      sendAsynchronousRequest:request
                        queue:mainQueue
            completionHandler:^(NSURLResponse* response,
                                NSData* data,
                                NSError* connectionError) {
                CTSRestCoreResponse* restResponse =
                    [CTSRestCore toCTSRestCoreResponse:response
                                          responseData:data
                                                 reqId:requestId
                                             dataIndex:dataIndex];
                [blockDelegate restCore:self didReceiveResponse:restResponse];
            }];
}


-(void)requestAsyncServerDelegation:(CTSRestCoreRequest *)restRequest{
    
    NSMutableURLRequest* request =
    [CTSRestCore toNSMutableRequest:restRequest withBaseUrl:baseUrl];
    
    delegationRequestId = restRequest.requestId;
    
    LogDebug(@"URL > %@ ", request);
    LogDebug(@"restRequest JSON> %@", restRequest.requestJson);
    
    
    NSURLConnection *urlConn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [urlConn start];
    
    while(finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

+ (CTSRestCoreResponse*)requestSyncServer:(CTSRestCoreRequest*)restRequest
                              withBaseUrl:(NSString*)baseUrl {
  NSMutableURLRequest* request =
      [CTSRestCore toNSMutableRequest:restRequest withBaseUrl:baseUrl];
  NSError* connectionError = nil;
  NSURLResponse* response = nil;

  NSData* data = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:&response
                                                   error:&connectionError];

  CTSRestCoreResponse* restResponse =
      [CTSRestCore toCTSRestCoreResponse:response
                            responseData:data
                                   reqId:restRequest.requestId
                               dataIndex:restRequest.index];

  return restResponse;
}

+ (NSMutableURLRequest*)fetchDefaultRequestForPath:(NSString*)path
                                          withBase:(NSString*)baseUrlArg {
  NSURL* serverUrl = [NSURL
      URLWithString:[NSString stringWithFormat:@"%@%@", baseUrlArg, path]];

  return [NSMutableURLRequest requestWithURL:serverUrl
                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                             timeoutInterval:30.0];
}

+ (NSMutableURLRequest*)requestByAddingHeaders:(NSMutableURLRequest*)request
                                       headers:(NSDictionary*)headers {
  for (NSString* key in [headers allKeys]) {
    LogDebug(@" setting header %@, for key %@", [headers valueForKey:key], key);
    [request addValue:[headers valueForKey:key] forHTTPHeaderField:key];
  }
  return request;
}

+ (NSMutableURLRequest*)requestByAddingParameters:(NSMutableURLRequest*)request
                                       parameters:(NSDictionary*)parameters {
  if (parameters != nil)
    [request setHTTPBody:[[self serializeParams:parameters]
                             dataUsingEncoding:NSUTF8StringEncoding]];
  return request;
}

#pragma mark - helper methods

+ (NSString*)getHTTPMethodFor:(HTTPMethod)methodType {
  switch (methodType) {
    case GET:
      return @"GET";
      break;
    case POST:
      return @"POST";
      break;
    case PUT:
      return @"PUT";
      break;
    case DELETE:
      return @"DELETE";
      break;
  }
}

+ (NSString*)serializeParams:(NSDictionary*)params {
  NSMutableArray* pairs = NSMutableArray.array;
  for (NSString* key in params.keyEnumerator) {
    id value = params[key];
    if ([value isKindOfClass:[NSDictionary class]])
      for (NSString* subKey in value)
        [pairs addObject:[NSString stringWithFormat:
                                       @"%@[%@]=%@",
                                       key,
                                       subKey,
                                       [self escapeValueForURLParameter:
                                                 [value objectForKey:subKey]]]];

    else if ([value isKindOfClass:[NSArray class]])
      for (NSString* subValue in value)
        [pairs addObject:[NSString
                             stringWithFormat:
                                 @"%@[]=%@",
                                 key,
                                 [self escapeValueForURLParameter:subValue]]];

    else
      [pairs addObject:[NSString stringWithFormat:
                                     @"%@=%@",
                                     key,
                                     [self escapeValueForURLParameter:value]]];
  }
  return [pairs componentsJoinedByString:@"&"];
}

+ (NSString*)escapeValueForURLParameter:(NSString*)valueToEscape {
  return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(
      NULL,
      (__bridge CFStringRef)valueToEscape,
      NULL,
      (CFStringRef) @"!*'();:@&=+$,/?%#[]",
      kCFStringEncodingUTF8);
}

+ (BOOL)isHttpSucces:(int)statusCode {
  return [statusCodeIndexSetForClass(CTSStatusCodeClassSuccessful)
      containsIndex:statusCode];
}

NSIndexSet* statusCodeIndexSetForClass(CTSStatusCodeClass statusCodeClass) {
  return [NSIndexSet
      indexSetWithIndexesInRange:statusCodeRangeForClass(statusCodeClass)];
}

NSRange statusCodeRangeForClass(CTSStatusCodeClass statusCodeClass) {
  return NSMakeRange(statusCodeClass, CTSStatusCodeRangeLength);
}

+ (NSMutableURLRequest*)toNSMutableRequest:(CTSRestCoreRequest*)restRequest
                               withBaseUrl:(NSString*)baseUrlArg {
  NSMutableURLRequest* request =
      [CTSRestCore fetchDefaultRequestForPath:restRequest.urlPath
                                     withBase:baseUrlArg];
  [restRequest logProperties];

  [request setHTTPMethod:[self getHTTPMethodFor:restRequest.httpMethod]];

  request = [self requestByAddingParameters:request
                                 parameters:restRequest.parameters];

    
  if (restRequest.requestJson != nil) {
    if (restRequest.headers == nil)
      restRequest.headers = [[NSMutableDictionary alloc] init];
    [restRequest.headers setObject:@"application/json" forKey:@"Content-Type"];
    [request setHTTPBody:[restRequest.requestJson
                             dataUsingEncoding:NSUTF8StringEncoding]];
  }

  request = [self requestByAddingHeaders:request headers:restRequest.headers];
  return request;
}

+ (CTSRestCoreResponse*)toCTSRestCoreResponse:(NSURLResponse*)response
                                 responseData:(NSData*)data
                                        reqId:(int)requestId
                                    dataIndex:(long)dataIndex {
  CTSRestCoreResponse* restResponse = [[CTSRestCoreResponse alloc] init];
  NSError* error = nil;
  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
  LogDebug(@"allHeaderFields %@", [httpResponse allHeaderFields]);
  int statusCode = (int)[httpResponse statusCode];
  if (![self isHttpSucces:statusCode]) {
    error = [CTSError getServerErrorWithCode:statusCode withInfo:nil];
  }
  restResponse.responseString =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  restResponse.requestId = requestId;
  restResponse.error = error;
  restResponse.indexData = dataIndex;
  [restResponse logProperties];
  return restResponse;
}

#pragma mark - NSURLConnection Delegates
- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) redirectResponse
{
    
    LogDebug(@"connection %@",connection);
    
    LogDebug(@"redirect request %@",request);
    LogDebug(@"redirect redirectResponse %@",redirectResponse);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) redirectResponse;
    
    if (redirectResponse !=nil && httpResponse.statusCode == 302 ) {
        request = nil;
        
        
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response{
    
    LogDebug(@"didReceiveResponse response %@",response);
    CTSRestCoreResponse *restResponse = [[CTSRestCoreResponse alloc] init];
    restResponse.requestId = delegationRequestId;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    
    if (response !=nil && httpResponse.statusCode == 302 ) {
        NSArray* httpscookies =
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[response URL]];
        NSHTTPCookie* cookie = [httpscookies objectAtIndex:1];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        restResponse.data = nil;
        
    }
    else{
        
        NSError *error;

        if([CTSRestCore isVerifyPage:[[response URL] absoluteString]]){
            error = [CTSError errorForStatusCode:1000];
        }else {
            error = [CTSError errorForStatusCode:(int)httpResponse.statusCode];
        }
        
        restResponse.requestId = delegationRequestId;
        restResponse.data = error;

    }
    [delegate restCore:self didReceiveResponse:restResponse];
}


+(BOOL)isVerifyPage:(NSString *)urlString{
    BOOL isVerifyPage = [CTSRestCore myContainsString:urlString];
    
    if(isVerifyPage){
        isVerifyPage = YES;
    }
    return isVerifyPage;
}

+ (BOOL)myContainsString:(NSString*)other {
    NSRange range = [other rangeOfString:MLC_CITRUS_PAY_AUTH_COOKIE_PATH];
    return range.length != 0;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    finished = TRUE;
}


@end
