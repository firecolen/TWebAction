//
//  TWebActionManager.m
//  HouseKeeper
//
//  Created by collen.zhang on 2019/8/21.
//  Copyright © 2019 admin. All rights reserved.
//


#import "TWebActionManager.h"
#import "TWebRuntimeHelper.h"
#import "TWebAction.h"
#import "NSObject+TWebAction.h"

@interface TWebActionManager ()

@property (nonatomic, strong) NSArray *webActionClasses;
@property (nonatomic, strong) NSCache *classMapCache;

//JS的方法保存，
@property (nonatomic, strong) NSMutableDictionary *jsFunctionDic;

@end

TWebActionManager *_sharedInstance = nil;
@implementation TWebActionManager

#pragma mark - 初始化
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TWebActionManager alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //动态获取所有遵循了TWebActionProtocol的类
        
        _webActionClasses = [TWebRuntimeHelper getClassesThatConfirmToProtocol:@protocol(TWebActionProtocol)];
        _classMapCache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - 创建具体的webAction实现类
/**
 创建对象
 
 @param webAction 操作类
 @return 实现协议的对象
 */
-(id<TWebActionProtocol>)createTargetWithWebAction:(TWebAction*)webAction{
    if (!webAction) {
        return nil;
    }
    
    Class class = [self findClassForWebAction:webAction];
    if (!class) {
        return nil;
    }
    
    return [self createTargetForWebAction:webAction withClass:class];
}

/**
 根据webAction查找对应的类名
 
 @param webAction 操作类
 @return class
 */
- (Class)findClassForWebAction:(TWebAction *)webAction {
    NSString *actionName = webAction.actionName;
    if (!actionName || ![actionName isKindOfClass:[NSString class]] || actionName.length == 0) {
        return nil;
    }
    
    Class cacheClass = [self.classMapCache objectForKey:webAction.actionName];
    if (cacheClass) {
        //已经缓存的类型，可以直接跳转
        return cacheClass;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
        //未缓存的，先判断该种类型的跳转能被哪个类响应,并缓存下来，再执行跳转
        for (Class<TWebActionProtocol> webActionClass in self.webActionClasses) {
            BOOL canHandle = [webActionClass performSelector:@selector(canHandleWebAction:) withObject:webAction.actionName];
            if (canHandle) {
                [self.classMapCache setObject:webActionClass forKey:webAction.actionName];
                return webActionClass;
            }
        }
#pragma clang diagnostic pop
    }
    return nil;
}

/**
 根据webAction创建具体的类
 
 @param webAction 操作类
 @param webActionTargetClass 目标类的class
 @return 具体的类
 */
- (id)createTargetForWebAction:(TWebAction *)webAction withClass:(Class)webActionTargetClass {
    id target;
    //创建具体的类
    if ([webActionTargetClass respondsToSelector:@selector(createTargetWithWebAction:)]) {
        target = [webActionTargetClass performSelector:@selector(createTargetWithWebAction:) withObject:webAction];
    }else{
        return nil;
    }
    
    //设置参数
    if (target){
        [webAction setValuesForObject:target];
    }
    
    //设置callback
    if (webAction.webActionCallback && [target isKindOfClass:[NSObject class]]) {
        ((NSObject *)target).webActionCallback = webAction.webActionCallback;
        webAction.webActionCallback = nil;
    }
    
    return target;
}


#pragma mark - 懒加载
- (NSCache *)classMapCache{
    if (!_classMapCache) {
        _classMapCache = [[NSCache alloc] init];
    }
    return _classMapCache;
}

- (NSArray *)webActionClasses {
    if (!_webActionClasses) {
        _webActionClasses = [TWebRuntimeHelper getClassesThatConfirmToProtocol:@protocol(TWebActionProtocol)];
    }
    return _webActionClasses;
}

@end
