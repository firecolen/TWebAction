//
//  TWebActionProtocol.h
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TWebAction.h"
#import "NSObject+TWebAction.h"

@protocol TWebActionProtocol <NSObject>

/**
 是否能处理这个操作
 
 @param actionName 操作名称
 @return YES/NO
 */
+ (BOOL)canHandleWebAction:(NSString*)actionName;

/**
 处理这个操作
 
 @param handler handler
 */
- (void)handleWebActionWithHandler:(id)handler;

/**
 创建具体的实例
 
 @return id
 */
+ (id)createTargetWithWebAction:(TWebAction*)webAction;


@end

