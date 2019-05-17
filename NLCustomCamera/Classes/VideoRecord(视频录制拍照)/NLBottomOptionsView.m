//
//  NLBottomOptionsView.m
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLBottomOptionsView.h"
#import <Masonry/Masonry.h>
#import "NLRecordManager.h"
#import "UIImage+NLImage.h"

@interface NLBottomOptionsView()
//取消
@property(nonatomic,strong)UIButton *cancleBtn;
//滤镜
@property(nonatomic,strong)UIButton *editBtn;
//选择
@property(nonatomic,strong)UIButton *selectedBtn;

@end

@implementation NLBottomOptionsView

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        [self configureView];
    }
    return self;
}
-(void)configureView{
    //保存按钮
    UIImage *saveImg = [UIImage getBundleImageWithName:@"record_save" className:NSStringFromClass([self class])];
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.frame = CGRectMake((self.frame.size.width-saveImg.size.width)/2, (self.frame.size.height-saveImg.size.height)/2, saveImg.size.width, saveImg.size.height);
    [_selectedBtn setImage:saveImg forState:UIControlStateNormal];
    [_selectedBtn addTarget:self action:@selector(selected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectedBtn];
    
    //返回
    _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img1 = [UIImage getBundleImageWithName:@"record_cancle" className:NSStringFromClass([self class])];
    [_cancleBtn setImage:img1 forState:UIControlStateNormal];
    [_cancleBtn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancleBtn];
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(40);
        make.centerY.equalTo(self);
    }];
    
    //编辑
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_editBtn addTarget:self action:@selector(editClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-40);
        make.centerY.equalTo(self);
    }];
    
}

//删除
-(void)cancle{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancleClick)]) {
        [self.delegate cancleClick];
    }
}
//保存
-(void)selected{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedClick)]) {
        [self.delegate selectedClick];
    }
}
//编辑
-(void)editClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushEditPage)]) {
        [self.delegate pushEditPage];
    }
}
-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    _editBtn.hidden = [NLRecordManager shareManager].recordParam.getCurrentMode == videoMode ? YES:NO;
}


@end
