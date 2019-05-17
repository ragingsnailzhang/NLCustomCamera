//
//  NLHandleImageManager.h
//  AncientVillage
//
//  Created by yj_zhang on 2019/3/28.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLHandleImageManager : NSObject

+(UIImage *)imageAddFilter:(UIImage *)originalImage filter:(GPUImageFilter *)filter;

@end

NS_ASSUME_NONNULL_END
