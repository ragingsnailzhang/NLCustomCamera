//
//  NLRecordView.h
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/26.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLTimeView.h"
#import "NLProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NLRecordViewDelegate <NSObject>

-(void)updateViewWithOptionsViewHidden:(BOOL)isHidden;
//显示滤镜界面
-(void)showFilterView;
//预览视频
-(void)showPreviewVideo;
//相册
-(void)showAlbum;

@end

@interface NLRecordView : UIView

@property(nonatomic,weak)id <NLRecordViewDelegate>delegate;
//摄像进度View
@property(nonatomic,strong)NLProgressView *progressView;
//拍照View
@property(nonatomic,strong)UIButton *photoBtn;

@end

NS_ASSUME_NONNULL_END
