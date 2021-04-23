# BannerView

## 缩放轮播图 PZScaleCycleView<br> 
1、里面有个ScaleBannerView
2、添加代码：<br>

```
    PZScaleCycleView *cycleView = [[PZScaleCycleView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width  * .5) WithAnimationDuration:3];
        cycleView.isCycle = 1;
        cycleView.scaleNum = 0.9;
        cycleView.imgWidth = [UIScreen mainScreen].bounds.size.width * .7;
        cycleView.imgArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
        [self addSubview:cycleView];
        __weak typeof(self) weakSelf = self;
        cycleView.imgOnClick = ^(NSInteger index) {
            __strong typeof(self) strongSelf = weakSelf;
        };
```
    

### 注：NomalCycleView——————这个是平常通用的轮播图，一位同事写的
  示例：<br>
  ```  
    CycleScrollView *cycleScrollView = [[CycleScrollView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, maxTopConstraint) animationDuration:4];
    [self.view addSubview:cycleScrollView];
    cycleScrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    cycleScrollView.pageControl.currentPageIndicatorTintColor = Red_COLOR;
    cycleScrollView.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    __block NSArray *blockArr = @[@"1.png",@"2.png"];
    //开启定时器并添加三种状态的图片
    _cycleScrollView.fetchImagePathAtIndex = ^NSString *(NSInteger pageIndex){
        return blockArr[pageIndex];
    };
    _cycleScrollView.totalPagesCount = ^NSInteger(void){
        return blockArr.count;
    };
    
    __weak typeof(self) weakSelf = self;
    _cycleScrollView.TapActionBlock = ^(NSInteger pageIndex){
       __strong typeof(self) strongSelf = weakSelf;
      NSLog(@"点击了第%@页",pageIndex);
    };
 ```
   


