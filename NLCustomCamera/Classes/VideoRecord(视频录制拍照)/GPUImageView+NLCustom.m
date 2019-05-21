//
//  GPUImageView+NLCustom.m
//  GPUImage
//
//  Created by yj_zhang on 2019/5/20.
//

#import "GPUImageView+NLCustom.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation GPUImageView (NLCustom)

+(void)load
{
//    swizzleMethod(self, @selector(recalculateViewGeometry), @selector(nlRecalculateViewGeometry));
}


-(void)nlRecalculateViewGeometry;
{
    __block CGRect currentBounds;

    runOnMainQueueWithoutDeadlocking(^{
        currentBounds = self.bounds;
    });
    runSynchronouslyOnVideoProcessingQueue(^{
        CGFloat heightScaling, widthScaling;

        CGSize currentViewSize = self.bounds.size;

        //    CGFloat imageAspectRatio = inputImageSize.width / inputImageSize.height;
        //    CGFloat viewAspectRatio = currentViewSize.width / currentViewSize.height;
        CGSize tempSize = ((NSValue *)[self valueForKey:@"_inputImageSize"]).CGSizeValue;
        NSLog(@"%f,%f",tempSize.width,tempSize.height);
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(tempSize, currentBounds);

        switch(self.fillMode)
        {
            case kGPUImageFillModeStretch:
            {
                widthScaling = 1.0;
                heightScaling = 1.0;
            }; break;
            case kGPUImageFillModePreserveAspectRatio:
            {
                widthScaling = insetRect.size.width / currentBounds.size.width;
                heightScaling = insetRect.size.height / currentBounds.size.height;
            }; break;
            case kGPUImageFillModePreserveAspectRatioAndFill:
            {
                //            CGFloat widthHolder = insetRect.size.width / currentViewSize.width;
                widthScaling = currentBounds.size.height / insetRect.size.height;
                heightScaling = currentBounds.size.width / insetRect.size.width;
            }; break;
        }
//        GLfloat tempImageVertices[8] = [self valueForKey:@"_imageVertices"]
//        imageVertices[0] = -widthScaling;
//        imageVertices[1] = -heightScaling;
//        imageVertices[2] = widthScaling;
//        imageVertices[3] = -heightScaling;
//        imageVertices[4] = -widthScaling;
//        imageVertices[5] = heightScaling;
//        imageVertices[6] = widthScaling;
//        imageVertices[7] = heightScaling;
    });

    //    static const GLfloat imageVertices[] = {
    //        -1.0f, -1.0f,
    //        1.0f, -1.0f,
    //        -1.0f,  1.0f,
    //        1.0f,  1.0f,
    //    };
}

@end
