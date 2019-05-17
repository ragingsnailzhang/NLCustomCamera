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

@end

NS_ASSUME_NONNULL_END
