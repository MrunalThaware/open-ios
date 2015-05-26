//
//  CTSMobileVerifiactionRes.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 18/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface CTSMobileVerifiactionRes : JSONModel
@property(nonatomic)NSString *responseCode, *responseMessage;
@property(nonatomic)NSDictionary *responseData;
@end
