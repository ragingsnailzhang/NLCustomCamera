//
//  NLFilterCell.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/6/14.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLFilterView.h"

@interface NLFilterCell : UICollectionViewCell

-(void)reloadData:(NLFilterModel *)model style:(FilterViewStyle)style;

@end
