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
    self.fatherView.frame = CGRectMake(0, [self tz_isIPhoneX]?24:0, KSCREEN_WIDTH, [self tz_isIPhoneX]?KSCREEN_HEIGHT-24-34:KSCREEN_HEIGHT);
    [self.view addSubview:self.fatherView];

    self.model.fatherView = self.fatherView;
    self.model.placeholderImage =[self getImageWithColor:[UIColor blackColor] andHeight:0]; //初始加载时封面
    
    self.player = [[ZFPlayerView alloc]init];
    self.player.delegate = self;
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
    
- (BOOL)tz_isIPhoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
        // 模拟器下采用屏幕的高度来判断
        return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)));
    }
    // iPhone10,6是美版iPhoneX 感谢hegelsu指出：https://github.com/banchichen/TZImagePickerController/issues/635
    BOOL IPhoneX = [platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"];
    return IPhoneX;
}
    
- (CGFloat)tz_statusBarHeight {
    return [self tz_isIPhoneX] ? 44 : 20;
}

- (ZFPlayerModel *)model{
    if(!_model){
        _model = [ZFPlayerModel new];
    }
    return _model;
}

@end
