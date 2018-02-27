//
//  CycleScrollView.m
//  PagedScrollView
//
//  Created by 许杰 on 14-1-23.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
//

#import "CycleScrollView.h"
#import "NSTimer+Addition.h"

@interface CycleScrollView () <UIScrollViewDelegate>

@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentStringArr;
@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic , assign) NSTimeInterval animationDuration;

@end

@implementation CycleScrollView{
    float moveX;
}

@synthesize pageControl;
- (void)setTotalPagesCount_view:(NSInteger (^)(void))totalPagesCount_view
{
    _totalPageCount = totalPagesCount_view();
    if (_totalPageCount > 0 && _animationDuration > 0.0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self setContentViews];
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

//4.初始化——在cycleScrollView初始化中，第一个调用此方法
        //此时基本的scrollView和pageControl都以创建，从此方法开始，开启定时器和添加图片

//总的页数
- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    _totalPageCount = totalPagesCount();
    //容错处理——单只有一张图片，或者缺少数据
    if(_totalPageCount <= 1)
    {
        [self configContentViews];
        //自定义添加——一张时无法滑动
        self.scrollView.scrollEnabled = NO;
        
    }
    else if (_totalPageCount > 0 && _animationDuration > 0.0) {
        
         //自定义添加——多张滑动
        self.scrollView.scrollEnabled = YES;
        
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
           
                                                              repeats:YES];
        //添加图片（三张状态图——以前，当前，以后）
        [self configContentViews];
        
        //一段时间恢复定时器
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

//1.
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    self.animationDuration = animationDuration;
    return self;
}

//2.初始化
//（1）添加基本的scrollView和pageControl
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code自动尺寸调整行为-内嵌子视图的位置和尺寸适应原始视图的新尺寸
        self.autoresizesSubviews = YES;
        //设置UIScrollView的属性
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        //设置UIPageControl的属性
        self.pageControl = [[UIPageControl alloc]init];
        //当页数为1时，是否自动隐藏控制器
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.currentPageIndicatorTintColor =[UIColor whiteColor];
        self.pageControl.pageIndicatorTintColor = [UIColor orangeColor];
        self.pageControl.center = CGPointMake(frame.size.width * .5, frame.size.height - 10);
        [self addSubview:self.pageControl];

        self.currentPageIndex = 0;
    }
    return self;
}

#pragma mark - 私有函数
- (void)setContentViews
{
    self.pageControl.numberOfPages = _totalPageCount;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource_views];
    
    NSInteger counter = 0;
    for (UIView *view in self.contentViews)
    {
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [view addGestureRecognizer:tapGesture];
        view.frame = self.bounds;
        CGRect rightRect = view.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        view.frame = rightRect;
        [self.scrollView addSubview:view];
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

- (void)configContentViews
{
    self.pageControl.numberOfPages = _totalPageCount;
    
    //NSArray的用法——数组中的每一个元素都调用此方法
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
     //计算图片的页码排序（三种状态，以前，当前，以后）
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (NSString *imagePath in self.contentStringArr) {//contentStringArr存储了页码的状态_对应的第几张图片
        UIImageView *ib = [[UIImageView alloc]init];
        ib.contentMode = UIViewContentModeScaleAspectFit;
//        DCImageBox *ib = [[DCImageBox alloc]init];
//        ib.clipsToBounds = YES;//如果子视图的范围超出了父视图的边界，那么超出的部分就会被裁剪掉。
//        ib.source.placeholder = @"默认背景图.jpg";
//        ib.source.limitSize = 1024 * 1024;
//        [ib.source setUrl:imagePath fileName:nil];
        
        if ([imagePath containsString:@"http"]) {
            [ib sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:DEFAULT_BANNER_BG]];
//            [ib sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        }else if (imagePath!=nil&&![imagePath containsString:@"http"]) {
            ib.image = [UIImage imageNamed:imagePath];
            if (!ib.image) {
                ib.image = [UIImage imageNamed:DEFAULT_BANNER_BG];
            }
        }else{
            ib.image = [UIImage imageNamed:DEFAULT_BANNER_BG];
        }
        [ib setContentMode:UIViewContentModeScaleToFill];
        ib.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [ib addGestureRecognizer:tapGesture];
        ib.frame = self.bounds;
        CGRect rightRect = ib.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        ib.frame = rightRect;
        [self.scrollView addSubview:ib];
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    // 容错——没有数据时，创建一个空数组
    if (self.contentStringArr == nil) {
        self.contentStringArr = [@[] mutableCopy];
    }
    [self.contentStringArr removeAllObjects];
    //以前页数
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    
    //后来的页数
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    if (self.fetchImagePathAtIndex) {
        
        //使用数组记录图片的状态（以前，当前，以后）
        [self.contentStringArr addObject:self.fetchImagePathAtIndex(previousPageIndex)];
        [self.contentStringArr addObject:self.fetchImagePathAtIndex(_currentPageIndex)];
        [self.contentStringArr addObject:self.fetchImagePathAtIndex(rearPageIndex)];
    }
}

- (void)setScrollViewContentDataSource_views
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    if (self.fetchContentViewAtIndex) {
        [self.contentViews addObject:self.fetchContentViewAtIndex(previousPageIndex)];
        [self.contentViews addObject:self.fetchContentViewAtIndex(_currentPageIndex)];
        [self.contentViews addObject:self.fetchContentViewAtIndex(rearPageIndex)];
    }
}


#pragma mark-TongYongAction(通用方法——计算图片的页码)

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}


//3.初始化——scrollView初始化的时候调用两次（第二个自定义的方法时又调用了一次）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int contentOffsetX = scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * CGRectGetWidth(self.scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        if(_isViews)
        {
            [self setContentViews];
        }
        else
        {
            [self configContentViews];
        }
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        if(_isViews)
        {
            [self setContentViews];
        }
        else
        {
            [self configContentViews];
        }
    }
    self.pageControl.currentPage = self.currentPageIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark -
#pragma mark - 响应事件

//当计时器开启，重新设置scrollView的偏移量
- (void)animationTimerDidFired:(NSTimer *)timer
{
    //moveX-scrollView的偏移量
    if (!moveX) {
        moveX = self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame);
    }
    CGPoint newOffset = CGPointMake(moveX, self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
//    if (ShareApp.moveX != 0) {
//        return;
//    }
    
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

@end
