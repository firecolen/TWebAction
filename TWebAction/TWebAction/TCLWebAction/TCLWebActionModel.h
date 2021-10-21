//
//  TCLWebActionModel.h
//  TWebAction
//
//  Created by collen.zhang on 2019/9/2.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCLWebActionModel : NSObject

/*
 操作名称
 */
@property(nonatomic, strong) NSString *actionName;

/*
 回调方法
 */
@property(nonatomic, strong) NSString *callbackFunc;
@end

NS_ASSUME_NONNULL_END
