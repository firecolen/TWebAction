//
//  TWebActionManager.h
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//  WebAction管理类

#import <Foundation/Foundation.h>
#import "TWebActionProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@class TWebAction;

@interface TWebActionManager : NSObject
/**
 TRouterManager实例
 
 @return return value description
 */
+ (instancetype)sharedManager;

/**
 创建对象
 
 @param webAction 操作类
 @return 实现协议的对象
 */
-(id<TWebActionProtocol>)createTargetWithWebAction:(TWebAction*)webAction;


@end

NS_ASSUME_NONNULL_END
