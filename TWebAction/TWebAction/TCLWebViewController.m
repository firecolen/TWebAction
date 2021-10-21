//
//  TCLWebViewController.m
//  TWebAction
//
//  Created by collen.zhang on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import "TCLWebViewController.h"
#import <WebKit/WebKit.h>
#import "TCLWebViewScriptMessageDelegate.h"
#import "TCLWebActionPathDefine.h"
#import "TWebActionManager.h"
#import "TWebAction.h"
#import "NSObject+TWebAction.h"

@interface TCLWebViewController ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *  webView;

//网页加载进度视图
@property (nonatomic, strong) UIProgressView * progressView;

//@property (nonatomic, strong) TWebAction *webAction;

@property (nonatomic, strong) TWebActionManager *manager;
@end

@implementation TCLWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self TCL_layoutNavigation];
    [self TCL_addSubviews];
    [self TCL_initialize];
    
    NSString *str = @" 1 2 3 ";
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
    NSLog(@"==%@=",str);
}

- (void)dealloc{
    //移除注册的js方法
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:TCLWebJSbridge];
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}

//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
        
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
// 初始化
- (void)TCL_initialize {
    _manager = [[TWebActionManager alloc] init];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];

    [self loadHtml];
}

-(void)loadHtml{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JStoOC.html" ofType:nil];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

// 子视图布局
- (void)TCL_addSubviews {
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
}


// 设置导航栏
- (void)TCL_layoutNavigation {
    
    // 后退按钮
    UIButton * goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goBackButton setImage:[UIImage imageNamed:@"backbutton"] forState:UIControlStateNormal];
    [goBackButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    goBackButton.frame = CGRectMake(0, 0, 30, StatusBarAndNavigationBarHeight);
    UIBarButtonItem * goBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    
    UIBarButtonItem * jstoOc = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStyleDone target:self action:@selector(goHomeAction:)];
    self.navigationItem.leftBarButtonItems = @[goBackButtonItem,jstoOc];
    
    // 刷新按钮
    UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setImage:[UIImage imageNamed:@"webRefreshButton"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.frame = CGRectMake(0, 0, 30, StatusBarAndNavigationBarHeight);
    UIBarButtonItem * refreshButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    
    UIBarButtonItem * ocToJs = [[UIBarButtonItem alloc] initWithTitle:@"OC调用JS" style:UIBarButtonItemStyleDone target:self action:@selector(callJsAction:)];
    self.navigationItem.rightBarButtonItems = @[refreshButtonItem, ocToJs];
}

#pragma mark - - Event Handle

//返回
-(void)goBackAction:(id)sender {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else{
        if (self.navigationController.viewControllers.count >= 2) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//去首页
-(void)goHomeAction:(id)sender {
    [self loadHtml];
}

//刷新
-(void)refreshAction:(id)sender {
//    [_webView reload];
    TCLWebViewController *vc = [[TCLWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//调用js方法
-(void)callJsAction:(id)sender {
    [_webView evaluateJavaScript:@"changeColor()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSLog(@"oc call js: changeColor");
    }];
}


#pragma mark - - UserContentController
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
//    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    if ([TCLWebJSbridge isEqualToString:message.name]) {
        //native 和 js 交互
        if (message.body && [message.body isKindOfClass:[NSDictionary class]]) {
            NSString *actionName = message.body[@"name"];
            
            __weak typeof(self) weakSelf = self;
            TWebActionCallback callback = ^(TWebActionCallbackData * _Nonnull data) {
                
                NSLog(@"=============执行完webaction操作的回调，actionName = %@, resultName = %@",actionName,data.actionName);
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if(data.jsCallback){
                    [strongSelf.webView evaluateJavaScript:data.jsCallback completionHandler:^(id _Nullable object, NSError * _Nullable error) {
                        NSLog(@"object = %@,error = %@",object,error);
                    }];
                }
            };
            
            TWebAction *webAction = [TWebAction webActionFromActionName:actionName params:message.body[@"data"] callback:callback];
            //如果handleWebActionWithHandler有执行block，target会被持有，直到执行完block
            id<TWebActionProtocol> target = [[TWebActionManager sharedManager] createTargetWithWebAction:webAction];
            if (!target) {
                NSLog(@"请升级至最新版本");
                return;
            }
            [target handleWebActionWithHandler:nil];
            
        }
        
        
    }
}

#pragma mark - - WKNavigationDelegate
/*
 WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等
 */

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
//    [self getCookie];
    
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"发送跳转请求：%@",urlStr);
    //自己定义的协议头
    NSString *htmlHeadString = @"github://";
    if([urlStr hasPrefix:htmlHeadString]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通过截取URL调用OC" message:@"你想前往我的Github主页?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }])];
        [alertController addAction:([UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@"github://callName_?" withString:@""]];
            [[UIApplication sharedApplication] openURL:url];
            
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
    
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
//    NSLog(@"=======>didReceiveAuthenticationChallenge");
//    //用户身份信息
//    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
//    //为 challenge 的发送方提供 credential
//    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
//
//}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}


#pragma mark - - WKUIDelegate

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - Getter
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, StatusBarAndNavigationBarHeight+1, self.view.frame.size.width, 2)];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

-(WKWebView *)webView {
    if (!_webView) {
        //设置对象
        WKPreferences *preference = [[WKPreferences alloc] init];
        
        //window.open(url,"_blank”); 如需支持，javaScriptCanOpenWindowsAutomatically必须设置为YES
        preference.javaScriptCanOpenWindowsAutomatically = YES;
         //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        preference.javaScriptEnabled = YES;
        
        //网页配置对象
        WKWebViewConfiguration *wkConfig = [[WKWebViewConfiguration alloc] init];
        wkConfig.preferences = preference;
        
        //是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        wkConfig.allowsInlineMediaPlayback = YES;
        
        
        if (@available(iOS 9.0, *)) {
            //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
            wkConfig.requiresUserActionForMediaPlayback = YES;
            //设置是否允许画中画技术 在特定设备上有效
            wkConfig.allowsPictureInPictureMediaPlayback = YES;
            wkConfig.applicationNameForUserAgent = @"HouseKeeper";
        }
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        TCLWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[TCLWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        
        //这个类是native与JavaScript的交互管理
        WKUserContentController *wkUserContentController = [[WKUserContentController alloc] init];
        [wkUserContentController addScriptMessageHandler:weakScriptMessageDelegate name:TCLWebJSbridge];
        
        wkConfig.userContentController = wkUserContentController;
        
        //适配文本大小
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [wkConfig.userContentController addUserScript:wkUScript];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:wkConfig];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        //允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        
    }
    return _webView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
