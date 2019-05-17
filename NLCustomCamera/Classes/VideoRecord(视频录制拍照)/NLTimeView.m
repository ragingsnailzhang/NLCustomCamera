//
//  NLTimeView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLTimeView.h"
#import <Masonry/Masonry.h>
#import "UIImage+NLImage.h"

#define TIME_MARGIN 10

@implementation NLTimeView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

-(void)configView{
    UIImageView *timeView = [[UIImageView alloc]initWithImage:[UIImage getBundleImageWithName:@"time_sign" className:NSStringFromClass([self class])]];
    [self addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(TIME_MARGIN);
        make.centerY.equalTo(self);
    }];
    
    UILabel *lab = [[UILabel alloc]init];
    _timeLab = lab;
    lab.text = @"00秒";
    lab.textAlignment = NSTextAlignmentRight;
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:14.f];
    [self addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-TIME_MARGIN);
        make.centerY.equalTo(self);
    }];
}

@end
