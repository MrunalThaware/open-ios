//
//  CTSRestRequest.h
//  CTSRestKit
//
//  Created by Yadnesh Wankhede on 30/07/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <Foundation/Foundation.h>
// typedef enum HTTPMethod { GET, POST, PUT, DELETE } HTTPMethod;

@interface CTSRestCoreRequest : NSObject
@property(strong) NSString* requestJson, *urlPath;
@property(strong) NSDictionary* parameters, *headers;
@property(assign) int requestId;
@property(assign) HTTPMethod httpMethod;
- (instancetype)initWithPath:(NSString*)path
                   requestId:(int)reqId
                     headers:(NSDictionary*)reqHeaders
                  parameters:(NSDictionary*)params
                        json:(NSString*)json
                  httpMethod:(HTTPMethod)method;

@end
