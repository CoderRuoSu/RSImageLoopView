//
//  RSImageLoopView.m
//  RSInfiniteloopImageView
//
//  Created by ruosu on 2017/4/13.
//  Copyright © 2017年 ruosu. All rights reserved.
//

#import "RSImageLoopView.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
static NSString * const reuseIdentifierID = @"Cell";

@interface RSImageLoopView ()<UICollectionViewDataSource,UICollectionViewDelegate>

// 轮播图片组成的数组
@property (nonatomic, strong) NSArray *imageArray;
// 轮播的UIImageView组成的数组
@property (nonatomic, strong) NSArray *imageViewArray;
// 轮播器的frame
@property (nonatomic, assign) CGRect viewFrame;
// 轮播的时间间隔
@property (nonatomic, assign) NSTimeInterval timeInterval;
// 定时器
@property (nonatomic, weak) NSTimer *timer;
// 点击事件对象和方法字符串
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL sel;

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation RSImageLoopView

// 在所属控制器dealloc或者viewwilldisappear中调用
- (void)stopTimer {
    [self removeTimer];
}

#pragma mark 类工厂和构造方法
+ (instancetype)imageLoopViewWithImageArray:(NSArray *)imageArray frame:(CGRect)frame timeInterval:(NSTimeInterval)timeInterval
{
    RSImageLoopView *imageLoopView = [[RSImageLoopView alloc]init];
    // 属性赋值
    imageLoopView.frame = frame;
    imageLoopView.timeInterval = timeInterval;
    imageLoopView.imageArray = imageArray;
    
    // 初始化view
    [imageLoopView initView];
    
    return imageLoopView;
}

- (instancetype)initWithImageArray:(NSArray *)imageArray frame:(CGRect)frame timeInterval:(NSTimeInterval)timeInterval
{
    if (self = [super init]) {
        // 属性赋值
        self.frame = frame;
        self.timeInterval = timeInterval;
        self.imageArray = imageArray;
        
        // 初始化view
        [self initView];
    }
    
    return self;
}
// 初始化view
- (void)initView {
    
    // 添加子控件,推荐使用懒加载
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    
    // 注册cell
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierID];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:50] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    // 添加定时器
    [self addTimerWithTimeInterval:self.timeInterval];
}

#pragma mark 接受用户点击
- (void)addTarget:(id)target action:(SEL)action {
    
    _target = target;
    self.sel = action;
}

- (void)tap {
    
    if (_sel) {
        SEL selector = _sel;
        IMP imp = [_target methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(_target, selector);
    }
}
#pragma mark 懒加载和图片属性
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = ({
            layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = self.frame.size;
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout;
        });
        
        UICollectionView *collectionView = ({
            collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.pagingEnabled = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            
            collectionView.dataSource = self;
            collectionView.delegate = self;
            
            // 添加点按手势
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
            [collectionView addGestureRecognizer:tapGestureRecognizer];
            
            _collectionView = collectionView;
            collectionView;
        });
        
    }
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        
        UIPageControl *pageControl = ({
            pageControl = [[UIPageControl alloc] init];
            pageControl.bounds = CGRectMake(0, 0, 150, 40); // pageControl的尺寸
            CGFloat height = self.frame.size.height - pageControl.bounds.size.height * 0.5;
            pageControl.center = CGPointMake(self.bounds.size.width * 0.5, height); // pageControl的位置
            pageControl.pageIndicatorTintColor = [UIColor blueColor];
            pageControl.currentPageIndicatorTintColor = [UIColor redColor];
            //pageControl.backgroundColor = [UIColor yellowColor];
            pageControl.enabled = NO;
            pageControl.numberOfPages = self.imageArray.count;
            
            _pageControl=pageControl;
            pageControl;
        });
        
    }
    return _pageControl;
}

- (NSArray *)imageViewArray {
    if (_imageViewArray == nil) {
        _imageViewArray = [NSArray array];
    }
    return _imageViewArray;
}

- (void)setImageArray:(NSArray *)imageArray {
    
    _imageArray = imageArray;
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (UIImage *image in imageArray) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = self.frame;
        [arrM addObject:imageView];
    }
    
    self.imageViewArray = arrM;
}

- (NSUInteger)visibleImageIndex {
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    return currentIndexPath.row;
}

#pragma mark 添加定时器
- (void)addTimerWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(nextpage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer ;
    
}

#pragma mark 删除定时器
- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextpage {
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:50];
    [self.collectionView scrollToItemAtIndexPath:currentIndexPathReset atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    NSInteger nextItem = currentIndexPathReset.item +1;
    NSInteger nextSection = currentIndexPathReset.section;
    if (nextItem==self.imageViewArray.count) {
        nextItem=0;
        nextSection++;
    }
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 100;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imageViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierID forIndexPath:indexPath];
    UIImageView *imageView = self.imageViewArray[indexPath.item];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:imageView];
    
    return cell;
}


#pragma mark <UICollectionViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

#pragma mark 当用户停止的时候调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimerWithTimeInterval:self.timeInterval];
}

#pragma mark 设置页码
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (int) (scrollView.contentOffset.x/scrollView.frame.size.width+0.5)%self.imageViewArray.count;
    self.pageControl.currentPage =page;
}

#pragma mark pageControl的相关属性
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (void)setPageControlSize:(CGSize)pageControlSize {
    self.pageControl.bounds = CGRectMake(0, 0, pageControlSize.width, pageControlSize.height);
}

- (void)setPageControlCenter:(CGPoint)pageControlCenter {
    self.pageControlCenter = pageControlCenter;
}

@end
