//
//  ViewController.m
//  VideoPlayerTestDemo
//
//  Created by xiaoling on 2018/5/11.
//  Copyright © 2018年 LSJ. All rights reserved.
//

#import "TBMoviePlayer.h"
#import "sys/utsname.h"
#import "NLConfigure.h"

@interface TBMoviePlayer ()<ZFPlayerDelegate>

@property(nonatomic,strong)UIView * fatherView;

@property(nonatomic,strong)ZFPlayerView * player;

@end

@implementation TBMoviePlayer
    
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//#pragma clang diagnostic pop

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//#pragma clang diagnostic pop

}
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.fatherView = [UIView new];
    self.fatherView.frame = CGRectMake(0, IS_PhoneXAll ? 24 : 0, KSCREEN_WIDTH, IS_PhoneXAll ? KSCREEN_HEIGHT-24-34 : KSCREEN_HEIGHT);
    [self.view addSubview:self.fatherView];

    self.model.fatherView = self.fatherView;
    self.model.placeholderImage =[self getImageWithColor:[UIColor blackColor] andHeight:0]; //初始加载时封面
    
    self.player = [[ZFPlayerView alloc]init];
    self.player.delegate = self;
    self.player.forcePortrait = YES;
    self.player.fullScreenPlay = YES;
    [self.player playerModel:self.model];
    [self.player autoPlayTheVideo];

}
//获取视频
- (UIImage*)getImageWithColor:(UIColor*)color andHeight:(CGFloat)height{
    CGRect r= CGRectMake(0.0f, 0.0f, KSCREEN_WIDTH, KSCREEN_HEIGHT);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (void)zf_playerBackAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (CGFloat)tz_statusBarHeight {
    return IS_PhoneXAll ? 44 : 20;
}

- (ZFPlayerModel *)model{
    if(!_model){
        _model = [ZFPlayerModel new];
    }
    return _model;
}

// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return NO;
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
