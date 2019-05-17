//
//  NSObject+NLTools.m
//  AFNetworking
//
//  Created by yj_zhang on 2019/5/17.
//

#import "NSObject+NLTools.h"

@implementation NSObject (NLTools)

+(NSString *)getBundlePlistWithName:(NSString *)plistName className:(NSString *)className{
    NSString *bundlePath = [[NSBundle bundleForClass:NSClassFromString(className)].resourcePath
                            stringByAppendingPathComponent:@"/NLCustomCamera.bundle"];
    NSBundle *resource_bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [resource_bundle pathForResource:plistName ofType:@"plist"];
    return path;
}

+(NSString *)getBundleACVWithName:(NSString *)acvName className:(NSString *)className{
    NSString *bundlePath = [[NSBundle bundleForClass:NSClassFromString(className)].resourcePath
                            stringByAppendingPathComponent:@"/NLCustomCamera.bundle"];
    NSBundle *resource_bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [resource_bundle pathForResource:acvName ofType:@"acv"];
    return path;
}

@end
