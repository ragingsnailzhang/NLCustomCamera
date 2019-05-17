//
//  NLFontInputView.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLFontInputView.h"
#import "NLFontNotifyName.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIColor+NLCustomColor.h"
#import <Masonry/Masonry.h>
@interface NLFontInputView()

//发布按钮
@property(nonatomic,strong)UIButton * sendReplyBtn;

@end

@implementation NLFontInputView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configure];
        [[[NSNotificationCenter defaultCenter]rac_addObserverForName:CHANGE_FONT_COLOR object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            [self.textField becomeFirstResponder];
        }];
    }
    return self;
}

- (void)configure{
    CGFloat margin = 12;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.font = [UIFont systemFontOfSize:17];
    self.textField.placeholder = @"请输入文字";
    self.textField.layer.borderColor = [UIColor hex:@"#E5E5E5"].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 2.f;
    [self addSubview:self.textField];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.bounds.size.height)];
    self.textField.leftView = leftView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    self.sendReplyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendReplyBtn setTitleColor:[UIColor hex:@"#FF4800"] forState:UIControlStateNormal];
    [self.sendReplyBtn setBackgroundColor:[UIColor clearColor]];
    self.sendReplyBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.sendReplyBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.sendReplyBtn addTarget:self action:@selector(sendReplyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendReplyBtn];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.height.mas_greaterThanOrEqualTo(20).priority(888);
        make.right.equalTo(self.sendReplyBtn.mas_left).offset(-margin*2.0);
        make.top.equalTo(self).offset(5).priority(999);
        make.bottom.equalTo(self).offset(-10).priority(777);
    }];
    
    [self.sendReplyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-15);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(35);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
    
}

- (void)textDidChange:(NSNotification *)not{
    if([not.object isEqual:self.textField]){
        [[NSNotificationCenter defaultCenter]postNotificationName:CHANGE_FONT_CONTENT object:self.textField.text];
    }
}

- (void)sendReplyAction:(UIButton *)btn{
    !self.sendAction?:self.sendAction(self.textField.text);

}


@end
