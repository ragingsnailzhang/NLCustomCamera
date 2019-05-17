//
//  UIImage+NLImage.m
//  AFNetworking
//
//  Created by yj_zhang on 2019/5/17.
//

#import "UIImage+NLImage.h"

@implementation UIImage (NLImage)

+(UIImage *)getBundleImageWithName:(NSString *)imageName className:(NSString *)className{
    NSString *bundlePath = [[NSBundle bundleForClass:NSClassFromString(className)].resourcePath
                            stringByAppendingPathComponent:@"/NLCustomCamera.bundle"];
    NSBundle *resource_bundle = [NSBundle bundleWithPath:bundlePath];
    UIImage *image = [UIImage imageNamed:imageName
                                inBundle:resource_bundle
           compatibleWithTraitCollection:nil];
    return image;
}


@end
