//
//  PZScaleCycleView.m
//  ScaleCycleView
//
//  Created by 潘珍珍 on 2018/2/24.
//  Copyright © 2018年 pzz. All rights reserved.
//

#import "PZScaleCycleView.h"

@interface PZScaleCycleView ()<UIScrollViewDelegate>

/**所有图片容器**/
@property (nonatomic,strong)NSMutableArray *imgViewArr;
/**当前页**/
@property (nonatomic,assign)NSInteger currentIndex;
/**几秒滑动**/
@property (nonatomic , assign) NSTimeInterval animationDuration;

//是否手动滑动
@property (nonatomic,assign)NSInteger isDrag;

/**缩放的系数**/
@property (nonatomic,assign)CGFloat scaleFactor;

@property (nonatomic,assign)CGFloat lastOffsetX;

@end

@implementation PZScaleCycleView
- (id)initWithFrame:(CGRect)frame WithAnimationDuration:(NSTimeInterval)animationDuration{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.animationDuration = animationDuration;
        
        [self initSubviewUI];
    }
    return self;
}

- (void)initSubviewUI{
    self.scaleFactor = 0.0008;
    self.currentIndex = 0;
    [self addSubview:self.scrollView];
}

#pragma mark--set
- (void)setScaleNum:(CGFloat)scaleNum{
    _scaleNum = scaleNum;
}

- (void)setImgWidth:(CGFloat)imgWidth{
    _imgWidth = imgWidth;
}

- (void)setIsCycle:(NSInteger)isCycle{
    _isCycle = isCycle;
    
    if (self.isCycle==1) {
        self.currentIndex = 2;
    }
}


- (void)setImgArr:(NSArray *)imgArr{
    
    _imgArr = imgArr;
    
#warning 当前效果，两张图以上轮播，如需三张图 imgArr.count>2

    if (self.isCycle == 1 && imgArr.count>1) {
        NSString *lastImgStr = [imgArr lastObject];
        NSString *lastSecondImgStr = imgArr[imgArr.count - 2];
        NSString *firstImgStr = [imgArr firstObject];
        NSString *secondImgStr = imgArr[1];
        NSMutableArray *changeImgArr = [NSMutableArray arrayWithArray:_imgArr];
        [changeImgArr insertObject:lastImgStr atIndex:0];
        [changeImgArr insertObject:lastSecondImgStr atIndex:0];
        [changeImgArr addObject:firstImgStr];
        [changeImgArr addObject:secondImgStr];
        _imgArr = changeImgArr;
    }
    
    for (UIView *subViews in self.scrollView.subviews) {
        if ([subViews isKindOfClass:[UIImageView class]]) {
            [subViews removeFromSuperview];
        }
    }
    
    self.currentIndex = 0;
    if (self.imgArr.count>2) {
        self.currentIndex = 2;
    }
    
    [self.imgViewArr removeAllObjects];
    [self addScrollSubviews];//添加scrollView子视图
}

/**添加scrollView子视图**/
- (void)addScrollSubviews{
    
    
    _imgViewArr = [NSMutableArray array];
    
    CGFloat x = (self.frame.size.width - self.imgWidth) / 2.0;
    for (NSInteger i = 0; i<self.imgArr.count; i++) {
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake( x + i * self.imgWidth, 0, self.imgWidth, self.scrollView.frame.size.height)];
        NSString *imgFile = self.imgArr[i];
        if ([imgFile containsString:@"http://"] || [imgFile containsString:@"https://"]) {
           
            [imgView sd_setImageWithURL:[NSURL URLWithString:imgFile] placeholderImage:[UIImage imageNamed:@"hlh_placehoder_adv"]];
    
            
        }else{
            imgView.image = [UIImage imageNamed:imgFile];
        }
        [self.scrollView addSubview:imgView];
        [_imgViewArr addObject:imgView];
        imgView.backgroundColor = [UIColor whiteColor];
        [PZToolsCommon cornerRedius:imgView WithValue:10];

        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
        [imgView addGestureRecognizer:tapGes];
        imgView.userInteractionEnabled = YES;
        
        //一张照片平铺
//        if (self.imgArr.count==1) {
////            imgView.frame = self.bounds;
//            self.scrollView.scrollEnabled = NO;
//        }else{
//            self.scrollView.scrollEnabled = YES;
//        }
        
        
    }
    self.scrollView.contentSize = CGSizeMake(self.imgArr.count * self.scrollView.frame.size.width, 0);
    
    //isCycle 是否循环 0-否 1-是
    
    //记录中心点，为之后计算缩放系数准备
    CGFloat centerX = 0.0;
    
    if (self.isCycle==1 ) {
        
        CGFloat offsetX = 0;

#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

        if (self.imgArr.count>1) {
           
            CGFloat dif = (self.frame.size.width - self.imgWidth) / 2.0;
            UIImageView *centerImgView = self.imgViewArr[2];
            offsetX = centerImgView.frame.origin.x - dif ;
        }
        
        //一张照片平铺
        if (self.imgArr.count==1) {
            self.scrollView.contentOffset=CGPointZero;
            
        }else{
            self.scrollView.contentOffset=CGPointMake(offsetX, 0);
            //根据当前显示区的中心点对所有的图片进行缩放。
            
            if (self.imgArr.count==2) {
                centerX = self.imgWidth*0.5 + x;

            }else{
                
                centerX = self.imgWidth*0.5 + x + self.imgWidth + self.imgWidth;

            }
            
            //计算缩放的系数
            
            
            CGFloat distance = self.imgWidth;
            
            self.scaleFactor = (1.0 / self.scaleNum - 1.0) / distance;
           
            [self scaleImagevWithCenterX:centerX];

        }
        
       
        
    }else{
        self.scrollView.contentOffset=CGPointZero;
        centerX = self.imgWidth*0.5 + x;
        //根据当前显示区的中心点对所有的图片进行缩放。
        [self scaleImagevWithCenterX:centerX];
    }
    
#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

    if (self.imgArr.count>1) {
        if (self.animationTimer) {
            [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];

        }else{
            [self addTimer];
        }
    }else{
        [self.animationTimer pauseTimer];
    }
    
    
  
}

/**添加定时器**/
- (void)addTimer{
    
    if (self.imgArr.count > 2 && _animationDuration > 0 && !self.animationTimer) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
     

    }
}

#pragma mark--animationTimerDidFired:
- (void)animationTimerDidFired:(NSTimer *)timer{
    
    if (self.currentIndex<=1) {
        if (self.imgArr.count>1) {

            //                CGFloat dif = (self.frame.size.width - self.imgWidth) / 2.0;

            self.currentIndex = (self.imgViewArr.count - 3);
        }
     }else if(self.currentIndex>=self.imgArr.count - 2){
         if (self.imgArr.count>1) {

            self.currentIndex = 2 ;
         }
     }
    
    self.scrollView.contentOffset = CGPointMake(self.currentIndex * self.imgWidth, 0);

    
    CGFloat moveX = 0.0;
    if (!moveX) {
        moveX = self.scrollView.contentOffset.x + self.imgWidth;
    }
////    NSLog(@"%ld页",self.currentIndex);
//    if (moveX!=(self.currentIndex+1)*self.imgWidth) {
//        moveX = (self.currentIndex+1) *self.imgWidth;
//    }
    CGPoint newOffset = CGPointMake(moveX, self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
    self.currentIndex++;

    
//    NSLog(@"时间滑动到了第%ld",self.currentIndex);
}

#pragma mark --辅助方法
//对图片进行缩放的方法
-(void)scaleImagevWithCenterX:(CGFloat)centerx{
    for (UIImageView *imagev in self.imgViewArr) {
        //计算当前控件与显示区中心点的相对距离
        CGFloat distance = ABS(imagev.center.x - centerx);
        //设置缩放系数
        CGFloat factor=self.scaleFactor;
        //获取缩放倍数
        CGFloat scales=1/(1+distance*factor);
        //进行缩放
        imagev.transform=CGAffineTransformMakeScale(scales, scales);
    }
    
}

#pragma mark--TapGesture
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture{
    
    NSInteger index = [self.imgViewArr indexOfObject:tapGesture.view];
    
    NSInteger tagIndex = 0;
    
    tagIndex = index;
    if (self.isCycle) {

#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2
        
        if (self.imgArr.count>1) {
            if (index<=1) {
                
                tagIndex = self.imgArr.count - 4  - index;

            }else if (index>1 && index< self.imgArr.count - 4 + 2){
               
                tagIndex = index - 2;
                
            }else{
    
                tagIndex = index - 2 - (self.imgArr.count - 4);
            }
        }
    }else{
        
    }
    
    NSLog(@"点击了第%ld张",tagIndex);
    
#warning 当前效果，两张图以上轮播，如需三张图 隐藏****中代码
//*****
    //两张图时的容错处理
    if (self.imgArr.count==6) {
        if (tagIndex<0) {
            tagIndex = 0;
        }else if (tagIndex>1){
            tagIndex = 1;
        }
    }
//*****
    if (self.imgOnClick) {
        self.imgOnClick(tagIndex);
    }
    
//    NSInteger inde = self.currentIndex;
//    self.scrollView.contentOffset = CGPointMake((kScreenWidth - YWidth(60.0)) * self.currentIndex, 0);
//    self.currentIndex = index;
    
    CGFloat changeX = fabs(self.currentIndex * self.imgWidth - self.scrollView.contentOffset.x) > fabs((self.currentIndex + 1) * self.imgWidth - self.scrollView.contentOffset.x) ? (self.currentIndex + 1) * self.imgWidth : self.currentIndex * self.imgWidth;
    self.currentIndex = changeX / self.imgWidth;
    
    [self.scrollView setContentOffset:CGPointMake(changeX, 0) animated:YES];
    self.lastOffsetX = self.currentIndex * self.imgWidth;
}

#pragma mark--超范围处理
/**滑动超出图片原本张数，进行循环操作（超范围处理）**/
- (void)scrollOver{
   
#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

    //isCycle 是否循环 0-否 1-是
    if (self.isCycle==1 && self.imgArr.count>1) {
        
        if (self.currentIndex<=1) {
            
            CGFloat offsetX = 0;
#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

            if (self.imgArr.count>1) {
                
//                CGFloat dif = (self.frame.size.width - self.imgWidth) / 2.0;
                
                offsetX = self.imgWidth * (self.imgViewArr.count - 3);
            }
            
            
            self.scrollView.contentOffset=CGPointMake(offsetX, 0);
            
            self.currentIndex = self.imgViewArr.count - 3;
            
        }else if(self.currentIndex>=self.imgArr.count - 2){
            
            CGFloat offsetX = 0;
#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

            if (self.imgArr.count>1) {
                
//                CGFloat dif = (self.frame.size.width - self.imgWidth) / 2.0;

#warning 重新设置的距离一样，但是滑动的距离却不同
                if (self.isDrag == 1) {
                    offsetX = self.imgWidth * 2 ;

                }else{
                    
                    offsetX = self.imgWidth * 1 ;

                }
            }
            
            self.scrollView.contentOffset=CGPointMake(offsetX, 0);
            self.currentIndex = 2;
            
        }
    }
    
}


#pragma mark--UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
//    if (self.isCycle==1) {
//        self.scrollView.userInteractionEnabled = NO;
//
//    }
    
    [self.animationTimer pauseTimer];
    
    self.isDrag = 1;
    
    if (self.scrollPage) {
        self.scrollPage(self.currentIndex - 2);
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
    CGFloat x = (self.frame.size.width - self.imgWidth) / 2.0;
    CGFloat centerX = self.scrollView.contentOffset.x + x + self.imgWidth*0.5;
    [self scaleImagevWithCenterX:centerX];
    
    if (self.isDrag!=1) {
         [self scrollOver];
    }else{

#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

        if (self.imgArr.count>1) {
            if (scrollView.contentOffset.x< self.imgWidth) {
                scrollView.contentOffset = CGPointMake(self.imgWidth, 0);
                
                self.scrollView.contentOffset=CGPointMake(self.imgWidth * (self.imgViewArr.count - 3), 0);
                self.currentIndex = self.imgViewArr.count - 3;
            }else if (scrollView.contentOffset.x > (self.imgArr.count - 2) * self.imgWidth){
                self.scrollView.contentOffset = CGPointMake(self.imgWidth * 2, 0);
                self.currentIndex = 2;
            }
        }
      
    }
}



- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    /**
     *  targetContentOffset(指向结构体的指针) 目标偏移量
     视图滑动停止时的偏移量
     
     velocity:  x:X轴的速度  y:Y轴的速度
     
     */
    
    //单元格宽度
    CGFloat width = self.imgWidth;
    
    //目标偏移量
    CGFloat offset = targetContentOffset -> x;
    
    //最终要停留的页数
    NSInteger index =  (offset + width / 2) / width;
    
    if (ABS(index - self.currentIndex)>1) {
//        NSLog(@"大于1页");
        if (index>self.currentIndex) {
            index = self.currentIndex+1;
        }else{
            index = self.currentIndex - 1;
        }
    }
    
//    NSLog(@"最终要停留的页数:%ld",index);
    
    if (index == _currentIndex) {
        
        //判断滑动速度,如果速度比较快,直接到下一页(向左滑)
        if (velocity.x > .4 && index < self.imgArr.count - 1) {
            
            index++;
            
            //向右滑
        }else if(velocity.x < -.4 && index > 0){
            
            index--;
            
        }
    }
    
    //容错处理(必须处理,计算出的页数,可能会超出数组的界限)
    if (index < 0) {
        
        index = 0;
        
    }else if(index >= self.imgArr.count){
        
        index = self.imgArr.count - 1;
        
    }
   
#warning 循环的最后一张和第一张有很明显卡顿
//    if (index==1) {
//        index = self.imgArr.count - 3;
//    }else if (index>=self.imgArr.count-2){
//        index = 2;
//    }
    
    //调整最终的位置
    targetContentOffset -> x = index * width;
//    NSLog(@"x轴的速度为%f",velocity.x);
    
    //    _currentIndex = index;
    
    //更改当前页
    self.currentIndex = index;
    self.lastOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
//
    if (self.isDrag==1) {
        [self scrollOver];
    }
//    if (self.isCycle==1) {
//        self.scrollView.userInteractionEnabled = YES;
//
//    }

    self.isDrag = 0;
    
    [self adjustTheDistance:scrollView];
    
    if (self.scrollPage) {

#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

        if (self.imgArr.count>1) {
            self.scrollPage(self.currentIndex - 2);

        }else{
            self.scrollPage(self.currentIndex);

        }
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{

    
    [self adjustTheDistance:scrollView];

    if (self.scrollPage) {

#warning 当前效果，两张图以上轮播，如需三张图 self.imgArr.count>2

        if (self.imgArr.count>1) {
            
            self.scrollPage(self.currentIndex - 2);
            
        }else{
            self.scrollPage(self.currentIndex);
            
        }
    }
 
    
}


- (void)adjustTheDistance:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x != self.currentIndex * self.imgWidth) {
        
        //左滑
        if (scrollView.contentOffset.x - self.lastOffsetX>0) {
            //            NSLog(@"左滑");
            CGFloat changeX = fabs(self.currentIndex * self.imgWidth - scrollView.contentOffset.x) > fabs((self.currentIndex - 1) * self.imgWidth - scrollView.contentOffset.x) ? (self.currentIndex - 1) * self.imgWidth : self.currentIndex * self.imgWidth;
            self.currentIndex = changeX / self.imgWidth;
            
            if ([[UIDevice currentDevice].systemVersion integerValue]<10.0) {
                self.scrollView.contentOffset = CGPointMake(changeX, 0);

            }else{
                [self.scrollView setContentOffset:CGPointMake(changeX, 0) animated:YES];

            }

            self.lastOffsetX = self.currentIndex * self.imgWidth;
            
//            NSLog(@"调整距离-右");
            
        }else{
            //右滑
            
            CGFloat changeX = fabs(self.currentIndex * self.imgWidth - scrollView.contentOffset.x) > fabs((self.currentIndex + 1) * self.imgWidth - scrollView.contentOffset.x) ? (self.currentIndex + 1) * self.imgWidth : self.currentIndex * self.imgWidth;
            self.currentIndex = changeX / self.imgWidth;
            
             if ([[UIDevice currentDevice].systemVersion integerValue]<10.0) {
                 self.scrollView.contentOffset = CGPointMake(changeX, 0);

             }else{
                 [self.scrollView setContentOffset:CGPointMake(changeX, 0) animated:YES];

             }
            
            self.lastOffsetX = self.currentIndex * self.imgWidth;
            
//            NSLog(@"调整距离-左");
            
        }
        
        
    }else{
        self.lastOffsetX = scrollView.contentOffset.x;
        
    }
    
}




#pragma mark--lazy load
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.pagingEnabled = NO;
        _scrollView.clipsToBounds = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end
