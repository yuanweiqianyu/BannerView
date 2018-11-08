//
//  PZScaleCycleView.h
//  ScaleCycleView
//
//  Created by 潘珍珍 on 2018/2/24.
//  Copyright © 2018年 pzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSTimer+Addition.h"

@interface PZScaleCycleView : UIView

@property (nonatomic,strong)UIScrollView *scrollView;
/**定时器**/
@property (nonatomic , strong) NSTimer *animationTimer;

#pragma mark--params
/**显示图片**/
@property (nonatomic,strong)NSArray *imgArr;
/**图片宽度**/
@property (nonatomic,assign)CGFloat imgWidth;
/**缩放的倍率**/
@property (nonatomic,assign)CGFloat scaleNum;
/**
 图片是否为轮播
 **
 **只有图片大于2张才能循环
 **/
@property (nonatomic,assign)NSInteger isCycle;

/**点击了第几张**/
@property (nonatomic,copy)void (^imgOnClick)(NSInteger index);

/**滑动到第几张**/
@property (nonatomic,copy)void(^scrollPage)(NSInteger index);


- (id)initWithFrame:(CGRect)frame WithAnimationDuration:(NSTimeInterval)animationDuration;




@end
