//
//  NLRecordManager.h
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/25.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLRecordParam.h"
#import <GPUImage/GPUImage.h>
#import "NLGPUImageView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NLRecordManagerVCDelegate <NSObject>
//录制完成
-(void)recordFinishedWithOutputFileURL:(NSURL *)fileURL RecordTime:(CGFloat)recordTime;
//录制时间
-(void)reloadRecordTime:(CGFloat)time;
//隐藏闪光灯
-(void)lightIsHidden:(BOOL)isHidden;
//添加预览view
-(void)showPreviewView:(NLGPUImageView *)displayView;

@end

@protocol NLRecordManagerDelegate <NSObject>

@optional
//获取拍摄的照片
-(void)getTakenPhoto:(UIImage *)photo;
//获取视频数据流
-(void)getVideoData:(NSData *)outputData URL:(NSURL *)outputURL;
//录制时间
-(void)getRecordTime:(CGFloat)time;
//录制封面
-(void)getRecordVideoCoverURL:(NSURL *)coverURL image:(UIImage *)coverImage;
//获取视频数据流,录制封面
-(void)getVideoData:(NSData *)outputData dataURL:(NSURL *)outputURL coverURL:(NSURL *)coverURL coverImage:(UIImage *)coverImage recordTime:(CGFloat)recordTime;

@end

@interface NLRecordManager : NSObject

/*** 是否在录制*/
@property(nonatomic,assign)BOOL isRecording;
/** 视频参数 */
@property(nonatomic,strong)NLRecordParam *recordParam;

@property(nonatomic,weak)id <NLRecordManagerVCDelegate>vcDelegate;

@property(nonatomic,weak)id <NLRecordManagerDelegate>delegate;

+(NLRecordManager *)shareManager;

+(UIViewController *)getRecordViewController;

//配置参数
-(void)configVideoParamsWithRecordParam:(NLRecordParam *)param;
//拍照
-(void)shootPhoto;
//拍照结束
-(void)endShootPhoto;
//保存照片
-(void)savePhoto;
//获取拍摄照片
-(UIImage *)getPhoto;
//开始录制
-(void)startRecord;
//停止录制
-(void)endRecord;
//切换摄像头
-(void)turnCamera;
//闪光灯
-(void)changeLightWithState:(AVCaptureTorchMode)state;
//改变滤镜
-(void)changeFilter:(GPUImageFilter *)filter;
//美颜
-(void)isOpenBeauty:(BOOL)isBeauty;
//保存视频
-(void)saveVideo;
//视频压缩
-(void)videoCompressionURL:(NSURL *)videoURL CompletionHandler:(void (^)(NSURL *))handler;
//停止重力感应
-(void)stopDeviceMotionUpdates;

@end

NS_ASSUME_NONNULL_END
