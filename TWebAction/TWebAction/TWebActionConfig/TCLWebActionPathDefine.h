//
//  TCLWebActionPathDefine.h
//  TWebAction
//
//  Created by collen.zhang on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const TCLWebJSbridge;//js桥接

extern NSString* const TCLWebAction_BaseCache;//缓存
extern NSString* const TCLWebAction_BaseGoAppstore;//去应用商店
extern NSString* const TCLWebAction_BaseCallPhone;//地图获取经纬度
extern NSString* const TCLWebAction_BaseGetLocation;//打电话
extern NSString* const TCLWebAction_BaseRouter;//路由能力

@interface TCLWebActionPathDefine : NSObject

@end

NS_ASSUME_NONNULL_END
