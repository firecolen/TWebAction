//
//  TCLWebGetLocation.m
//  TWebAction
//
//  Created by collen.zhang on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import "TCLWebGetLocation.h"
#import "TCLWebActionPathDefine.h"
#import "NSObject+TWebAction.h"

@implementation TCLWebGetLocation
+ (BOOL)canHandleWebAction:(NSString *)actionName {
    if ([TCLWebAction_BaseGetLocation isEqualToString:actionName]) {
        return YES;
        
    }
    return NO;
}

+ (id)createTargetWithWebAction:(TWebAction *)webAction {
    TCLWebGetLocation *model = [[TCLWebGetLocation alloc] init];
    model.actionName = webAction.actionName;
    model.callbackFunc = webAction.callbackFunc;
    return model;
}

- (void)handleWebActionWithHandler:(id)handler {
    
    //模拟异步请求
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"currentThread ========>%@",[NSThread currentThread]);
        sleep(2);
        [self test];
    });
    
}
- (void)test {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.webActionCallback) {
            TWebActionCallbackData *model = [[TWebActionCallbackData alloc] init];
            model.jsCallbackFunc = self.callbackFunc;
            model.status = 200;
            model.actionName = self.actionName;
            model.dictionary = @{@"latitude":@(23.65),
                                 @"longitude":@(113.23),
                                 };
            self.webActionCallback(model);
        }
    });
}
- (void)dealloc
{
    NSLog(@"===============> loaction dealloc");
}
@end
