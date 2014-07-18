//
//  CTSProfilePaymentRes.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSProfilePaymentRes : NSObject
@property(nonatomic,strong)NSString *type,*defaultOption;
@property(nonatomic,strong)NSArray* paymentOptions;
@end
