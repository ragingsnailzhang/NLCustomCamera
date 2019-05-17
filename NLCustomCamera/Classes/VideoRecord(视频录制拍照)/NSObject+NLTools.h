//
//  NSObject+NLTools.h
//  AFNetworking
//
//  Created by yj_zhang on 2019/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NLTools)

+(NSString *)getBundlePlistWithName:(NSString *)plistName className:(NSString *)className;

+(NSString *)getBundleACVWithName:(NSString *)acvName className:(NSString *)className;
@end

NS_ASSUME_NONNULL_END
