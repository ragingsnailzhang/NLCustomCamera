//
//  NLFontEditViewController.m
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/4/13.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import "NLFontEditViewController.h"
#import "NLFontView.h"
#import "NLFontSelectedView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NLConfigure.h"
#import "UIColor+NLCustomColor.h"
#import "UIImage+NLImage.h"

#define FONT_STYLE_VIEW_HEIGHT  120
#define BOTTOM_VIEW_HEIGHT  50


@interface NLFontEditViewController ()
//关闭
@property(nonatomic,strong)UIButton *closeBtn;
//展示view
@property(nonatomic,strong)UIImageView *showImgView;
//底部view
@property(nonatomic,strong)UIView *bottomView;
//文字相关
@property(nonatomic,strong)NLFontView *fontView;
//文字样式选择z界面
@property(nonatomic,strong)NLFontSelectedView *fontSelectView;

@end

@implementation NLFontEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self layoutMainView];
    [self layoutBottomView];
}
//MARK:Views
-(void)layoutMainView{
    self.showImgView = [[UIImageView alloc]initWithImage:self.originalImage];
    self.showImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.showImgView.userInteractionEnabled = YES;
    [self.view addSubview:self.showImgView];
    [self.showImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-BOTTOM_VIEW_HEIGHT);
        make.left.right.equalTo(self.view);
    }];
    //关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(MARGIN,(49-23)/2+SAFEAREA_TOP_HEIGH, 23, 23);
    [self.closeBtn setImage:[UIImage getBundleImageWithName:@"record_close" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    [self.view addSubview:self.closeBtn];
    [[self.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
-(void)layoutBottomView{
    self.bottomView = [UIView new];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(BOTTOM_VIEW_HEIGHT);
        make.left.right.equalTo(self.view);
    }];
    //线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:line];
    //文字
    UIButton *textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [textBtn setTitle:@"添加文本" forState:UIControlStateNormal];
    textBtn.titleLabel.font = [UIFont fontWithName:@"DINCondensed-Bold" size:17];
    [textBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.bottomView addSubview:textBtn];
    [textBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
    }];
    [[textBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        //隐藏关闭按钮
        self.closeBtn.hidden = YES;
        [self updateShowImgViewConstraints:YES];
        [self showFontEditViews];
    }];
    
    //取消
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.bottomView addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(20);
        make.centerY.equalTo(self.bottomView);
    }];
    [[cancleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self updateShowImgViewConstraints:NO];
        [self cleanFontView];
    }];
    
    //确认
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor hex:@"FF4800"] forState:UIControlStateNormal];
    [self.bottomView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-20);
        make.centerY.equalTo(self.bottomView);
    }];
    [[sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.fontView hiddenBorderAndEditBtn];
        UIImage *newImage = [self getImageSizeWithImage:self.showImgView toFrame:[self cropImageViewRect]];
        [self.showImgView setNeedsDisplay];
        self.showImgView.image = newImage;
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
        [self updateShowImgViewConstraints:NO];
        [self cleanFontView];
    }];
}
-(void)showFontEditViews{
    //字体选择界面
    if (self.fontSelectView.window == nil) {
        [self.view addSubview:self.fontSelectView];
        [self.fontSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bottomView.mas_top);
            make.left.right.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(KSCREEN_WIDTH, FONT_STYLE_VIEW_HEIGHT));
        }];
    }
    //文本框
    if (self.fontView.window == nil) {
        [self.showImgView addSubview:self.fontView];
        [self.fontView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.showImgView);
            make.size.mas_equalTo(self.showImgView.bounds.size);
        }];
    }
}

//MARK:字体相关
-(NLFontView *)fontView{
    if (_fontView == nil) {
        _fontView = [[NLFontView alloc]initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, self.showImgView.bounds.size.height)];
    }
    return _fontView;
}
//MARK:字体界面
-(NLFontSelectedView *)fontSelectView{
    if (_fontSelectView == nil) {
        _fontSelectView = [[NLFontSelectedView alloc]initWithFrame:CGRectMake(0, KSCREEN_HEIGHT-FONT_STYLE_VIEW_HEIGHT, KSCREEN_WIDTH, FONT_STYLE_VIEW_HEIGHT)];
    }
    
    return _fontSelectView;
}
//MARK:私有方法
//更新约束
-(void)updateShowImgViewConstraints:(BOOL)isEditing{
    if (isEditing) {
        [self.showImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-BOTTOM_VIEW_HEIGHT-FONT_STYLE_VIEW_HEIGHT);
        }];
    }else{
        [self.showImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-BOTTOM_VIEW_HEIGHT);
        }];
    }
}
//截取新图
- (UIImage *)getImageSizeWithImage:(UIView*)currentView toFrame:(CGRect)frame{
    UIImage*ScreenImg = [self getNewImage:currentView];//截屏屏幕照片
    CGFloat scale = [UIScreen mainScreen].scale;//这句代码很关键适配屏幕
    //截取部分图片并生成新图片    把像素frame 转化为 点rect（如无转化则按原图像素取部分图片）
    CGImageRef sourceImageRef = [ScreenImg CGImage];
    CGRect dianRect =CGRectMake(frame.origin.x*scale, frame.origin.y*scale, frame.size.width*scale, frame.size.height*scale);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef,dianRect);
    UIImage *wantImage = [UIImage imageWithCGImage:newImageRef];
    return wantImage;
}
-(UIImage*)getNewImage:(UIView*)currentView{
    UIGraphicsBeginImageContextWithOptions(currentView.frame.size,NO, 0.0);//currentView 当前的view
    [currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}
//裁剪frame
-(CGRect)cropImageViewRect{
    CGSize size = self.originalImage.size;
    CGFloat showHeight = KSCREEN_HEIGHT-SAFEAREA_BOTTOM_HEIGH-FONT_STYLE_VIEW_HEIGHT-BOTTOM_VIEW_HEIGHT;
    CGFloat screenRate = KSCREEN_WIDTH/showHeight;
    CGFloat imgRate = size.width/size.height;
    if (imgRate >= screenRate) {//宽>高
        size = CGSizeMake(KSCREEN_WIDTH, KSCREEN_WIDTH/imgRate);
        return CGRectMake(0, (showHeight-size.height)/2, size.width, size.height);
    }else{
        size = CGSizeMake(showHeight * imgRate,showHeight);
        return CGRectMake((KSCREEN_WIDTH-size.width)/2, 0, size.width, size.height);
    }
}
//清除文本
-(void)cleanFontView{
    self.closeBtn.hidden = NO;
    [self.fontSelectView removeFromSuperview];
    [self.fontView removeFromSuperview];
    self.fontView = nil;
    self.fontSelectView = nil;
}


@end
