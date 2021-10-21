//
//  NSObject+TWebAction.h
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/22.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWebActionCallbackData;
NS_ASSUME_NONNULL_BEGIN

typedef void (^TWebActionCallback)(TWebActionCallbackData *data);

@interface NSObject (TWebAction)

@property (nonatomic, copy)TWebActionCallback __nullable webActionCallback;

@end


@interface TWebActionCallbackData : NSObject

//回调方法
@property (nonatomic, strong) NSString *jsCallbackFunc;

//回调 方法+json
@property (nonatomic, strong, readonly) NSString *jsCallback;


/*
 状态值
 200：成功
 -1：失败
 500：APP业务异常
 404：没有该JS API
 xxx：业务自定义异常
 */
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *actionName;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, strong) NSDictionary *dictionary;

@end
NS_ASSUME_NONNULL_END
