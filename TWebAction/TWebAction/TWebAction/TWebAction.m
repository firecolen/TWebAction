//
//  TWebAction.m
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import "TWebAction.h"
#import "TWebActionManager.h"
#import "TWebRuntimeHelper.h"

@implementation TWebAction

/**
 web操作名称匹配
 
 @param actionName web操作方法名
 @return YES:NO
 */
- (BOOL)actionNameMatch:(NSString *)actionName{
    
    if (self.actionName && [self.actionName isEqualToString:actionName]) {
        return YES;
    }
    return NO;
}

+(instancetype)webActionFromParams:(NSDictionary*)params callback:(nonnull TWebActionCallback)callback{
    TWebAction *webAction = [[TWebAction alloc] init];
    webAction.params = params;
    
    webAction.actionName = params[@"name"];
    webAction.callbackFunc = params[@"callback"];
    webAction.webActionCallback = callback;
    return webAction;
}

+(instancetype)webActionFromActionName:(NSString*)actionName params:(NSDictionary*)params callback:(nonnull TWebActionCallback)callback{
    if (!actionName || ![actionName isKindOfClass:[NSString class]] || actionName.length == 0) {
        return nil;
    }
    TWebAction *webAction = [[TWebAction alloc] init];
    webAction.params = params;
    webAction.actionName = actionName;
    webAction.callbackFunc = params[@"callback"];
    webAction.webActionCallback = callback;
    return webAction;
}

+ (instancetype)webActionFromActionName:(NSString *)actionName runtimeParam:(NSDictionary *)runtimeParam callback:(nonnull TWebActionCallback)callback{
    
    TWebAction *webAction = [[TWebAction alloc] init];
    webAction.runtimeParam = runtimeParam;
    webAction.actionName = actionName;
    webAction.callbackFunc = runtimeParam[@"callback"];
    webAction.webActionCallback = callback;
    return webAction;
}

/**
 runtime设置给目标对象
 
 @param object 参数
 */
- (void)setValuesForObject:(id)object {
    if (self.runtimeParam && object) {
        for (id key in self.runtimeParam.allKeys) {
            if (![key isKindOfClass:[NSString class]]) {
                NSCAssert(NO, @"key:%@ 不是字符串",key);
                continue;
            }
            if (![TWebRuntimeHelper isClass:[object class] hasProperty:key]) {
                NSCAssert(NO, @"key:%@ 不存在 ",key);
                continue;
            }
            
            id value = [self.runtimeParam objectForKey:key];
            NSError *error = nil;
            if (![object validateValue:&value forKey:key error:&error]) {
                NSCAssert(NO, @"value:%@ 类型错误,key:%@",value,key);
                continue;
            } else {
                [object setValue:value forKey:key];
            }
        }
    }
}

@end
