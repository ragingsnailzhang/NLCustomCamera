//
//  NLMotionManager.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/6/13.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NLMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@property(nonatomic, assign)UIInterfaceOrientation interfaceOrientation;

-(void)stopDeviceMotionUpdates;

@end
