//
//  NLRecordParam.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "NLENUM.h"

@interface NLRecordParam : NSObject
//摄像头位置
@property(nonatomic,assign)AVCaptureDevicePosition position;
//最大时长
@property(nonatomic,assign)CGFloat maxTime;
//最小时长
@property(nonatomic,assign)CGFloat minTime;
//是否压缩
@property(nonatomic,assign)BOOL isCompression;
//视频比例
@property(nonatomic,assign)NLShootRatio ratio;
//水印文字
@property(nonatomic,strong)NSString *waterMark;
//当前界面
@property(nonatomic,strong)UIViewController *currentVC;
//是否开启滤镜
@property(nonatomic,assign)BOOL isFilter;
//是否开启美颜
@property(nonatomic,assign)BOOL isBeauty;
//是否显示美颜
@property(nonatomic,assign)BOOL isShowBeautyBtn;
//是否显示美颜
@property(nonatomic,assign)BOOL isShowAlbumBtn;
//拍摄模式
@property(nonatomic,assign)NLShootMode shootMode;
//当前拍摄模式
@property(nonatomic,assign)NLShootMode getCurrentMode;

//基本
+(instancetype)recordConfigWithVideoRatio:(NLShootRatio)ratio position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime isCompression:(BOOL)isCompression currentVC:(UIViewController *)currentVC;

//带水印
+(instancetype)recordConfigWithVideoRatio:(NLShootRatio)ratio position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime isCompression:(BOOL)isCompression waterMark:(NSString *)waterMark currentVC:(UIViewController *)currentVC;

//带水印,加滤镜
+(instancetype)recordConfigWithVideoRatio:(NLShootRatio)ratio shootMode:(NLShootMode)shootMode position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime isCompression:(BOOL)isCompression waterMark:(NSString *)waterMark isFilter:(BOOL)isFilter isShowBeautyBtn:(BOOL)isShowBeautyBtn isShowAlbumBtn:(BOOL)isShowAlbumBtn currentVC:(UIViewController *)currentVC;
@end
