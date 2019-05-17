//
//  NLRecordParam.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLRecordParam.h"
#import "NLENUM.h"

@implementation NLRecordParam

+(instancetype)recordConfigWithVideoRatio:(NLShootRatio)ratio position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime isCompression:(BOOL)isCompression currentVC:(UIViewController *)currentVC{
    return [self recordConfigWithVideoRatio:ratio position:position maxRecordTime:maxTime minRecordTime:minTime isCompression:isCompression waterMark:nil currentVC:currentVC];
}

+(instancetype)recordConfigWithVideoRatio:(NLShootRatio)ratio position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime isCompression:(BOOL)isCompression waterMark:(NSString *)waterMark currentVC:(UIViewController *)currentVC{
    return [self recordConfigWithVideoRatio:ratio shootMode:photoVideoMode position:position maxRecordTime:maxTime minRecordTime:minTime isCompression:isCompression waterMark:waterMark isFilter:NO isShowBeautyBtn:NO isShowAlbumBtn:NO currentVC:currentVC];
}
//带水印,加滤镜
+(instancetype)recordConfigWithVideoRatio:(NLShootRatio)ratio shootMode:(NLShootMode)shootMode position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime isCompression:(BOOL)isCompression waterMark:(NSString *)waterMark isFilter:(BOOL)isFilter isShowBeautyBtn:(BOOL)isShowBeautyBtn isShowAlbumBtn:(BOOL)isShowAlbumBtn currentVC:(UIViewController *)currentVC{
    NLRecordParam *params = [[NLRecordParam alloc]init];
    params.ratio = ratio;
    params.position = position;
    params.maxTime = maxTime;
    params.minTime = minTime;
    params.isCompression = isCompression;
    params.isFilter = isFilter;
    params.waterMark = waterMark;
    params.currentVC = currentVC;
    params.isShowBeautyBtn = isShowBeautyBtn;
    params.shootMode = shootMode;
    params.isShowAlbumBtn = isShowAlbumBtn;
    return params;
}

@end
