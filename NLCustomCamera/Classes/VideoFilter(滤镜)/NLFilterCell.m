//
//  NLFilterCell.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/6/14.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLFilterCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+NLCustomColor.h"
#import "UIImage+NLImage.h"

@interface NLFilterCell()

@property(nonatomic,strong)UIImageView *photoView;
@property(nonatomic,strong)UILabel *filterLab;
@property(nonatomic,strong)UIImageView *selectView;


@end

@implementation NLFilterCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self layoutView];
    }
    return self;
}
-(void)layoutView{
    self.photoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width)];
    self.photoView.clipsToBounds = YES;
    self.photoView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoView.userInteractionEnabled = YES;
    self.photoView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.photoView];
    
    self.filterLab = [[UILabel alloc]init];
    self.filterLab.font = [UIFont systemFontOfSize:14.f];
    self.filterLab.textColor = [UIColor whiteColor];
    self.filterLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.filterLab];
    [self.filterLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self.contentView);
    }];
    
    self.selectView = [[UIImageView alloc]initWithImage:[UIImage getBundleImageWithName:@"filter_selected" className:NSStringFromClass([self class])]];
    self.selectView.hidden = YES;
    [self.contentView addSubview:self.selectView];
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.photoView);
        make.size.equalTo(self.photoView);
    }];
    UIImageView *selectBtnView = [[UIImageView alloc]initWithImage:[UIImage getBundleImageWithName:@"filter_selected_btn" className:NSStringFromClass([self class])]];
    [self.selectView addSubview:selectBtnView];
    [selectBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.selectView);
    }];
    
    
    
}
-(void)reloadData:(NLFilterModel *)model style:(FilterViewStyle)style{
    self.photoView.image = [UIImage getBundleImageWithName:model.filterImage className:NSStringFromClass([self class])];
    self.filterLab.text = model.filterName;
    if (style == blackViewStyle) {//
        if (model.isSelected) {
            self.selectView.hidden = NO;
            self.filterLab.textColor = [UIColor whiteColor];
        }else{
            self.selectView.hidden = YES;
            self.filterLab.textColor = [UIColor hex:@"#909090"];
        }
    }else{
        if (model.isSelected) {
            self.selectView.hidden = NO;
            self.filterLab.textColor = [UIColor hex:@"#FF4800"];
        }else{
            self.selectView.hidden = YES;
            self.filterLab.textColor = [UIColor hex:@"#5F5F5F"];
        }
    }
    
}

@end
