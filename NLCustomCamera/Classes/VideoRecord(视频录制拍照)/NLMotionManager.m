//
//  NLMotionManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/6/13.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface NLMotionManager()

@property(nonatomic, strong) CMMotionManager * motionManager;

@end

@implementation NLMotionManager

-(instancetype)init{
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1/15.0;
        if (!_motionManager.deviceMotionAvailable) {
            _motionManager = nil;
            return self;
        }
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
    return self;
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            _videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            _interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
        }
        else{
            _deviceOrientation = UIDeviceOrientationPortrait;
            _videoOrientation = AVCaptureVideoOrientationPortrait;
            _interfaceOrientation = UIInterfaceOrientationPortrait;
            
        }
    }
    else{
        if (x >= 0){
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            _videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            _interfaceOrientation = UIInterfaceOrientationLandscapeRight;
            
        }
        else{
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            _videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            _interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            
        }
    }
}

-(void)stopDeviceMotionUpdates{
    [_motionManager stopDeviceMotionUpdates];
}


@end
