//
//  WMMenuView.m
//  WMPageController
//
//  Created by Mark on 15/4/26.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import "WMMenuView.h"
#import "WMMenuItem.h"
#define kMaskWidth 20
#define kItemWidth 60
#define kMargin    0
#define kTagGap    6250
#define kBGColor   [UIColor colorWithRed:172.0/255.0 green:165.0/255.0 blue:162.0/255.0 alpha:1.0];
@interface WMMenuView () <WMMenuItemDelegate>{
    CGFloat _norSize;
    CGFloat _selSize;
    UIColor *_norColor;
    UIColor *_selColor;
}
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) WMMenuItem *selItem;
@property (nonatomic, strong) UIColor *bgColor;
@end

@implementation WMMenuView
#pragma mark - Public Methods
- (instancetype)initWithFrame:(CGRect)frame buttonItems:(NSArray *)items backgroundColor:(UIColor *)bgColor norSize:(CGFloat)norSize selSize:(CGFloat)selSize norColor:(UIColor *)norColor selColor:(UIColor *)selColor{
    if (self = [super initWithFrame:frame]) {
        self.items = items;
        if (bgColor) {
            self.bgColor = bgColor;
        }else{
            self.bgColor = kBGColor;
        }
        _norSize = norSize;
        _selSize = selSize;
        _norColor = norColor;
        _selColor = selColor;
    }
    return self;
}
- (void)slideMenuAtProgress:(CGFloat)progress{
    NSInteger tag = (NSInteger)progress + kTagGap;
    CGFloat rate = progress - tag + kTagGap;
    WMMenuItem *currentItem = (WMMenuItem *)[self viewWithTag:tag];
    WMMenuItem *nextItem = (WMMenuItem *)[self viewWithTag:tag+1];
    if (rate == 0.0) {
        rate = 1.0;
        self.selItem = currentItem;
        [self refreshContenOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}
#pragma mark - Private Methods
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self addScrollView];
    [self addItems];
}
- (void)refreshContenOffset{
    // 让选中的item位于中间
    CGRect frame = self.selItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width/2) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width/2) {
            targetX = contentSize.width - width;
        }else{
            targetX = frame.origin.x - width/2 + frame.size.width/2;
        }
        // 应该有更好的解决方法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}
- (void)addScrollView{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGRect frame = CGRectMake(0, 0, width, height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator   = NO;
    scrollView.backgroundColor = self.bgColor;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}
- (void)addItems{
    CGFloat contentWidth = kMargin;
    for (int i = 0; i < self.items.count; i++) {
        CGFloat itemW = kItemWidth;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemW = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        CGRect frame = CGRectMake(contentWidth, 0, itemW, self.frame.size.height);
        contentWidth += itemW;
        WMMenuItem *item = [[WMMenuItem alloc] initWithFrame:frame];
        item.tag = (i+kTagGap);
        item.title = self.items[i];
        item.delegate = self;
        item.backgroundColor = self.bgColor;
        if (_norSize > 0.0001) {
            item.normalSize = _norSize;
        }
        if ((int)_selSize > 0.0001) {
            item.selectedSize = _selSize;
        }
        if (_norColor) {
            item.normalColor = _norColor;
        }
        if (_selColor) {
            item.selectedColor = _selColor;
        }
        if (i == 0) {
            [item selectedItemWithoutAnimation];
            self.selItem = item;
        }
        [self.scrollView addSubview:item];
    }
    contentWidth += kMargin;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}
#pragma mark - Menu item delegate
- (void)didPressedMenuItem:(WMMenuItem *)menuItem{
    if (self.selItem == menuItem) return;
    
    NSInteger currentIndex = self.selItem.tag - kTagGap;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:menuItem.tag-kTagGap currentIndex:currentIndex];
    }
    
    menuItem.selected = YES;
    self.selItem.selected = NO;
    self.selItem = menuItem;
    // 让选中的item位于中间
    [self refreshContenOffset];
}
@end
