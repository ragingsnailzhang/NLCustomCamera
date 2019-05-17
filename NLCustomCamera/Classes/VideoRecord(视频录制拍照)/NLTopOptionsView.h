//
//  NLTopOptionsView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/23.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NLTopOptionsViewDelegate <NSObject>

-(void)close;
//切换摄像头
-(void)turnCamera:(UIButton *)sender;
//闪光灯
-(void)light:(UIButton *)sender;
//美颜
-(void)beauty:(UIButton *)sender;

@end

@interface NLTopOptionsView : UIView

@property(nonatomic,weak)id<NLTopOptionsViewDelegate>delegate;
//关闭按钮
@property(nonatomic,strong)UIButton *closeBtn;
//摄像头按钮
@property(nonatomic,strong)UIButton *cameraBtn;
//闪光灯按钮
@property(nonatomic,strong)UIButton *lightBtn;
//美颜按钮
@property(nonatomic,strong)UIButton *beautyBtn;


@end
