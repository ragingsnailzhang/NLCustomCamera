//
//  NLRecordView.m
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/26.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import "NLRecordView.h"
#import "NLRecordManager.h"
#import "NLConfigure.h"
#import <Masonry/Masonry.h>
#import "UIImage+NLImage.h"

@interface NLRecordView ()
//下划线
@property(nonatomic,strong)UIImageView *line;
//滤镜按钮
@property(nonatomic,strong)UIButton *filterBtn;

@property(nonatomic,strong)GPUImageFilter *fullFilter;

@end

@implementation NLRecordView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutViews];
        [self edgeView];
        if ([NLRecordManager shareManager].recordParam.shootMode == photoVideoMode) {
            [NLRecordManager shareManager].recordParam.getCurrentMode = photoMode;//当选择两种同时存在模式时,默认当前模式设置为拍照
            [self selectBtnView];
        }else{
            [NLRecordManager shareManager].recordParam.getCurrentMode = [NLRecordManager shareManager].recordParam.shootMode;
        }
    }
    return self;
}
-(void)layoutViews{
    //倒计时View
    self.timeView = [[NLTimeView alloc]initWithFrame:CGRectMake((KSCREEN_WIDTH-STARTBTN_WIDTH)/2,0, STARTBTN_WIDTH, TIMEVIEW_HEIGHT)];
    self.timeView.hidden = YES;
    [self addSubview:self.timeView];
    //拍照
    self.photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.photoBtn setImage:[UIImage getBundleImageWithName:@"record_start" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    [self.photoBtn addTarget:self action:@selector(shootPhotoClcik) forControlEvents:UIControlEventTouchUpInside];
    self.photoBtn.alpha = ([NLRecordManager shareManager].recordParam.shootMode != videoMode) ? 1.0f:0.0f;
    [self addSubview:self.photoBtn];
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    //摄像
    self.progressView = [[NLProgressView alloc]initWithFrame:CGRectMake((KSCREEN_WIDTH-STARTBTN_WIDTH)/2, self.timeView.frame.origin.y+self.timeView.frame.size.height, STARTBTN_WIDTH, STARTBTN_WIDTH)];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.alpha = ([NLRecordManager shareManager].recordParam.shootMode == videoMode) ? 1.0f:0.0f;
    [self addSubview:self.progressView];
    [self.progressView resetProgress];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(STARTBTN_WIDTH, STARTBTN_WIDTH));
    }];
    
    //长按摄像
    UILongPressGestureRecognizer *videoGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.progressView addGestureRecognizer:videoGes];
}

-(void)selectBtnView{
    NSDictionary *iconDict = @{@"record_photo_normal":@"record_photo_select",@"record_video_normal":@"record_video_select"};
    for (NSString *str in [iconDict allKeys]) {
        NSInteger i = [[iconDict allKeys] indexOfObject:str];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+100;
        btn.selected = !i?YES:NO;
        [btn setImage:[UIImage getBundleImageWithName:str className:NSStringFromClass([self class])] forState:UIControlStateNormal];
        [btn setImage:[UIImage getBundleImageWithName:iconDict[str] className:NSStringFromClass([self class])] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-7);
            if (!i) {
                make.right.equalTo(self.mas_centerX).offset(-40);
            }else{
                make.left.equalTo(self.mas_centerX).offset(40);
            }
        }];
    }
    UIImageView *line = [[UIImageView alloc]initWithImage:[UIImage getBundleImageWithName:@"record_selectedline" className:NSStringFromClass([self class])]];
    self.line = line;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo([self viewWithTag:100]);
    }];
}
-(void)edgeView{
    //相册
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.hidden = ![NLRecordManager shareManager].recordParam.isShowAlbumBtn;
    UIImage *img1 = [UIImage getBundleImageWithName:@"record_album" className:NSStringFromClass([self class])];
    [albumBtn setImage:img1 forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(albumClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:albumBtn];
    [albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(40);
        make.centerY.equalTo(self);
    }];
    //滤镜
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.filterBtn = filterBtn;
    self.filterBtn.hidden = ![NLRecordManager shareManager].recordParam.isFilter;
    UIImage *img = [UIImage getBundleImageWithName:@"record_filter" className:NSStringFromClass([self class])];
    [filterBtn setImage:img forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filterClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:filterBtn];
    [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-40);
        make.centerY.equalTo(self);
    }];
}
//MARK:Actions
//相册与摄像
-(void)btnClick:(UIButton *)sender{
    for (UIButton *btn in self.subviews) {
        if ([btn isMemberOfClass:[UIButton class]]) {
            btn.selected = NO;
        }
    }
    sender.selected = YES;
    if (![NLRecordManager shareManager].recordParam.isFilter) {//不开启滤镜
        self.filterBtn.hidden = YES;
    }else{
        self.filterBtn.hidden = sender.tag == 101 ? YES:NO;
    }
    [NLRecordManager shareManager].recordParam.getCurrentMode = sender.tag == 100 ? photoMode:videoMode;
    CGPoint center = self.line.center;
    center.x = sender.center.x;
    [UIView animateWithDuration:0.5f animations:^{
        self.line.center = center;
        self.photoBtn.alpha = (sender.tag == 100)?1.0f:0.0f;
        self.progressView.alpha = 1-self.photoBtn.alpha;
    }];
    if (sender.tag == 101) {//因要求摄像不允许加滤镜,所以去掉滤镜
        if (self.fullFilter == nil) {
            self.fullFilter = [GPUImageFilter new];
        }
        [[NLRecordManager shareManager]changeFilter:self.fullFilter];
    }
}
//录制
-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [[NLRecordManager shareManager] startRecord];
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateViewWithOptionsViewHidden:)]) {
            [self.delegate updateViewWithOptionsViewHidden:YES];
        }
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        [[NLRecordManager shareManager] endRecord];
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateViewWithOptionsViewHidden:)]) {
            [self.delegate updateViewWithOptionsViewHidden:NO];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPreviewVideo)]) {
            [self.delegate showPreviewVideo];
        }
    }
}
//拍照
-(void)shootPhotoClcik{
    [[NLRecordManager shareManager] shootPhoto];
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateViewWithOptionsViewHidden:)]) {
        [self.delegate updateViewWithOptionsViewHidden:NO];
    }
}
//相册
-(void)albumClick{
    NSLog(@"相册");
    if (self.delegate && [self.delegate respondsToSelector:@selector(showAlbum)]) {
        [self.delegate showAlbum];
    }
}
//滤镜
-(void)filterClick{
    NSLog(@"滤镜");
    if (self.delegate && [self.delegate respondsToSelector:@selector(showFilterView)]) {
        [self.delegate showFilterView];
    }
}

@end
