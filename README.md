# AEWebView
1、WebView组件
* 即插即用原则存在，例如：WKWebView组件、UIWebVIew组件等继承根组件进行注册即可
* 遵守组件行为协议，承接外部Controller行为事件的回调
* 实现组件基础协议，对外输出WebView组件的基本协议方法

2、交互管理
* 基于不同原理实现不同的交互方法可供选择，例如：原生交互方法、基于WKWebViewJavascriptBridge等。
* 原生交互方法如下
    * 方法注入(注册方法给JS调用，并可以返回数据)
    * 代理方法(供JS调用，传参给原生)
    * 主动调用(原生调用JS方法，并可接受返回值)
    * 交互方法插件形式注入(即插即用原则)
* 基于WKWebViewJavascriptBridge如下
    * 方法注册(注册方法，供JS端调用)
    * 方法回调(调用在JS端已经预埋好的方法)
    * 交互方法插件形式注入(即插即用原则)

3、控制器
* WebView组件注册
* Controller行为回调WebView组件
* 组件基础协议实现
* UI模块

4、整体架构如下
![page_1](https://user-images.githubusercontent.com/9248093/173719213-01a89a06-5ea0-4048-acb5-1c4d0aa509da.png)
