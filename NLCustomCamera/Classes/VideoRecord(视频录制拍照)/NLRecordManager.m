//
//  NLRecordManager.m
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/25.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import "NLRecordManager.h"
#import "NLGPUImageView.h"
#import "NLMotionManager.h"
#import "GPUImageBeautifyFilter.h"
#import "NLWaterMarkManager.h"
#import "NLLoadingView.h"
#import "NLPhotoViewController.h"
#import "NLFileManager.h"
#import "NLConfigure.h"

@interface NLRecordManager ()<GPUImageVideoCameraDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureMetadataOutputObjectsDelegate>
/** 摄像头 */
@property(nonatomic,strong)GPUImageStillCamera *shootCamera;
/** 视频写入 */
@property(nonatomic,strong)GPUImageMovieWriter *movieWriter;
/** 视频输出视图 */
@property(nonatomic,strong)NLGPUImageView *displayView;
/** 视频输出路径 */
@property(nonatomic,strong)NSURL *videoOutputURL;
/** 计时器 */
@property(nonatomic,strong)NSTimer *timer;
/** 时间 */
@property(nonatomic,assign)CGFloat time;
/** 当前界面 */
@property(nonatomic,strong)UIView *inView;
/** 当前格式,描述 */
@property(nonatomic,assign)CMFormatDescriptionRef currentFormatDescription;
/** 裁剪 */
@property(nonatomic,strong)GPUImageCropFilter *cropFilter;
/** 美颜 */
@property(nonatomic,strong)GPUImageBeautifyFilter *beautifyFilter;
/** 当前滤镜 */
@property(nonatomic,strong)GPUImageFilter *currentFilter;
/** 重力感应 */
@property(nonatomic,strong)NLMotionManager *motionManager;
//当前拍摄的图像
@property(nonatomic,strong)UIImage *currentShootImage;
//信号量
@property(nonatomic,copy)dispatch_semaphore_t semaphore;

@end

@implementation NLRecordManager

static NLRecordManager *manager = nil;
static dispatch_once_t onceToken;
+(NLRecordManager *)shareManager{
    dispatch_once(&onceToken, ^{
        manager = [[NLRecordManager alloc]init];
    });
    return manager;
}
+(UIViewController *)getRecordViewController{
    NLPhotoViewController *page = [[NLPhotoViewController alloc]init];
    return page;
}
-(instancetype)init{
    if (self = [super init]) {
        _motionManager = [[NLMotionManager alloc]init];
        _currentFilter = [GPUImageFilter new];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

//MARK:配置参数
-(void)initDataWithParam:(NLRecordParam *)param{
    self.recordParam = param;
    self.videoOutputURL = [NSURL fileURLWithPath:[self getVideoOutputPath]];
    self.time = 0.0f;
}
-(void)configVideoParamsWithRecordParam:(NLRecordParam *)param{
    [self initDataWithParam:param];
    
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(showPreviewView:)]) {
        [self.vcDelegate showPreviewView:self.displayView];
    }
    self.cropFilter = [GPUImageCropFilter new];
    self.cropFilter.cropRegion = [self getCropRect];
    [self isOpenBeauty:self.recordParam.isBeauty];
    [self.shootCamera startCameraCapture];
    //设置默认摄像头
    if (self.shootCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        [self turnCamera];
    }
}
//MARK:拍照
-(void)shootPhoto{
    __weak __typeof(&*self)weakSelf = self;
    [self.shootCamera capturePhotoAsImageProcessedUpToFilter:self.currentFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        NSLog(@"拍照%@",processedImage);
        weakSelf.currentShootImage = processedImage;
        [weakSelf endShootPhoto];
    }];
}
-(void)endShootPhoto{
    self.shootCamera.audioEncodingTarget = nil;
    [self.shootCamera stopCameraCapture];
}
-(void)savePhoto{
    if (self.currentShootImage) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(getTakenPhoto:)]) {
            [self.delegate getTakenPhoto:self.currentShootImage];
        }
        UIImageWriteToSavedPhotosAlbum(self.currentShootImage, nil, nil, nil);
        self.currentShootImage = nil;
    }
}
//获取拍摄照片
-(UIImage *)getPhoto{
    UIImage *photo = self.currentShootImage;
    return photo;
}
//MARK:录制视频
//开始录制
-(void)startRecord{
    unlink([self.videoOutputURL.absoluteString UTF8String]);
    self.isRecording = YES;
    CGSize outputSize = [self getVideoOutputSize:self.currentFormatDescription];
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.videoOutputURL size:outputSize fileType:AVFileTypeMPEG4 outputSettings:[self videoCompressionSettings:outputSize]];
    [self.movieWriter setHasAudioTrack:YES audioSettings:[self audioCompressionSettings]];
    self.movieWriter.encodingLiveVideo = YES;
    self.movieWriter.shouldPassthroughAudio = YES;
    self.movieWriter.transform = [self transformFromCurrentVideoOrientationToOrientation:AVCaptureVideoOrientationPortrait];
    self.movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
    
    [self.currentFilter addTarget:self.movieWriter];
    self.shootCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
    self.time = 0.0f;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
}
//停止录制
-(void)endRecord{
    @synchronized (self) {
        if (!self.isRecording) {
            self.shootCamera.audioEncodingTarget = nil;
            [self.shootCamera stopCameraCapture];
            return;
        }
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.isRecording = NO;
        self.shootCamera.audioEncodingTarget = nil;
        [self.shootCamera stopCameraCapture];
        __weak __typeof(&*self)weakSelf = self;
        [self.movieWriter finishRecordingWithCompletionHandler:^{
            [weakSelf.cropFilter removeTarget:weakSelf.movieWriter];
        }];
        
        if (self.time > 0) {
            if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(recordFinishedWithOutputFileURL:RecordTime:)]) {
                [self.vcDelegate recordFinishedWithOutputFileURL:self.videoOutputURL RecordTime:self.time];
            }
        }
    }
    
}
-(void)timeAction{
    if (self.time >= self.recordParam.maxTime) {
        [self endRecord];
    }
    self.time = self.time + 0.1f;
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(reloadRecordTime:)]) {
        [self.vcDelegate reloadRecordTime:self.time];
    }
}
//MARK:Action
//切换摄像头
-(void)turnCamera{
    [self.shootCamera pauseCameraCapture];
    [self.shootCamera rotateCamera];
    [self.shootCamera resumeCameraCapture];
    AVCaptureDevicePosition position = self.shootCamera.inputCamera.position;
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(lightIsHidden:)]) {
        [self.vcDelegate lightIsHidden: position == AVCaptureDevicePositionBack ? NO : YES];
    }
}
//闪光灯
-(void)changeLightWithState:(AVCaptureTorchMode)state{
    if ([self.shootCamera.inputCamera hasTorch]) {
        [self.shootCamera.inputCamera lockForConfiguration:nil];
        [self.shootCamera.inputCamera setTorchMode:state];
        [self.shootCamera.inputCamera unlockForConfiguration];
    }
}
//是否开启美颜
-(void)isOpenBeauty:(BOOL)isBeauty{
    [self.shootCamera pauseCameraCapture];
    [self.shootCamera removeAllTargets];
    [self.cropFilter removeAllTargets];
    self.recordParam.isBeauty = isBeauty;
    if (self.recordParam.isBeauty) {//开启美颜
        _beautifyFilter = [GPUImageBeautifyFilter new];
        [self.cropFilter addTarget:_beautifyFilter];
        [_beautifyFilter addTarget:self.currentFilter];
        [self.currentFilter addTarget:self.displayView];
    }else{
        [self.cropFilter addTarget:self.currentFilter];
        [self.currentFilter addTarget:self.displayView];
    }
    
    [self.shootCamera addTarget:self.cropFilter];
    [self.shootCamera resumeCameraCapture];
}
//更改滤镜
-(void)changeFilter:(GPUImageFilter *)filter{
    self.currentFilter = filter;
    [self isOpenBeauty:self.recordParam.isBeauty];
}
//保存视频
-(void)saveVideo{
    //压缩视频 YES/NO
    [self videoCompression:self.recordParam.isCompression Quality:mediumQuality CompletionHandler:^(NSURL *url) {
        //保存录制到本地
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) return ;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:url options:nil];
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if (success) {NSLog(@"成功保存视频到相簿.");}
            }];
        }];
        //回调获取视频资源
        [self callBackVideoData:url];
    }];
}
//回调获取视频资源
-(void)callBackVideoData:(NSURL *)url{
    //回调获取视频资源
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:URL:)]) {
        [self.delegate getVideoData:data URL:url];
        [self removeLoadingView];
    }
    //回调视频封面
    UIImage *cover = [NLFileManager getThumbnailImage:url];
    NSString *localCoverPath = [NLFileManager getVideoCoverWithImage:cover AndName:[url.absoluteString componentsSeparatedByString:@"/"].lastObject];
    if (self.delegate && [self.delegate respondsToSelector:@selector(getRecordVideoCoverURL:image:)]) {
        [self.delegate getRecordVideoCoverURL:[NSURL URLWithString:localCoverPath] image:cover];
        [self removeLoadingView];
    }
    //回调视频封面与视频资源
    if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:dataURL:coverURL:coverImage:recordTime:)]) {
        [self.delegate getVideoData:data dataURL:url coverURL:[NSURL URLWithString:localCoverPath] coverImage:cover recordTime:self.time];
        [self removeLoadingView];
    }
    //回调视频时间
    if (self.delegate && [self.delegate respondsToSelector:@selector(getRecordTime:)]) {
        [self.delegate getRecordTime:self.time];
        [self removeLoadingView];
    }
}
////MARK:视频压缩
////视频压缩(外调方法)
-(void)videoCompressionURL:(NSURL *)videoURL CompletionHandler:(void (^)(NSURL *))handler{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self addLoadingView];
    self.videoOutputURL = videoURL;
    [self videoCompression:YES Quality:mediumQuality CompletionHandler:handler];
    
}
//视频压缩
-(void)videoCompression:(BOOL)isComorossion Quality:(VideoQuality)quality CompletionHandler:(void (^)(NSURL *))handler{
    NSLog(@"before == %f M",[NLFileManager fileSize:self.videoOutputURL]);
    AVAssetExportSession *exportSession = nil;
    NSString *presetName = [self getPresetName:quality];
    
    if (isComorossion) {//压缩
        if (self.recordParam.waterMark) {//添加水印
            exportSession = [[NLWaterMarkManager shareWaterMarkManager]addWaterMarkWithTitle:self.recordParam.waterMark FilePath:self.videoOutputURL PresetName:presetName];
        }else{
            AVAsset *asset = [AVAsset assetWithURL:self.videoOutputURL];
            NSString *exportFileName = [self.videoOutputURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
            if ([[exportFileName lowercaseString]hasSuffix:@".mov"]) {
                exportFileName = [NSString stringWithFormat:@"%@.mp4",[[exportFileName lowercaseString] componentsSeparatedByString:@".mov"].firstObject];
            }
            exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:presetName];
            exportSession.shouldOptimizeForNetworkUse = YES;
            NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
            NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"compression_%ld_%@",time(0),exportFileName]];
            exportSession.outputURL = [NSURL fileURLWithPath:filePath];
            exportSession.outputFileType = AVFileTypeMPEG4;
        }
        
    }else{
        if (self.recordParam.waterMark) {//添加水印
            exportSession = [[NLWaterMarkManager shareWaterMarkManager]addWaterMarkWithTitle:self.recordParam.waterMark FilePath:self.videoOutputURL PresetName:AVAssetExportPresetHighestQuality];
        }else{
            if (handler) {
                handler(self.videoOutputURL);
            }
        }
    }
    __weak __typeof(&*self)weakSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        [weakSelf removeLoadingView];
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"AVAssetExportSessionStatusCompleted");
                NSLog(@"after == %f M",[NLFileManager fileSize:exportSession.outputURL]);
                if (handler) {
                    handler(exportSession.outputURL);
                }
                break;
            default:
                NSLog(@"AVAssetExportSessionStatusFailed");
                //                if (handler) {handler(nil);}
                break;
        }
        dispatch_semaphore_signal(weakSelf.semaphore);
        
    }];
}
//MARK:摄像头输出代理方法
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    self.currentFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
}
//MARK:视频相关参数设置
//获取视频输出路径
-(NSString *)getVideoOutputPath{
    NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
    NSString *videoPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video_%ld.mp4",time(0)]];
    return videoPath;
}
////获取输出视频大小
-(CGSize)getVideoOutputSize:(CMFormatDescriptionRef)currentFormatDescription{
    CGSize outputSize;
    NSInteger width = KSCREEN_WIDTH;
    NSInteger height = KSCREEN_HEIGHT;
    if (currentFormatDescription) {
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
        width = dimensions.height;
        height = dimensions.width;
    }
    
    switch (self.recordParam.ratio) {
        case NLShootRatio1To1:
            outputSize = CGSizeMake(width, width);
            break;
        case NLShootRatio4To3:
            outputSize = CGSizeMake(width, width*4/3);
            break;
        case NLShootRatio16To9:
            outputSize = CGSizeMake(width, width*16/9);
            break;
        case NLShootRatioFullScreen:
            outputSize = CGSizeMake(width, height);
            break;
        default:
            outputSize = CGSizeMake(width, height);
            break;
    }
    return outputSize;
}
//裁剪视频尺寸
-(CGRect)getCropRect{
    CGRect rect;
    switch (self.recordParam.ratio) {
        case NLShootRatio1To1:
            rect = CGRectMake(0, 0, 1, KSCREEN_WIDTH/KSCREEN_HEIGHT);
            break;
        case NLShootRatio4To3:
            rect = CGRectMake(0, 0, 1, 4*KSCREEN_WIDTH/(3*KSCREEN_HEIGHT));
            break;
        case NLShootRatio16To9:
            rect = CGRectMake(0, 0, 1, 16*KSCREEN_WIDTH/(9*KSCREEN_HEIGHT));
            break;
        case NLShootRatioFullScreen:
            rect = CGRectMake(0, 0, 1, 1);
            break;
        default:
            rect = CGRectMake(0, 0, 1, 1);
            break;
    }
    return rect;
}
//视频参数
-(NSDictionary *)videoCompressionSettings:(CGSize)outputSize{
    NSInteger width = outputSize.width;
    NSInteger height = outputSize.height;
    NSUInteger numPixels = width * height;
    CGFloat bitsPerPixel = 6.f;
    NSUInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    if (@available(iOS 11.0, *)) {
        NSDictionary *videoCompressionSettings = @{AVVideoCodecKey:AVVideoCodecTypeH264,
                                                   AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
                                                   AVVideoWidthKey:@(width),
                                                   AVVideoHeightKey:@(height),
                                                   AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                                     AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30],
                                                                                     AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel}
                                                   };
        return videoCompressionSettings;
    } else {
        // Fallback on earlier versions
        NSDictionary *videoCompressionSettings = @{AVVideoCodecKey:AVVideoCodecH264,
                                                   AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
                                                   AVVideoWidthKey:@(width),
                                                   AVVideoHeightKey:@(height),
                                                   AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                                     AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30],
                                                                                     AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel}
                                                   };
        return videoCompressionSettings;
    }
}
//音频参数
-(NSDictionary *)audioCompressionSettings{
    
    NSDictionary *audioCompressionSettings = @{AVEncoderBitRatePerChannelKey:@(28000),
                                               AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                               AVNumberOfChannelsKey:@(1),
                                               AVSampleRateKey:@(22050)};
    return audioCompressionSettings;
}
//视频录制质量
-(NSString *)getPresetName:(VideoQuality)quality{
    NSString *presetName = AVAssetExportPresetMediumQuality;
    if (quality == lowQuality) {
        presetName = AVAssetExportPresetLowQuality;
    }else if (quality == mediumQuality){
        presetName = AVAssetExportPresetMediumQuality;
    }else if (quality == highestQuality){
        presetName = AVAssetExportPresetHighestQuality;
    }
    return presetName;
}
//MARK:旋转视频

// 获取视频旋转矩阵
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.motionManager.videoOrientation];
    CGFloat angleOffset;
    angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    //    if (self.videoCamera.inputCamera.position == AVCaptureDevicePositionBack) {
    //        angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    //    } else {
    //        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    //    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

// 获取视频旋转角度
- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

// 当前设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}
//MARK:懒加载
// 摄像头
-(GPUImageStillCamera *)shootCamera {
    
    if (_shootCamera == nil) {
        _shootCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
        _shootCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _shootCamera.horizontallyMirrorFrontFacingCamera = YES;
        _shootCamera.delegate = self;
        // 可防止允许声音通过的情况下,避免第一帧黑屏
        [_shootCamera addAudioInputsAndOutputs];
    }
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(lightIsHidden:)]) {
        [self.vcDelegate lightIsHidden: _shootCamera.inputCamera.position == AVCaptureDevicePositionBack ? NO : YES];
    }
    return _shootCamera;
}
// 展示视图
-(NLGPUImageView *)displayView {
    CGSize size = [self getVideoOutputSize:nil];
    if (_displayView == nil || (!CGSizeEqualToSize(size, _displayView.frame.size))) {
        _displayView = [[NLGPUImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _displayView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    
    return _displayView;
}
//MARK:私有方法
//添加加载动画
-(void)addLoadingView{
    if (self.recordParam.currentVC.view) {
        self.inView = self.recordParam.currentVC.view;
    }else{
        self.inView = [self getCurrentVC].view;
    }
    if (![NSThread currentThread].isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NLLoadingView loadingViewWithTitle:@"正在处理视频..." inView:self.inView];
        });
    }else{
        [NLLoadingView loadingViewWithTitle:@"正在处理视频..." inView:self.inView];
    }
}
//移除加载动画
-(void)removeLoadingView{
    if ([NSThread currentThread].isMainThread) {
        for (UIView *view in self.inView.subviews) {
            if ([view isMemberOfClass:[NLLoadingView class]]) {
                [(NLLoadingView *)view stopAnimating];
                [view removeFromSuperview];
            }
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *view in self.inView.subviews) {
                if ([view isMemberOfClass:[NLLoadingView class]]) {
                    [(NLLoadingView *)view stopAnimating];
                    [view removeFromSuperview];
                }
            }
        });
    }
}

- (UIViewController *)getCurrentVC{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {// 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {// 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){// 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {// 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}
-(void)dealloc{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
-(void)stopDeviceMotionUpdates{
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

+(void)attemptDealloc{
    manager = nil;
    onceToken = 0l;
}

@end
