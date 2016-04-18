# ThirdShareAndLoginDemo

  由于之前使用的是ShareSDK，使用起来不是很方便，需要处理各种applicationDelegate回调等问题，比较复杂，而且显示分享的弹出样式无法自定制，因此写了这个Demo。
 
  ##此demo的特点：
  
  * 1、使用起来简单，外部接口只有5个，使用极其方便。
  * 2、不需要使用者自己实现application:openURL:sourceApplication:annotation:、application:handleOpenURL:、application:openURL:options:等函数。
  * 3、支持QQ、QQ空间、微信、微信空间、微博、短信、粘贴板等的分享。
  
##使用步骤：
  *  1、去到QQ、微信、微博等的开发者中心注册自己的应用
  *  2、在Info.plist->LSApplicationQueriesSchemes里添加各个平台要求的列表（暂时也可复制本demo的列表）
  *  3、配置项目里面的Info->URL Types里几个平台的回调本地地址（配置方式参照各个平台的要求。
  *  4、代码使用registerThirdPlatform:appKey:secret:redirectURI:函数注册各个平台的appKey等信息。
  *  5、分享要使用ZHShareManager类的类方法shareWithSharedType:title:image:url:description:weiboDescription:callBack:进行文字、图片、网页的分享
  *  6、第三方登录使用ZHThirdManager类的getThirdUserInfo:callBack:获取用户信息，回调的block的userInfo对象包含了用户的信息
   
#####备注1：暂时QQ和微信的分享和登录使用了官方的demo应用的appKey信息，由于没有拿到微信的appsecret，因此微信登录暂时不可用，替换为用户自己应用信息后方可用。
#####备注2：传到github时可能会有一些第三方平台的静态库无法上传，因此可能会需要使用者自己去第三方平台下载。
#####备注3：项目使用cocoapod依赖了几个第三框架，运行前请执行pod命令获取本地代码。
