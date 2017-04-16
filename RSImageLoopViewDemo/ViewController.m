//
//  ViewController.m
//  RSImageLoopViewDemo
//
//  Created by ruosu on 2017/4/16.
//  Copyright © 2017年 ruosu. All rights reserved.
//

#import "ViewController.h"
#import "RSImageLoopView.h"
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
@interface ViewController ()
@property (nonatomic, weak) RSImageLoopView *imageLoopView; //weak strong 都可以
@end

@implementation ViewController

/*
 必须要实现,不然会有内存泄漏,轮播器释放不了,也可在viewwilldisappear实现
 具体原因见简书博客:http://www.jianshu.com/u/4f7decfc7fb4
 */
- (void)dealloc{
    [self.imageLoopView stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *imageArray = [self getImageArry];
    
    // 01 创建RSImageLoopView对象
    RSImageLoopView *imageLoopView = [RSImageLoopView imageLoopViewWithImageArray:imageArray frame:CGRectMake(0, 0, SCREEN_WIDTH, 200) timeInterval:1];
    self.imageLoopView  = imageLoopView;
    [self.view addSubview:imageLoopView];
    
    // 02 添加点击事件需要执行的方法
    [imageLoopView addTarget:self action:@selector(clickLoopView)];
}

// 实现点击方法
- (void)clickLoopView{
    // 获取点击轮播器需要的参数(点击的图片索引) 此时一般push或modal新的控制器
    NSUInteger index = self.imageLoopView.visibleImageIndex;
    NSLog(@"点击了第%ld张图片",index);
}

// 获取图片数组
- (NSArray *)getImageArry{
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i = 1; i <= 5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%i",i]];
        [imageArray addObject:image];
    }
    return imageArray;
}


@end
