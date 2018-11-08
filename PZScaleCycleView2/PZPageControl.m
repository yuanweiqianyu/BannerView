//
//  PZPageControl.m
//  yys_ios
//
//  Created by 潘珍珍 on 2018/4/27.
//  Copyright © 2018年 YYS. All rights reserved.
//

#import "PZPageControl.h"

@implementation PZPageControl


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat dotW = 5.0;
    CGFloat dotH = 5.0;
    CGFloat magrin = 5.0;//
    //计算圆点间距
    CGFloat marginX = dotW + magrin;
    
    //计算整个pageControll的宽度
    CGFloat newW = (self.subviews.count - 1 ) * marginX;
    
    //设置新frame
    self.frame = CGRectMake(kScreenWidth/2-(newW + dotW)/2, self.frame.origin.y, newW + dotW, self.frame.size.height);
    
    //遍历subview,设置圆点frame
    for (int i=0; i<[self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        
        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotW, dotH)];
        }else {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotW, dotH)];
        }
    }
}

@end
