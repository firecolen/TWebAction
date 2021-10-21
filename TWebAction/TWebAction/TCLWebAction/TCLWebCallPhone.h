//
//  TCLWebCallPhone.h
//  TWebAction
//
//  Created by collen.zhang on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWebActionProtocol.h"
#import "TCLWebActionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TCLWebCallPhone : TCLWebActionModel<TWebActionProtocol>

@property(nonatomic, strong) NSString *phoneNumber;

@end

NS_ASSUME_NONNULL_END
