//
//  CTSResponseData.m
//  CitrusPay-iOS-SDK
//
//  Created by Mukesh Patil on 26/06/15.
//  Copyright (c) 2015 CitrusPay. All rights reserved.
//

#import "CTSResponseData.h"
#import "NSObject+logProperties.h"

@implementation CTSResponseData
+ (CTSResponseData*)returnCTSResponseDataObjectModel:(id)JSON{
    CTSResponseData* resultObject;
    if (JSON) {
        JSONModelError* jsonError;
        resultObject = [[CTSResponseData alloc] initWithDictionary:JSON
                                                             error:&jsonError];
        [resultObject logProperties];
    }else{
        resultObject = [[CTSResponseData alloc] init];
        resultObject.responseCode = @"R-201-07";
        resultObject.responseMessage = @"success";
        resultObject.responseData = nil;
    }
    return resultObject;
}
@end
