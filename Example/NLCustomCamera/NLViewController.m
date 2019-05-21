//
//  NLViewController.m
//  NLCustomCamera
//
//  Created by wz_yinglong on 05/17/2019.
//  Copyright (c) 2019 wz_yinglong. All rights reserved.
//

#import "NLViewController.h"
#import <NLCustomCamera.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
@interface NLViewController ()

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"调用相机" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(200);
    }];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NLRecordParam *param = [NLRecordParam recordConfigWithVideoRatio:NLShootRatioFullScreen shootMode:photoVideoMode position:AVCaptureDevicePositionBack maxRecordTime:15.0f minRecordTime:1.0f isCompression:NO waterMark:nil isFilter:YES isShowBeautyBtn:NO isShowAlbumBtn:YES currentVC:self];
        [NLRecordManager shareManager].recordParam = param;
        NLPhotoViewController *page = [NLPhotoViewController new];
        [self presentViewController:page animated:YES completion:nil];
    }];
}
@end
