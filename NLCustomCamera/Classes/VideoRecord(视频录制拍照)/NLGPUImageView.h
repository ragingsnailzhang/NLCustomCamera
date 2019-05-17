//
//  NLGPUImageView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/6/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "GPUImageView.h"
#import "GPUImage.h"

@interface NLGPUImageView : GPUImageView

-(instancetype)initWithFrame:(CGRect)frame videoCamera:(GPUImageStillCamera *)videoCamera;

@end
