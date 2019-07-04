//
//  NLPhotoViewController.m
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/22.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import "NLPhotoViewController.h"
#import "NLRecordManager.h"
#import "NLTopOptionsView.h"
#import "NLRecordView.h"
#import "NLBottomOptionsView.h"
#import "NLGPUImageView.h"
#import "NLSettingView.h"
#import <objc/runtime.h>
#import "NLFilterView.h"
#import "NLConfigure.h"
#import "TBMoviePlayer.h"
#import "TZImagePickerController.h"
#import "UIImage+NLImage.h"

@interface NLPhotoViewController ()<NLRecordManagerVCDelegate,NLTopOptionsViewDelegate,NLRecordViewDelegate,NLFilterViewDelegate,NLBottomOptionsViewDelegate,NLSettingViewDelegate,TZImagePickerControllerDelegate>
//顶部View
@property(nonatomic,strong)NLTopOptionsView *topView;
//录制View
@property(nonatomic,strong)NLRecordView *recordView;
//录制时间View
@property(nonatomic,strong)NLTimeView *recordTimeView;
//选项View
@property(nonatomic,strong)NLBottomOptionsView *optionsView;
//设置界面
@property(nonatomic,strong)NLSettingView *setView;
//滤镜界面
@property(nonatomic,strong)NLFilterView *filterView;
//视频输出路径
@property(nonatomic,strong)NSURL *outputFileURL;
//录制参数
@property(nonatomic,strong)NLRecordParam *param;
//标志
@property(nonatomic,assign)NSInteger flag;
//播放界面
@property(nonatomic,strong)TBMoviePlayer *playerVC;
//当前滤镜
@property(nonatomic,assign)NSInteger currentFilterIndex;

@end

@implementation NLPhotoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBarHidden=YES;
#pragma clang diagnostic pop
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBarHidden=NO;
#pragma clang diagnostic pop
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self initData];
    [self checkPhotoStatus];
}
//MARK:Data
-(void)initData{
    self.flag = 0;
    self.param = [NLRecordManager shareManager].recordParam;
}
//MARK:ConfigureView
-(void)configureView{
    //导航View
    self.topView = [[NLTopOptionsView alloc]initWithFrame:CGRectMake(0, SAFEAREA_TOP_HEIGH-STATUS_HEIGHT/2, KSCREEN_WIDTH, 40)];
    self.topView.delegate = self;
    self.topView.beautyBtn.hidden = !self.param.isShowBeautyBtn;
    [self.view addSubview:self.topView];
    
    //录制时间View
    self.recordTimeView = [[NLTimeView alloc]initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, 35+SAFEAREA_TOP_HEIGH-20)];
    self.recordTimeView.hidden = !self.topView.hidden;
    [self.view addSubview:self.recordTimeView];
    
    //录制按钮View
    CGFloat recordHeight = TIMEVIEW_HEIGHT+STARTBTN_WIDTH+MARGIN*2.0;
    CGFloat y = KSCREEN_HEIGHT-SAFEAREA_BOTTOM_HEIGH-recordHeight;
    self.recordView = [[NLRecordView alloc]initWithFrame:CGRectMake(0, y, KSCREEN_WIDTH, recordHeight)];
    self.recordView.delegate = self;
    [self.view addSubview:self.recordView];
    
    //保存取消View
    self.optionsView = [[NLBottomOptionsView alloc]initWithFrame:CGRectMake(0, KSCREEN_HEIGHT-SAFEAREA_BOTTOM_HEIGH-(STARTBTN_WIDTH+MARGIN*2.0), KSCREEN_WIDTH, STARTBTN_WIDTH)];
    self.optionsView.hidden = YES;
    self.optionsView.delegate = self;
    [self.view addSubview:self.optionsView];
}
//MARK:准备录制/录制结束
//准备录制
-(void)readyRecordVideo{
    [NLRecordManager shareManager].vcDelegate = self;
    self.param.isBeauty = self.topView.beautyBtn.selected;
    [[NLRecordManager shareManager]configVideoParamsWithRecordParam:self.param];
}
//结束录制
-(void)recordFinished{
    [[NLRecordManager shareManager] endRecord];
    objc_setAssociatedObject(self.topView.lightBtn, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.topView.lightBtn setImage:[UIImage getBundleImageWithName:@"record_light_off" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    [[NLRecordManager shareManager]changeLightWithState:AVCaptureTorchModeOff];
}
//MARK:NLTopOptionsViewDelegate
//关闭界面
-(void)close{
    [self recordFinished];
    [[NLRecordManager shareManager] changeFilter:[GPUImageFilter new]];
    [[NLRecordManager shareManager] stopDeviceMotionUpdates];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//切换摄像头
-(void)turnCamera:(UIButton *)sender{
    sender.enabled = NO;
    [[NLRecordManager shareManager] turnCamera];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}
//闪光灯
-(void)light:(UIButton *)sender{
    NSString *state = objc_getAssociatedObject(sender, "light_state");
    if ([state isEqualToString:@"record_light_off"]) {
        objc_setAssociatedObject(sender, "light_state", @"record_light_on", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage getBundleImageWithName:@"record_light_on" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
        [[NLRecordManager shareManager]changeLightWithState:AVCaptureTorchModeOn];
        
    }else if ([state isEqualToString:@"record_light_on"]){
        objc_setAssociatedObject(sender, "light_state", @"record_light_auto", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage getBundleImageWithName:@"record_light_auto" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
        [[NLRecordManager shareManager]changeLightWithState:AVCaptureTorchModeAuto];
    }else{
        objc_setAssociatedObject(sender, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage getBundleImageWithName:@"record_light_off" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
        [[NLRecordManager shareManager]changeLightWithState:AVCaptureTorchModeOff];
    }
}
//美颜
-(void)beauty:(UIButton *)sender{
    sender.selected = !sender.selected;
    [[NLRecordManager shareManager]isOpenBeauty:sender.selected];
}
//MARK:NLRecordViewDelegate
//更新界面
-(void)updateViewWithOptionsViewHidden:(BOOL)isHidden{
    self.optionsView.hidden = isHidden;
    self.recordView.hidden = !self.optionsView.hidden;
    self.recordTimeView.hidden = self.recordView;
    if (self.param.getCurrentMode == videoMode) {
        self.topView.hidden = [NLRecordManager shareManager].isRecording;
    }else{
        self.topView.hidden = !self.optionsView.hidden;
    }
}
//显示滤镜界面
-(void)showFilterView{
    self.recordView.hidden = YES;
    NLFilterView *filterView = [[NLFilterView alloc]initWithFrame:CGRectMake(0, KSCREEN_HEIGHT-SAFEAREA_BOTTOM_HEIGH-120, KSCREEN_WIDTH, 120)];
    self.filterView = filterView;
    filterView.viewStyle = blackViewStyle;
    filterView.currentFilterIndex = self.currentFilterIndex;
    filterView.delegate = self;
    [self.view addSubview:filterView];
}
-(void)showAlbum{
    TZImagePickerController * pickerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:1  delegate:self];
    pickerVC.allowTakePicture=NO;
    pickerVC.allowPickingVideo=NO;
    [self presentViewController:pickerVC animated:YES completion:nil];
}
//MARK:NLFilterViewDelegate
-(void)changeFilter:(GPUImageFilter *)filter currentFilterIndex:(NSInteger)currentFilterIndex{
    self.currentFilterIndex = currentFilterIndex;
    [[NLRecordManager shareManager]changeFilter:filter];
}
//MARK:NLGPUVideoRecordManagerVCDelegate
-(void)recordFinishedWithOutputFileURL:(NSURL *)fileURL RecordTime:(CGFloat)recordTime{
    if (recordTime < self.param.minTime) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"录制时长少于%fS,请重新录制!",self.param.minTime] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self cancleClick];
        }];
        [alter addAction:action];
        [self presentViewController:alter animated:YES completion:nil];
    }
    self.outputFileURL = fileURL;
}
//更新时间状态
-(void)reloadRecordTime:(CGFloat)time{
    self.recordTimeView.hidden = time>0 ? NO:YES;
    [self.recordTimeView reloadTime:(long)floorf(time)];
    [self.recordView.progressView updateProgressWithValue:time/self.param.maxTime];
}
//闪光灯隐藏与否
-(void)lightIsHidden:(BOOL)isHidden{
    self.topView.lightBtn.hidden = isHidden;
}
//添加视频采集界面
-(void)showPreviewView:(GPUImageView *)displayView{
    [self.view addSubview:displayView];
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.recordView];
    [self.view bringSubviewToFront:self.optionsView];
    [self.view bringSubviewToFront:self.recordTimeView];

}
//MARK:NLBottomOptionsViewDelegate
-(void)selectedClick{
    [self updateViewWithOptionsViewHidden:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.param.getCurrentMode == videoMode) {//视频
            //保存视频
            [[NLRecordManager shareManager]saveVideo];
            
            [self.playerVC removeFromParentViewController];
            [self.playerVC.view removeFromSuperview];
            
            [self reloadRecordTime:0];
        }else{//照片
            [[NLRecordManager shareManager]savePhoto];
        }
        [self close];
    });
}

-(void)showPreviewVideo{
    if (self.outputFileURL) {
        self.playerVC = [TBMoviePlayer new];
        self.playerVC.model.videoURL= self.outputFileURL;
        [self addChildViewController:self.playerVC];
        [self.view insertSubview:self.playerVC.view belowSubview:self.optionsView];
    }
}
-(void)cancleClick{
    [self updateViewWithOptionsViewHidden:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.param.getCurrentMode == videoMode) {//视频
            [self.playerVC removeFromParentViewController];
            [self.playerVC.view removeFromSuperview];
            [self reloadRecordTime:0];
        }
        [self readyRecordVideo];
    });
}
//MARK:NLSettingViewDelegate
-(void)closeSettingView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK:TZImagePickerControllerDelegate
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSLog(@"拿到图片:%@",photos.firstObject);
}
//MARK:状态检测
-(NLSettingView *)setView{
    if (_setView == nil) {
        _setView = [[NLSettingView alloc]initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT)];
        _setView.delegate = self;
    }
    return _setView;
}
//麦克风状态
-(BOOL)checkAudioStatus{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        if (self.flag == 0) {
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"无法使用麦克风" message:@"您未开启麦克风,录制视频将没有声音" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
                [self close];
                self.flag = 0;
            }];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                self.flag = 0;
            }];
            
            [alter addAction:action];
            [alter addAction:action1];
            [self showViewController:alter sender:nil];
        }
        return NO;
    }else{
        return YES;
    }
}

//相机状态
-(void)checkPhotoStatus{
    __weak __typeof(&*self)weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined){
        [self.view addSubview:self.setView];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self checkPhotoStatus];
                });
            }
        }];
    }else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [self.view addSubview:self.setView];
    }else{
        [self.setView removeFromSuperview];
        [self configureView];
        [self readyRecordVideo];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf checkAudioStatus];
        });
    }
}
-(void)transitAnimation{
    //创建动画
    CATransition *animation = [CATransition animation];
    //设置运动轨迹的速度
    //    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    //设置动画类型
    animation.type = kCATransitionFade;
    //设置动画时长
    animation.duration = 0.5f;
    //设置运动的方向
    animation.subtype = kCATransitionFromRight;
    
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:@"animation"];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.filterView.window) {
        self.recordView.hidden = NO;
        [self.filterView removeFromSuperview];
    }
}

-(void)dealloc{
    NSLog(@"dealloc");
}


@end
