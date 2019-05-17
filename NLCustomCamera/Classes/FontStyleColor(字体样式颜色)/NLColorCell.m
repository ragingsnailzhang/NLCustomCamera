//
//  NLColorCell.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/3.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLColorCell.h"
#import <Masonry/Masonry.h>
#import <UIColor+NLCustomColor.h>

@interface NLColorCell()
//颜色View
@property(nonatomic,strong)UIView *colorView;
//选中View
@property(nonatomic,strong)UIView *selectView;

@end

@implementation NLColorCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutViews];
    }
    return self;
}

-(void)layoutViews{
    self.colorView = [UIView new];
    self.colorView.layer.cornerRadius = 27/2.0;
    [self.contentView addSubview:self.colorView];
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(27.0, 27.0));
//        make.left.right.equalTo(self.contentView);
//        make.top.equalTo(self.contentView).offset(7);
//        make.bottom.equalTo(self.contentView).offset(-7);
    }];
    
    self.selectView = [UIView new];
    self.selectView.layer.cornerRadius = 25.0/2.0;
    self.selectView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectView.layer.borderWidth = 6;
    self.selectView.hidden = YES;
    [self.contentView addSubview:self.selectView];
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(25.0, 25.0));
    }];
}
-(void)reloadData:(NLColorModel *)model{
    UIColor *color = [UIColor hex:model.colorName];
    if ([model.colorName isEqualToString:@"#FFFFFF"]) {
        self.colorView.layer.borderColor = [UIColor hex:@"#CACACA"].CGColor;
        self.colorView.layer.borderWidth = 1;
        
        self.selectView.layer.borderColor = [UIColor hex:@"#CACACA"].CGColor;
        self.selectView.layer.borderWidth = 0.5;
        self.selectView.layer.cornerRadius = 7;
        [self.selectView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(14.0, 14.0));
        }];
        
    }else{
        self.colorView.layer.borderWidth = 0.0;
        
        self.selectView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.selectView.layer.borderWidth = 6;
        self.selectView.layer.cornerRadius = 25/2.0;
        [self.selectView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(25.0, 25.0));
        }];
    }
    self.colorView.backgroundColor = color;
    self.selectView.backgroundColor = color;
    self.selectView.hidden = !model.isSelected;
}
@end

//MARK:字体Cell

@interface NLFontCell()
//字体Label
@property(nonatomic,strong)UILabel *fontLab;
@end

@implementation NLFontCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutViews];
    }
    return self;
}

-(void)layoutViews{
    self.fontLab = [UILabel new];
    self.fontLab.text = @"老街村";
    self.fontLab.textColor = [UIColor hex:@"#5F5F5F"];
    self.fontLab.font = [UIFont systemFontOfSize:16];
    self.fontLab.numberOfLines = 1;
    [self.contentView addSubview:self.fontLab];
    [self.fontLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.contentView);
    }];
}
-(void)reloadData:(NLFontModel *)model{
    if ([model.fontName isEqualToString:@"default"]) {
        self.fontLab.font = [UIFont systemFontOfSize:16];
    }else{
        self.fontLab.font = [UIFont fontWithName:model.fontName size:16];
    }
    self.fontLab.textColor = model.isSelected ? [UIColor hex:@"#FF4800"]:[UIColor hex:@"#5F5F5F"];
}

@end

//MARK:颜色Model
@implementation NLColorModel
@end

//MARK:字体Model
@implementation NLFontModel
@end
