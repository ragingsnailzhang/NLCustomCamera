//
//  UIView+NLAfterTransformPoint.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/4.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "UIView+NLAfterTransformPoint.h"

@implementation UIView (NLAfterTransformPoint)

// helper to get pre transform frame
-(CGRect)nl_originalFrameAfterTransform {
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    return originalFrame;
}

// now get your corners
- (CGPoint)nl_topLeftAfterTransform {
    CGRect frame = [self nl_originalFrameAfterTransform];
    return [self nl_pointInViewAfterTransform:frame.origin];
}

- (CGPoint)nl_topRightAfterTransform {
    CGRect frame = [self nl_originalFrameAfterTransform];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self nl_pointInViewAfterTransform:point];
}

- (CGPoint)nl_bottomLeftAfterTransform {
    CGRect frame = [self nl_originalFrameAfterTransform];
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self nl_pointInViewAfterTransform:point];
}

- (CGPoint)nl_bottomRightAfterTransform {
    CGRect frame = [self nl_originalFrameAfterTransform];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self nl_pointInViewAfterTransform:point];
}

// 辅助方法
- (CGPoint)nl_pointInViewAfterTransform:(CGPoint)thePoint {
    // get offset from center
    CGPoint offset = CGPointMake(thePoint.x - self.center.x, thePoint.y - self.center.y);
    // get transformed point
    CGPoint transformedPoint = CGPointApplyAffineTransform(offset, self.transform);
    // make relative to center
    return CGPointMake(transformedPoint.x + self.center.x, transformedPoint.y + self.center.y);
}


@end
