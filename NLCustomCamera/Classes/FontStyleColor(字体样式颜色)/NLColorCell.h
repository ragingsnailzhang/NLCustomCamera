//
//  NLColorCell.h
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/3.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NLColorModel,NLFontModel;
NS_ASSUME_NONNULL_BEGIN
//MARK:颜色Cell
@interface NLColorCell : UICollectionViewCell

-(void)reloadData:(NLColorModel *)model;

@end
//MARK:字体Cell
@interface NLFontCell : UICollectionViewCell

-(void)reloadData:(NLFontModel *)model;

@end

//MARK:颜色Model
@interface NLColorModel : NSObject

@property(nonatomic,strong)NSString *colorName;

@property(nonatomic,assign)BOOL isSelected;

@end

//MARK:字体Model
@interface NLFontModel : NSObject
//字体大小
@property(nonatomic,strong)NSNumber *fontSize;
//字体名称
@property(nonatomic,strong)NSString *fontName;
//是否选中
@property(nonatomic,assign)BOOL isSelected;

@end


NS_ASSUME_NONNULL_END
