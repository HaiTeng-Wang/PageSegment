//
//  PageSegmentView.m
//  PageSegment
//
//  Created by Hunter on 12/08/2017.
//  Copyright © 2017 Hunter. All rights reserved.
//

#import "PageSegmentView.h"

@interface PageSegmentView ()<UIScrollViewDelegate>

@property (nonatomic, strong) BodyScrollView *bodyScrollView;
@property (nonatomic, strong) UIScrollView   *tabView;
@property (nonatomic, strong) UIImageView    *shadowImgView;
@property (nonatomic, strong) UIView         *selectedLine;

@property (nonatomic, strong) NSMutableArray *viewsArray;
@property (nonatomic, strong) NSMutableArray *tabButtons;
@property (nonatomic, strong) NSMutableArray *tabRedDots;  //按钮上的红点

@property (nonatomic, assign) NSUInteger     continueDraggingNumber;
@property (nonatomic, assign) NSUInteger     currentTabSelected;

@property (nonatomic, assign) CGFloat        startOffsetX;
@property (nonatomic, assign) CGFloat        selectedLineOffsetXBeforeMoving;
@property (nonatomic, assign) CGFloat        tabViewContentSizeWidth;
@property (nonatomic, assign) CGFloat        itemButtonX;

@property (nonatomic, assign) BOOL           isBuildUI;
@property (nonatomic, assign) BOOL           isUseDragging; //是否使用手拖动的，自动的就设置为NO
@property (nonatomic, assign) BOOL           isEndDecelerating;

@end


@implementation PageSegmentView

- (void)buildUI {
    _isBuildUI = NO;
    _isUseDragging = NO;
    _isEndDecelerating = YES;
    _startOffsetX = 0;
    _continueDraggingNumber = 0;

    NSUInteger number = [self.delegate numberOfPagers:self];

    for (int i = 0; i < number; i++) {
        //ScrollView部分
        UIViewController* vc = [self.delegate pagerViewOfPagers:self indexOfPagers:i];
        [self.viewsArray addObject:vc];
        [self.bodyScrollView addSubview:vc.view];

        //tab上按钮
        UIButton* itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemButton.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [itemButton.titleLabel setFont:[UIFont systemFontOfSize:self.tabButtonFontSize]];
        [itemButton setTitle:vc.title forState:UIControlStateNormal];
        [itemButton setTitleColor:self.tabButtonTitleColorForNormal forState:UIControlStateNormal];
        [itemButton setTitleColor:self.tabButtonTitleColorForSelected forState:UIControlStateSelected];
        [itemButton addTarget:self action:@selector(onTabButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        itemButton.tag = i + 1; // "tag = 0" 为父视图本身,所以tag+1
        itemButton.size = [self buttonTitleRealSize:itemButton];
        [itemButton setFrame:CGRectMake(self.itemButtonX, 0, itemButton.width, self.tabFrameHeight)];
        [self.tabButtons addObject:itemButton];
        [self.tabView addSubview:itemButton];

        // 记录itemButtonX
        if (i == 0) {
            _itemButtonX = self.tabMargin + itemButton.width + self.tabMargin;
        } else {
            _itemButtonX = CGRectGetMaxX(itemButton.frame) + self.tabMargin;
        }

        //tab上的红点
        UIView* aRedDot = [[UIView alloc] initWithFrame:CGRectMake(itemButton.width / 2 + [self buttonTitleRealSize:itemButton].width / 2 + 3, itemButton.height / 2 - [self buttonTitleRealSize:itemButton].height / 2, 8, 8)];
        aRedDot.backgroundColor = [UIColor redColor];
        aRedDot.layer.cornerRadius = aRedDot.width/2.0f;
        aRedDot.layer.masksToBounds = YES;
        aRedDot.hidden = YES;
        [self.tabRedDots addObject:aRedDot];
        [itemButton addSubview:aRedDot];

        // getTabViewContentSizeWidth
        if (i == number - 1) {
            self.tabViewContentSizeWidth = CGRectGetMaxX(itemButton.frame) + _tabMargin;

            // 当itemButton数量较少，强制设置其size，自动填充
            if (self.tabViewContentSizeWidth < self.tabView.width) {
                for (int t = 0; t < _tabButtons.count; t++) {
                    UIButton *btn = _tabButtons[t];
                    [btn setFrame:CGRectMake((_tabView.width / _tabButtons.count) * t,
                                             0,
                                             _tabView.width / _tabButtons.count,
                                             self.tabFrameHeight)];


                    UIView *redDot = _tabRedDots[t];
                    [redDot setFrame:CGRectMake(btn.width / 2 + [self buttonTitleRealSize:btn].width / 2 + 3, btn.height / 2 - [self buttonTitleRealSize:btn].height / 2, 8, 8)];
                }

                self.tabViewContentSizeWidth = _tabView.width;
            }
        }
    }

    //tabView
    [self.tabView setBackgroundColor:self.tabBackgroundColor];

    // fix：真机加载不到Bundle中资源图片。 date：20170816
    self.shadowImgView.image = [self imageNamed:@"shadowImg" BundleNamed:@"PageSegmentView.bundle"];

    _isBuildUI = YES;

    //起始选择一个tab,默认index = 0
    [self selectTabWithIndex:0 animate:NO];

    [self setNeedsLayout];
}

- (CGSize)buttonTitleRealSize:(UIButton *)button {
    CGSize size = CGSizeZero;
    size = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    return size;
}

- (CGFloat)selectedLineWidth:(UIButton *)button {
    if (self.selectedLineWidth) {
        return _selectedLineWidth;
    }
    if (self.tabViewContentSizeWidth == self.tabView.width) {
        return _tabView.width / _tabButtons.count;
    }
    return [self buttonTitleRealSize:button].width;
}

- (void)layoutSubviews {
    if (_isBuildUI) {
        self.bodyScrollView.contentSize = CGSizeMake(self.width * [self.viewsArray count], self.tabFrameHeight);
        _tabView.contentSize = CGSizeMake(_tabViewContentSizeWidth, self.tabFrameHeight);
        for (int i = 0; i < [self.viewsArray count]; i++) {
            UIViewController* vc = self.viewsArray[i];
            vc.view.frame = CGRectMake(self.bodyScrollView.width * i, self.tabFrameHeight, self.bodyScrollView.width, self.bodyScrollView.height - self.tabFrameHeight);
        }
    }
}


#pragma mark - Tab
- (void)onTabButtonSelected:(UIButton *)button {
    [self selectTabWithIndex:button.tag - 1 animate:YES];
}

- (void)selectTabWithIndex:(NSUInteger)index animate:(BOOL)isAnimate {
    UIButton *preButton = self.tabButtons[self.currentTabSelected];
    preButton.selected = NO;
    UIButton *currentButton = self.tabButtons[index];
    currentButton.selected = YES;
    _currentTabSelected = index;

    void(^moveSelectedLine)(void) = ^(void) {
        self.selectedLine.size = CGSizeMake([self selectedLineWidth:currentButton], self.selectedLineHeight);
        self.selectedLine.center = CGPointMake(currentButton.center.x, self.selectedLine.center.y);
        self.selectedLineOffsetXBeforeMoving = self.selectedLine.origin.x;
    };

    //移动select line
    if (isAnimate) {
        [UIView animateWithDuration:0.3 animations:^{
            moveSelectedLine();
        }];
    } else {
        moveSelectedLine();
    }

    [self updaTetabViewContentOffset];

    [self switchWithIndex:index animate:isAnimate];

    if ([self.delegate respondsToSelector:@selector(whenSelectOnPager:)]) {
        [self.delegate whenSelectOnPager:index];
    }

    [self hideRedDotWithIndex:index];
}

/*!
 * @brief Selected Line跟随移动
 */
- (void)moveSelectedLineByScrollWithOffsetX:(CGFloat)offsetX {
    CGFloat textGap = (self.width - self.tabMargin * 2 - self.selectedLine.width * self.tabButtons.count) / (self.tabButtons.count * 2);
    CGFloat speed = 50;
    //移动的距离
    CGFloat movedFloat = self.selectedLineOffsetXBeforeMoving + (offsetX * (textGap + self.selectedLine.width + speed)) / [UIScreen mainScreen].bounds.size.width;
    //最大右移值
    CGFloat selectedLineRightBarrier = _selectedLineOffsetXBeforeMoving + textGap * 2 + self.selectedLine.width;
    //最大左移值
    CGFloat selectedLineLeftBarrier = _selectedLineOffsetXBeforeMoving - textGap * 2 - self.selectedLine.width;
    CGFloat selectedLineNewX = 0;

    //连续拖动时的处理
    BOOL isContinueDragging = NO;
    if (_continueDraggingNumber > 1) {
        isContinueDragging = YES;
    }

    if (movedFloat > selectedLineRightBarrier && !isContinueDragging) {
        //右慢拖动设置拦截
        selectedLineNewX = selectedLineRightBarrier;
    } else if (movedFloat < selectedLineLeftBarrier && !isContinueDragging) {
        //左慢拖动设置的拦截
        selectedLineNewX = selectedLineLeftBarrier;
    } else {
        //连续拖动可能超过总长的情况需要拦截
        if (isContinueDragging) {
            if (movedFloat > self.width - (self.tabMargin + textGap + self.selectedLine.width)) {
                selectedLineNewX = self.width - (self.tabMargin + textGap + self.selectedLine.width);
            } else if (movedFloat < self.tabMargin + textGap) {
                selectedLineNewX = self.tabMargin + textGap;
            } else {
                selectedLineNewX = movedFloat;
            }
        } else {
            //无拦截移动
            selectedLineNewX = movedFloat;
        }
    }
    [self.selectedLine setFrame:CGRectMake(selectedLineNewX,
                                           self.selectedLine.frame.origin.y,
                                           self.selectedLine.frame.size.width,
                                           self.selectedLine.frame.size.height)];

}

- (void)updaTetabViewContentOffset{
    CGFloat leftmost = _tabView.centerX; // 最左边
    CGFloat rightmost = _tabView.contentSize.width - _tabView.centerX; // 最右边

    if (_selectedLine.centerX < leftmost || _selectedLine.centerX == leftmost) {
        _startOffsetX = 0;
    } else if (_selectedLine.centerX > rightmost || _selectedLine.centerX == rightmost) {
        _startOffsetX = _tabView.contentSize.width - _tabView.width;
    } else {
        _startOffsetX = _selectedLine.centerX - _tabView.centerX;
    }

    [UIView animateWithDuration:0.3 animations:^{
        _tabView.contentOffset = CGPointMake(_startOffsetX, 0);
    }];
}

/*!
 * @brief 红点
 */
- (void)showRedDotWithIndex:(NSUInteger)index {
    UIView* redDot = self.tabRedDots[index];
    redDot.hidden = NO;
}

- (void)hideRedDotWithIndex:(NSUInteger)index {
    UIView* redDot = self.tabRedDots[index];
    redDot.hidden = YES;
}


#pragma mark - BodyScrollView
- (void)switchWithIndex:(NSUInteger)index animate:(BOOL)isAnimate {
    [self.bodyScrollView setContentOffset:CGPointMake(index*self.width, 0) animated:isAnimate];
    _isUseDragging = NO;
}


#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        _continueDraggingNumber += 1;
        if (_isEndDecelerating) {
            _startOffsetX = scrollView.contentOffset.x;
        }
        _isUseDragging = YES;
        _isEndDecelerating = NO;
    }
}

/*!
 * @brief 对拖动过程中的处理
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        CGFloat movingOffsetX = scrollView.contentOffset.x - _startOffsetX;
        if (_isUseDragging) {
            //tab处理事件待完成
            [self moveSelectedLineByScrollWithOffsetX:movingOffsetX];
        }
    }
}

/*!
 * @brief 手释放后pager归位后的处理
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        [self selectTabWithIndex:(int)scrollView.contentOffset.x/self.bounds.size.width animate:YES];
        _isUseDragging = YES;
        _isEndDecelerating = YES;
        _continueDraggingNumber = 0;
    }
}

/*!
 * @brief 自动停止
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        //tab处理事件待完成
        [self selectTabWithIndex:(int)scrollView.contentOffset.x/self.bounds.size.width animate:YES];
    }
}


#pragma mark - Setter/Getter
/*!
 * @brief 滑动pager主体
 */
- (BodyScrollView*)bodyScrollView {
    if (!_bodyScrollView) {
        self.bodyScrollView = [[BodyScrollView alloc] initWithFrame:CGRectMake(0,_tabFrameHeight,self.width,self.height - _tabFrameHeight)];
        _bodyScrollView.delegate = self;
        _bodyScrollView.pagingEnabled = YES;
        _bodyScrollView.userInteractionEnabled = YES;
        _bodyScrollView.bounces = NO;
        _bodyScrollView.showsHorizontalScrollIndicator = NO;
        _bodyScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight
        | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bodyScrollView];
    }
    return _bodyScrollView;
}

/*!
 * @brief 头部tab
 */
- (UIView *)tabView {
    if (!_tabView) {
        self.tabView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.width,_tabFrameHeight)];
        _tabView.delegate = self;
        _tabView.userInteractionEnabled = YES;
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.autoresizingMask = UIViewAutoresizingFlexibleHeight
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_tabView];
    }
    return _tabView;
}

- (UIView *)selectedLine {
    if (!_selectedLine) {
        self.selectedLine = [[UIView alloc] initWithFrame:CGRectMake(0,self.tabView.height - 2,0,self.selectedLineHeight)];
        _selectedLine.backgroundColor = _tabButtonTitleColorForSelected;
        [self.tabView addSubview:_selectedLine];
    }
    return _selectedLine;
}

-(UIImageView *)shadowImgView{
    if (!_shadowImgView) {
        self.shadowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,self.tabView.height,self.width,10)];
        [self addSubview:_shadowImgView];
    }
    return _shadowImgView;
}

- (CGFloat)selectedLineHeight{
    if (!_selectedLineHeight) {
        self.selectedLineHeight = 2;
    }
    return _selectedLineHeight;
}

- (CGFloat)tabFrameHeight {
    if (!_tabFrameHeight) {
        self.tabFrameHeight = 40;
    }
    return _tabFrameHeight;
}

- (CGFloat)tabMargin {
    if (!_tabMargin) {
        self.tabMargin = 20;
    }
    return _tabMargin;
}

- (CGFloat)itemButtonX{
    if (!_itemButtonX) {
        self.itemButtonX = self.tabMargin;
    }
    return _itemButtonX;
}

- (CGFloat)tabButtonFontSize {
    if (!_tabButtonFontSize) {
        self.tabButtonFontSize = 14;
    }
    return _tabButtonFontSize;
}

- (CGFloat)selectedLineOffsetXBeforeMoving {
    if (!_selectedLineOffsetXBeforeMoving) {
        self.selectedLineOffsetXBeforeMoving = 0;
    }
    return _selectedLineOffsetXBeforeMoving;
}

- (NSUInteger)currentTabSelected {
    if (!_currentTabSelected) {
        self.currentTabSelected = 0;
    }
    return _currentTabSelected;
}

- (UIColor *)tabBackgroundColor {
    if (!_tabBackgroundColor) {
        self.tabBackgroundColor = [UIColor whiteColor];
    }
    return _tabBackgroundColor;
}

- (UIColor *)tabButtonTitleColorForNormal {
    if (!_tabButtonTitleColorForNormal) {
        self.tabButtonTitleColorForNormal = [UIColor blackColor];
    }
    return _tabButtonTitleColorForNormal;
}

- (UIColor *)tabButtonTitleColorForSelected {
    if (!_tabButtonTitleColorForSelected) {
        self.tabButtonTitleColorForSelected = [UIColor colorWithRed:58/255.0
                                                              green:161/255.0
                                                               blue:219/255.0
                                                              alpha:1];
    }
    return _tabButtonTitleColorForSelected;
}

- (NSMutableArray *)tabButtons {
    if (!_tabButtons) {
        self.tabButtons = [[NSMutableArray alloc] init];
    }
    return _tabButtons;
}

- (NSMutableArray *)tabRedDots {
    if (!_tabRedDots) {
        self.tabRedDots = [[NSMutableArray alloc] init];
    }
    return _tabRedDots;
}

- (NSMutableArray *)viewsArray {
    if (!_viewsArray) {
        self.viewsArray = [[NSMutableArray alloc] init];
    }
    return _viewsArray;
}


/**
 获取Bundel资源图片

 @param imgName 图片名称
 @param bundleName bundle名字
 @return Img对象
 */
- (UIImage *)imageNamed:(NSString *)imgName BundleNamed:(NSString *)bundleName{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    NSURL *bundleURL = [[frameworkBundle resourceURL] URLByAppendingPathComponent:bundleName];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
    UIImage *image = [UIImage imageNamed:imgName inBundle:resourceBundle compatibleWithTraitCollection:nil];
    return image;
}

@end
