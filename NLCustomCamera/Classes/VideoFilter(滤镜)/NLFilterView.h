//
//  NLFilterView.h
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/26.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,FilterViewStyle) {
    blackViewStyle,
    whiteViewStyle,
};

@protocol NLFilterViewDelegate <NSObject>

-(void)changeFilter:(GPUImageFilter *)filter currentFilterIndex:(NSInteger)currentFilterIndex;

@end

@interface NLFilterView : UIView

@property(nonatomic,weak)id <NLFilterViewDelegate> delegate;

@property(nonatomic,assign)FilterViewStyle viewStyle;
//当前滤镜
@property(nonatomic,assign)NSInteger currentFilterIndex;
//重置初始化
-(void)resetInitFilter;

@end

@interface NLFilterModel : NSObject

@property(nonatomic,strong)NSString *filterName;
@property(nonatomic,strong)NSString *filterClass;
@property(nonatomic,strong)NSString *filterImage;
@property(nonatomic,assign)BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
