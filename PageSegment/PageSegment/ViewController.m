//
//  ViewController.m
//  CcfaxPagerTab
//
//  Created by Hunter on 02/08/2017.
//  Copyright © 2017 Hunter. All rights reserved.
//
#import "ViewController.h"
#import "PageSegmentView.h"
#import "TableChildExampleViewController.h"
#import "ViewChildExampleViewController.h"

@interface ViewController ()<PageSegmentViewDelegate>

@property (nonatomic, strong) NSMutableArray *allVC;
@property (nonatomic, strong) PageSegmentView *segmentView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    _allVC = [NSMutableArray array];

    TableChildExampleViewController *vc1 = [[TableChildExampleViewController alloc]init];
    [_allVC addObject:vc1];
    vc1.title = @"TableChildVC1";

    ViewChildExampleViewController *vc2 = [[ViewChildExampleViewController alloc]init];
    [_allVC addObject:vc2];
    vc2.title = @"ChildVC2";
    vc2.view.backgroundColor = [UIColor yellowColor];

    TableChildExampleViewController *vc3 = [[TableChildExampleViewController alloc]init];
    [_allVC addObject:vc3];
    vc3.title = @"TableChildVC3";

    ViewChildExampleViewController *vc4 = [[ViewChildExampleViewController alloc]init];
    [_allVC addObject:vc4];
    vc4.title = @"ChildVC4";
    vc4.view.backgroundColor = [UIColor grayColor];

    TableChildExampleViewController *vc5 = [[TableChildExampleViewController alloc]init];
    [_allVC addObject:vc5];
    vc5.title = @"TableChildVC5";

    ViewChildExampleViewController *vc6 = [[ViewChildExampleViewController alloc]init];
    [_allVC addObject:vc6];
    vc6.title = @"ChildVC6";
    vc6.view.backgroundColor = [UIColor blueColor];

    self.segmentView.delegate = self;
    // 可自定义背景色和tab button的文字颜色等
    // _segmentView.selectedLineWidth = 50;
    // 开始构建UI
    [_segmentView buildUI];
    // 显示红点，点击消失
    [_segmentView showRedDotWithIndex:0];
}


#pragma mark - DBPagerTabView Delegate

- (NSUInteger)numberOfPagers:(PageSegmentView *)view {
    return [_allVC count];
}
- (UIViewController *)pagerViewOfPagers:(PageSegmentView *)view indexOfPagers:(NSUInteger)number {
    return _allVC[number];
}

- (void)whenSelectOnPager:(NSUInteger)number {
    NSLog(@"页面 %lu",(unsigned long)number);
}


#pragma mark - setter/getter

- (PageSegmentView *)segmentView {
    if (!_segmentView) {
        self.segmentView = [[PageSegmentView alloc]initWithFrame:CGRectMake(0,20,self.view.width,self.view.height - 20)];
        [self.view addSubview:_segmentView];
    }
    return _segmentView;
}

@end

