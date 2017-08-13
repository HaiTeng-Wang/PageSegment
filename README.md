PageSegment
==

[![License](https://img.shields.io/cocoapods/l/TabPageViewController.svg?style=flat)](http://cocoapods.org/pods/PageSegmentView)
[![Language](https://img.shields.io/badge/language-oc-orange.svg?style=flat)](https://developer.apple.com/oc)

<p align="left">
<a href="https://travis-ci.org/xmartlabs/PageSegment"><img src="https://travis-ci.org/xmartlabs/PageSegment.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://cocoapods.org/pods/PageSegmentView"><img src="https://img.shields.io/badge/pod-1.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/xmartlabs/PageSegment/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" />
</a>
<!-- <a href="https://codebeat.co/projects/github-com-xmartlabs-xlpagertabstrip"><img alt="codebeat badge" src="https://codebeat.co/badges/f32c9ad3-0aa1-4b40-a632-9421211bd39e" /></a> -->
</p>

> 基于[PagerTab](https://github.com/ming1016/PagerTab)基础上进行修改。

原贡献者，貌似消失于`Github`界，此控件也没有持续更新。所有放到这里希望大家可以一起`pull requests `。

文件，代码少，易于自己修改成适合自己项目的工程控件。`TabBar`可显示小红点。

---

![效果图](https://raw.githubusercontent.com/HaiTeng-Wang/PageSegment/master/PageSegment.gif)


Features
--------
* 容器视图控制器管理页面，左右滑动切换页面控制器
* 可配置TabBar，支持多个BarItem，TabBar支持小红点显示
* 支持页面边缘右滑返回

Requirements
------------
* iOS 8+

Installation with CocoaPods
------------
**Podfile**
```
platform :ios, '8.0'

target 'TargetName' do
pod 'PageSegmentView', '~> 1.0'
end
```

**Then**
```
$ pod install
```


Use
------------

**init**
```Objective-C
- (SMPagerTabView *)segmentView {
    if (!_segmentView) {
        self.segmentView = [[SMPagerTabView alloc]initWithFrame:CGRectMake(0,
                                                                           self.topLayoutGuide.length,
                                                                           self.view.width,
                                                                           self.view.height - self.topLayoutGuide.length)];
        [self.view addSubview:_segmentView];
    }
    return _segmentView;
}

```
**config**
```Objective-C
self.segmentView.delegate = self;
//可自定义背景色和tab button的文字颜色等
//开始构建UI
[_segmentView buildUI];
//显示红点，点击消失
[_segmentView showRedDotWithIndex:0];
```
**delegate**
```Objective-C
#pragma mark - DBPagerTabView Delegate
- (NSUInteger)numberOfPagers:(SMPagerTabView *)view {
    return [_allVC count];
}
- (UIViewController *)pagerViewOfPagers:(SMPagerTabView *)view indexOfPagers:(NSUInteger)number {
    return _allVC[number];
}

- (void)whenSelectOnPager:(NSUInteger)number {
    NSLog(@"页面 %lu",(unsigned long)number);
}
```


Contribution
------------
Discussion and pull requests are welcomed Correcting English grammar is welcomed, too.

Contact me
------------
- 简书: [HunterDude ](http://www.jianshu.com/u/c843d96298fb)
- 博客: [Hunter](https://haiteng-wang.github.io)
- 邮箱: llllhaiteng@gmail.com
- 微信 : 15542372074

License
-------
RxTodo is under MIT license. See the [LICENSE](LICENSE) for more info.
