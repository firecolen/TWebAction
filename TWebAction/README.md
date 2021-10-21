## JSBridge 框架解决通信问题实现移动端跨平台开发，提高跨平台开发效率。

### 特性
支持 JS 双向通信 

### 实现方式
采用实现协议的方式去设计

### 示例
一、项目启动时，使用TWebActionManager存储实现web协议的类

二、原生代码对JS的拦截
1、-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message，
在该方法拦截JS并处理逻辑；
2、使用TWebActionManager和使用TWebAction处理。

三、使用方法（参照TCLWebCallPhone和TCLWebGetLocation使用）
1、在TCLWebActionPathDefine文件配置交互的操作名称；
2、具体的实现类需要实现TWebActionProtocol协议，实现canHandleWebAction:和createTargetWithWebAction:方法；
3、处理的逻辑可以放在handleWebActionWithHandler:(id)handler方法中；

四、 回调
如果需要回调信息给H5页面，使用webActionCallback回调信息。（PS：self.webActionCallback(model)）

