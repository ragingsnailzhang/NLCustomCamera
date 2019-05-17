//
//  UIView+NLAfterTransformPoint.h
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/4.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (NLAfterTransformPoint)

/**
 * transform后获取四个点真实坐标
 */
// 原来的frame
-(CGRect)nl_originalFrameAfterTransform;
// 以下为4个点坐标
-(CGPoint)nl_topLeftAfterTransform;
-(CGPoint)nl_topRightAfterTransform;
-(CGPoint)nl_bottomLeftAfterTransform;
-(CGPoint)nl_bottomRightAfterTransform;

@end

NS_ASSUME_NONNULL_END
