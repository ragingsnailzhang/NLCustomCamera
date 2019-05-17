//
//  NLSettingView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/23.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NLSettingViewDelegate <NSObject>

-(void)closeSettingView;

@end

@interface NLSettingView : UIView

@property(nonatomic,weak)id <NLSettingViewDelegate>delegate;

@end
