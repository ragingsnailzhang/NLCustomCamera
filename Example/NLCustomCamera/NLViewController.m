//
//  NLViewController.m
//  NLCustomCamera
//
//  Created by wz_yinglong on 05/17/2019.
//  Copyright (c) 2019 wz_yinglong. All rights reserved.
//

#import "NLViewController.h"
#import <NLCustomCamera.h>

@interface NLViewController ()

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NLRecordParam *param = [NLRecordParam recordConfigWithVideoRatio:NLShootRatioFullScreen shootMode:photoVideoMode position:AVCaptureDevicePositionBack maxRecordTime:15.0f minRecordTime:1.0f isCompression:NO waterMark:nil isFilter:YES isShowBeautyBtn:NO isShowAlbumBtn:YES currentVC:self];
    [NLRecordManager shareManager].recordParam = param;
    NLPhotoViewController *page = [NLPhotoViewController new];
    [self presentViewController:page animated:YES completion:nil];
}

@end
