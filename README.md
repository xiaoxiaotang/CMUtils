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
pod 'SCUtils'
```

* 使用subspec

```
pod 'SCUtils/NSString'
```

### Usage
```objc
#import "SCUtils.h"
```

### 常见功能

- 常量定义
- 时间格式转换
- 设备信息获取
- JSON 数据转换
- 异常堆栈获取
- 科学计数四则运算
- 字符串的常见处理
- 响应事件拦截

pod repo push 230-privatepodspecs CMUtils.podspec --allow-warnings --verbose --use-libraries
