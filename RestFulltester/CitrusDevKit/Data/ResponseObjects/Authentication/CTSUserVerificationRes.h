//
//  CTSUserVerificationRes.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 14/11/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
//{"respCode":"201","respMsg":"User with principal <test@te.com> does not exists","status":false,"userType":"EMAIL"}
@interface CTSUserVerificationRes : JSONModel
@property(nonatomic,assign)int respCode;
@property(nonatomic)NSString *respMsg,*userType;
@property BOOL status;

@property(nonatomic,strong) NSError <Ignore>*error;

-(NSError *)convertToError;

@end
