Saic-Utils-FrameWork
====================

### Howto
* Podfile 添加源

```ruby
source 'http://134.175.230.26:9090/iOS_Compoent/PrivatePodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

* 安装

```ruby
pod 'CMUtils'
```

* 使用subspec

```
pod 'CMUtils/NSString'
```

### Usage
```objc
#import "WYConstant.h"
```

### 常见功能

- 常量定义
- 字符串的常见处理
- 响应事件拦截

pod repo push 230-privatepodspecs CMUtils.podspec --allow-warnings --verbose --use-libraries
