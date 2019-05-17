//
//  NLFontTextViewController.h
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLFontTextViewController : UIViewController

@property(nonatomic,strong)UILabel *currentEditingLabel;

- (void)presentContext:(UIViewController *)presentContext finish:(dispatch_block_t)finishBlock;

@end

NS_ASSUME_NONNULL_END
