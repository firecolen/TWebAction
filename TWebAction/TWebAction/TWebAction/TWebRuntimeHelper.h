//
//  TWebRuntimeHelper.h
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWebRuntimeHelper : NSObject


/**
 *  在运行时判断类中是否包含某个属性
 *
 *  @param class        类
 *  @param propertyName 属性名
 *
 *  @return 该属性是否存在
 */
+ (BOOL)isClass:(Class)class hasProperty:(NSString*)propertyName;

/**
 *  获取所有遵循了指定协议的类
 *
 *  @param protocol 要遵循的协议
 *
 *  @return 遵循了协议的类
 */
+ (NSArray *)getClassesThatConfirmToProtocol:(Protocol*)protocol;
@end

NS_ASSUME_NONNULL_END
