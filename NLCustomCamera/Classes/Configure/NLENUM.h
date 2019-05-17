//
//  NLENUM.h
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/25.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#ifndef NLENUM_h
#define NLENUM_h
/*** 拍摄比例 */
typedef NS_ENUM(NSInteger,NLShootRatio){
    NLShootRatio1To1 = 1,     // 1:1
    NLShootRatio4To3,         // 4:3
    NLShootRatio16To9,        // 16:9
    NLShootRatioFullScreen    // 全屏
};
/*** 视频质量 */
typedef NS_ENUM(NSInteger,VideoQuality) {
    lowQuality = 1,   //低
    mediumQuality,    //中
    highestQuality,   //高
};
/*** 录制模式 */
typedef NS_ENUM(NSInteger,NLShootMode) {
    photoVideoMode,  //拍照及视频
    photoMode,       //拍照
    videoMode,       //视频
};



#endif /* NLENUM_h */
