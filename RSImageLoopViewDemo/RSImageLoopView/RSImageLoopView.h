//
//  RSImageLoopView.h
//  RSInfiniteloopImageView
//
//  Created by ruosu on 2017/4/13.
//  Copyright © 2017年 ruosu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSImageLoopView : UIView

// 默认渲染颜色
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
// 当前页面颜色
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
@property (nonatomic, assign) CGSize pageControlSize;
@property (nonatomic, assign) CGPoint pageControlCenter;
@property (nonatomic, assign) NSUInteger visibleImageIndex;

+ (instancetype)imageLoopViewWithImageArray:(NSArray *)imageArray frame:(CGRect)frame timeInterval:(NSTimeInterval)timeInterval;
// 在所属控制器dealloc或者viewwilldisappear中清空定时器
- (void)stopTimer;
- (void)addTarget:(id)target action:(SEL)action;
@end
