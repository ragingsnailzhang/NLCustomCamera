//
//  NLConfigure.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#ifndef NLConfigure_h
#define NLConfigure_h

//屏幕宽度
#define KSCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define KSCREEN_HEIGHT      [UIScreen mainScreen].bounds.size.height
//下边距安全距离
#define SAFEAREA_BOTTOM_HEIGH                  (IS_PhoneXAll ? 34.0f : 0.01f)
//上边距安全距离
#define SAFEAREA_TOP_HEIGH                     (IS_PhoneXAll ? 44.0f : 20.0f)
//状态栏高度
#define STATUS_HEIGHT  20.f
//边距
#define MARGIN      20
//录制按钮大小
#define STARTBTN_WIDTH      72
//时间View高度
#define TIMEVIEW_HEIGHT     30
//进度条宽度
#define PROGRESS_BORDER_WIDTH  8
//取消按钮大小
#define CANCLEBTN_WIDTH  92
//选择按钮大小
#define SELECTEDBTN_WIDTH  53

//判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//判断iPhoneX，Xs（iPhoneX，iPhoneXs）
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXr
#define IS_IPHONE_XR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXsMax
#define IS_IPHONE_XS_MAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size)&& !isPad : NO)
//判断iPhoneX所有系列
#define IS_PhoneXAll (IS_IPHONE_X || IS_IPHONE_XR || IS_IPHONE_XS_MAX)

#define WS(weakSelf)            __weak __typeof(&*self)weakSelf = self;

//MARK:文件夹名称
//原始文件存放文件夹
#define VIDEO_FOLDER  @"VideoFolder"
////压缩文件存放文件夹
//#define COMPRESSION_VIDEO_FOLDER  @"CompressionVideoFolder"
////编辑文件存放文件夹
//#define EDIT_VIDEO_FOLDER  @"EditVideoFolder"
////封面文件存放文件夹
//#define VIDEO_COVER_FOLDER  @"VideoCoverFolder"

#endif /* NLConfigure_h */

