//
//  NLHandleImageManager.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/3/28.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLHandleImageManager.h"
#import "GPUImage.h"
@implementation NLHandleImageManager

+(UIImage *)imageAddFilter:(UIImage *)originalImage filter:(GPUImageFilter *)filter{
    UIImage *newImage = originalImage;
    GPUImagePicture *imgPicture = [[GPUImagePicture alloc] initWithImage:originalImage];
    [imgPicture addTarget:filter];
    [filter useNextFrameForImageCapture];
    [imgPicture processImage];
    newImage = [filter imageFromCurrentFramebuffer];
    return newImage;
}


@end
