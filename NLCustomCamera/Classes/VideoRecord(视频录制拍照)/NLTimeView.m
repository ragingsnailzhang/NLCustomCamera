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
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        [self configView];
    }
    return self;
}

-(void)configView{
    
    UILabel *lab = [[UILabel alloc]init];
    _timeLab = lab;
    lab.text = @"00:00";
    lab.textAlignment = NSTextAlignmentRight;
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:16.f];
    [self addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset((9+10)/2);
        make.centerY.equalTo(self);
    }];
    
    UIView *timeView = [UIView new];
    timeView.backgroundColor = [UIColor colorWithRed:245/255.0 green:21/255.0 blue:21/255.0 alpha:1];
    timeView.layer.cornerRadius = 4.5;
    [self addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lab.mas_left).offset(-10);
        make.centerY.equalTo(lab);
        make.size.mas_equalTo(CGSizeMake(9, 9));
    }];
}
-(void)reloadTime:(NSInteger)time{
    self.timeLab.text = [self formatTimeString:time];
}
-(NSString *)formatTimeString:(NSInteger)time{
    NSInteger hour = time / 3600;
    NSInteger min = (time % 3600) / 60;
    NSInteger sec = (time % 3600) % 60;
    NSString *hourStr = [NSString stringWithFormat:@"%@",hour > 0 ? [NSString stringWithFormat:@"%02ld:",hour] : @""];
    NSString *timeStr = [NSString stringWithFormat:@"%@%02ld:%02ld", hourStr, (long)min, (long)sec];
    return timeStr;
}

@end
