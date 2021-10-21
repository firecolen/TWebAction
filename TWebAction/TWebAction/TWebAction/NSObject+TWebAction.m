//
//  NSObject+TWebAction.m
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/22.
//  Copyright © 2019 admin. All rights reserved.
//

#import "NSObject+TWebAction.h"
#import <objc/runtime.h>

static void *kWebActionCallback = "webActionCallback";

@implementation NSObject (TWebAction)

-(_Nullable TWebActionCallback)webActionCallback{
    return objc_getAssociatedObject(self, kWebActionCallback);
}

-(void)setWebActionCallback:(TWebActionCallback _Nullable)webActionCallback{
    objc_setAssociatedObject(self, kWebActionCallback, webActionCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


@implementation TWebActionCallbackData

@synthesize jsCallback = _jsCallback;

- (NSString *)jsCallback{
    if (_jsCallbackFunc) {
        NSString *json = [self toJson];
        if (!json) {
            json = @"";
        }
        _jsCallback = [NSString stringWithFormat:@"%@('%@')", _jsCallbackFunc, json];
    }
    return _jsCallback;
}

-(NSString*)toJson{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@(self.status) forKey:@"status"];
    [dic setValue:self.dictionary?self.dictionary:@{} forKey:@"data"];
    [dic setValue:self.errorMsg?self.errorMsg:@"" forKey:@"errorMsg"];
    [dic setValue:self.actionName?self.actionName:@"" forKey:@"callbackId"];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end

