//
//  NLGPUImageView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/6/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLGPUImageView.h"
#import "GPUImage.h"

@interface NLGPUImageView()

@end

@implementation NLGPUImageView

-(instancetype)initWithFrame:(CGRect)frame videoCamera:(GPUImageStillCamera *)videoCamera{
    if (self = [super initWithFrame:frame]) {
        self.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    return self;
}


@end
