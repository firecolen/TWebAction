//
//  TWebAction.h
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//  web操作基本信息

#import <Foundation/Foundation.h>
#import "NSObject+TWebAction.h"

typedef NS_ENUM(NSInteger, WebActionHandleType){
    HandleTypeCallFunction = 0,   //回调方法
    HandleTypeSaveFunction,       //保存方法
    HandleTypeSaveAndCallFunction //保存并回调方法
};
NS_ASSUME_NONNULL_BEGIN

@interface TWebAction : NSObject 

/**
 操作名称
 */
@property(nonatomic, strong) NSString* actionName;

/**
 js回调方法
 */
@property(nonatomic, strong) NSString* callbackFunc;

/**
 参数
 */
@property(nonatomic, strong) NSDictionary* params;

/**
 是否需要登录
 */
@property (nonatomic,assign) BOOL needlogin;


//@property (nonatomic,assign) NSInteger index;

/**
 通过runtime自动设值到对应VC的属性上；（需要key名与target的属性名、类型一致）
 */
@property (nonatomic,strong) NSDictionary *runtimeParam;

/**
 通过参数，创建对象
 
 @param params 参数
 @param callback 回调
 @return 对象
 */
+(instancetype)webActionFromParams:(NSDictionary*)params callback:(TWebActionCallback)callback;

/**
 通过操作名和参数，创建对象
 
 @param actionName web操作名称
 @param params 参数
 @param callback 回调
 @return 对象
 */
+(instancetype)webActionFromActionName:(NSString*)actionName params:(NSDictionary*)params callback:(TWebActionCallback)callback;

/**
 通过操作名和参数，创建对象
 
 @param actionName web操作名称
 @param runtimeParam runtime参数
 @param callback 回调
 @return 对象
 */
+(instancetype)webActionFromActionName:(NSString*)actionName runtimeParam:(NSDictionary*)runtimeParam callback:(TWebActionCallback)callback;

/**
 runtime设置给目标对象
 
 @param object 参数
 */
- (void)setValuesForObject:(id)object ;
@end

NS_ASSUME_NONNULL_END
