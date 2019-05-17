//
//  NLFontInputView.h
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLFontInputView : UIView

//输入框
@property(nonatomic,strong)UITextField *textField;
//发送
@property(nonatomic,copy)void(^sendAction)(NSString *content);

@end

NS_ASSUME_NONNULL_END
