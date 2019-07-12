//
//  UIImage+NLImage.h
//  AFNetworking
//
//  Created by yj_zhang on 2019/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NLImage)

+(UIImage *)getBundleImageWithName:(NSString *)imageName className:(NSString *)className;

/**
 *  @brief  修正图片的方向
 *  @param  srcImg 图片
 *  @return 修正方向后的图片
 */
+ (UIImage *)nl_fixOrientation:(UIImage *)srcImg;

@end

NS_ASSUME_NONNULL_END
