//
//  TCLWebCallPhone.m
//  TWebAction
//
//  Created by collen.zhang on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import "TCLWebCallPhone.h"

#import "TCLWebActionPathDefine.h"

@implementation TCLWebCallPhone


+ (BOOL)canHandleWebAction:(NSString *)actionName {
    if ([TCLWebAction_BaseCallPhone isEqualToString:actionName]) {
        return YES;
    }
    return NO;
}

+ (id)createTargetWithWebAction:(TWebAction *)webAction {
    TCLWebCallPhone *callPhone = [[TCLWebCallPhone alloc] init];
    callPhone.actionName = webAction.actionName;
    callPhone.phoneNumber = webAction.params[@"phoneNumber"];
    return callPhone;
}


- (void)handleWebActionWithHandler:(id)handler {
//    NSURL *phone = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.phoneNumber]];
    NSLog(@"js call oc handle : call phone - %@",self.phoneNumber);
    self.webActionCallback(nil);
    //    if ([[UIApplication sharedApplication] canOpenURL:phone]) {
    //        [[UIApplication sharedApplication] openURL:phone];
    //    }
}
- (void)dealloc
{
    NSLog(@"===============> phone dealloc");
}
@end
