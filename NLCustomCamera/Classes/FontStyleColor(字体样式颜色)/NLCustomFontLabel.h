//
//  NLCustomFontLabel.h
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLColorCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLCustomFontLabel : UILabel

@property(nonatomic,strong)NLColorModel *colorModel;

@property(nonatomic,strong)NLFontModel *fontModel;

@end

NS_ASSUME_NONNULL_END
