//
//  NLFontTextViewController.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLFontTextViewController.h"
#import "NLFontInputView.h"
#import "NLFontColorView.h"
#import "NLConfigure.h"

@interface NLFontTextViewController ()
//文本输入框
@property(nonatomic,strong)NLFontInputView *textInputView;
//颜色
@property(nonatomic,strong)NLFontColorView *colorView;

@end

@implementation NLFontTextViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //防止失去键盘
    [self.textInputView.textField becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self registerNotify];
    [self layoutTextInputView];
}
//MARK:Views
- (void)layoutTextInputView{
    WS(weakSelf)
    self.textInputView = [[NLFontInputView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, KSCREEN_WIDTH, 50)];
    self.textInputView.hidden = YES;
    self.textInputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textInputView];
    self.textInputView.sendAction = ^(NSString * _Nonnull content) {
        if (content.length > 0) {
            weakSelf.currentEditingLabel.text = content;
        }
        [weakSelf.view endEditing:YES];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };

    //颜色
    self.colorView = [[NLFontColorView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 45)];
    self.colorView.hidden = YES;
    [self.view addSubview:self.colorView];
}
//注册通知
-(void)registerNotify{
    //接收键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
}
//MARK:键盘弹出收回
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    // Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // User Info
    NSDictionary *info = notification.userInfo;
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Keyboard Size,Checks if IOS8, gets correct keyboard height
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textInputView.hidden = NO;
            self.colorView.hidden = NO;
            //文本框
            CGRect frame = self.textInputView.frame;
            frame.origin.y = self.view.bounds.size.height - keyboardHeight - SAFEAREA_BOTTOM_HEIGH - frame.size.height ;
            self.textInputView.frame = frame;
            //颜色
            CGRect colorViewFrame = self.colorView.frame;
            CGFloat colorViewY = self.textInputView.frame.origin.y - colorViewFrame.size.height;
            colorViewFrame.origin.y = colorViewY;
            self.colorView.frame = colorViewFrame;
        });
    }
}
//MARK:展示
- (void)presentContext:(UIViewController *)presentContext finish:(dispatch_block_t)finishBlock{
    WS(weakSelf)
    presentContext.definesPresentationContext = YES;//这句话很重要 决定了是self 还是navigationBar作为present的容器
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;//这个也很重要
    [presentContext presentViewController:self animated:YES completion:^{
        [weakSelf.textInputView.textField becomeFirstResponder];
        !finishBlock?:finishBlock();
    }];
}
//MARK:私有方法
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
