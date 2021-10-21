//
//  TWebRuntimeHelper.m
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import "TWebRuntimeHelper.h"
#import <objc/runtime.h>

@implementation TWebRuntimeHelper

+ (BOOL)isClass:(Class)class hasProperty:(NSString *)propertyName {
    return (class_getProperty(class, [propertyName UTF8String]) != NULL);
}

+ (NSArray *)getClassesThatConfirmToProtocol:(Protocol *)protocol {
    NSMutableArray *classes = [NSMutableArray array];
    unsigned int classCount;
    Class* classList = objc_copyClassList(&classCount);
    
    int i;
    for (i = 0; i < classCount; i++) {
        const char *className = class_getName(classList[i]);
        Class thisClass = objc_getClass(className);
        if (class_conformsToProtocol(thisClass, protocol)) {
            [classes addObject:thisClass];
        }
    }
    free(classList);
    return classes;
}
@end
