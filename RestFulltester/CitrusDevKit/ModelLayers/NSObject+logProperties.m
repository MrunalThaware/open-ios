//
//  NSObject+logProperties.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "NSObject+logProperties.h"
#import "NSObject+logProperties.h"
#import <objc/runtime.h>

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif
@implementation NSObject (logProperties)
- (void)logProperties {
  DDLogInfo(@"----------------------------------------------- Properties for "
            @"object %@",
            self);

  @autoreleasepool {
    unsigned int numberOfProperties = 0;
    objc_property_t* propertyArray =
        class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
      objc_property_t property = propertyArray[i];
      NSString* name =
          [[NSString alloc] initWithUTF8String:property_getName(property)];
      DDLogInfo(@"Property %@ Value: %@", name, [self valueForKey:name]);
    }
    free(propertyArray);
  }
  DDLogInfo(@"-----------------------------------------------");
}
@end
