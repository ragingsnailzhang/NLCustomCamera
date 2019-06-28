//
//  NLTopOptionsView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/23.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLTopOptionsView.h"
#import "NLConfigure.h"
#import <objc/runtime.h>
#import "UIImage+NLImage.h"

@implementation NLTopOptionsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutViews];
    }
    return self;
}

-(void)layoutViews{
    //关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImg = [UIImage getBundleImageWithName:@"record_close" className:NSStringFromClass([self class])];
    self.closeBtn.frame = CGRectMake(MARGIN,(self.frame.size.height-closeImg.size.height)/2, closeImg.size.width, closeImg.size.height);
    [self.closeBtn setImage:closeImg forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
    
    //摄像头按钮
    self.cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraBtn.frame = CGRectMake(KSCREEN_WIDTH-MARGIN-35, self.closeBtn.center.y-15, 35, 30);
    [self.cameraBtn setImage:[UIImage getBundleImageWithName:@"record_camera" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    [self.cameraBtn addTarget:self action:@selector(turnCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraBtn];
    
    //闪光灯按钮
    self.lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lightBtn.frame = CGRectMake(self.cameraBtn.frame.origin.x-19-34, self.cameraBtn.center.y-15, 19, 30);
    [self.lightBtn setImage:[UIImage getBundleImageWithName:@"record_light_off" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    objc_setAssociatedObject(self.lightBtn, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:self.lightBtn];
    
    //美颜按钮
    self.beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyBtn.frame = CGRectMake(self.lightBtn.frame.origin.x-40-34, self.lightBtn.center.y-20, 40, 40);
    [self.beautyBtn setImage:[UIImage getBundleImageWithName:@"record_beauty_dis" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    [self.beautyBtn setImage:[UIImage getBundleImageWithName:@"record_beauty_on" className:NSStringFromClass([self class])] forState:UIControlStateSelected];
    [self addSubview:self.beautyBtn];
    
    [self.lightBtn addTarget:self action:@selector(light:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyBtn addTarget:self action:@selector(beauty:) forControlEvents:UIControlEventTouchUpInside];
    
}

//MARK:Action
//关闭界面
-(void)close{
    if (self.delegate && [self.delegate respondsToSelector:@selector(close)]) {
        [self.delegate close];
    }
}
//切换摄像头
-(void)turnCamera:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(turnCamera:)]) {
        [self.delegate turnCamera:sender];
    }
}
//闪光灯
-(void)light:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(light:)]) {
        [self.delegate light:sender];
    }
}
//美颜
-(void)beauty:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beauty:)]) {
        [self.delegate beauty:sender];
    }
}

@end
