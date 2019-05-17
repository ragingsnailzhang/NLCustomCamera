//
//  NLFontView.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/3.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLFontView.h"
#import "UIView+NLAfterTransformPoint.h"
#import <objc/runtime.h>
#import "NLFontTextViewController.h"
#import "NLCustomFontLabel.h"
#import "NLFontNotifyName.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "MJExtension.h"
#import "UIColor+NLCustomColor.h"
#import "UIImage+NLImage.h"
#import "NSObject+NLTools.h"

#define MAXFONTSIZE  48

#define DEFAULTFONTSIZE  17

#define MINFONTSIZE  10

#define MAXBORDERWIDTH 180

@interface NLFontView()
//旋转按钮
@property(nonatomic,strong)UIImageView *rotateView;
//复制View
@property(nonatomic,strong)UIButton *duplicateBtn;
//删除View
@property(nonatomic,strong)UIButton *delBtn;
//当前正在编辑的Lab
@property(nonatomic,strong)NLCustomFontLabel *currentEditingLabel;
//上一个点
@property(nonatomic,assign)CGPoint previousPoint;
//文本数组
@property (nonatomic,strong)NSMutableArray *labArr;

@end

@implementation NLFontView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.layer.masksToBounds = YES;
        [self initData];
        [self layoutViews];
        [self addGesture];
        [self registerNotify];
    }
    return self;
}
//MARK:Data
-(void)initData{
    self.labArr = [NSMutableArray array];
}
//MARK:Views
-(void)layoutViews{
    [self addTextboxView];
    [self layoutEditBtnView];
}
//编辑按钮界面
-(void)layoutEditBtnView{
    //删除
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.delBtn = delBtn;
    delBtn.bounds = CGRectMake(0, 0, 29, 29);
    delBtn.center = self.currentEditingLabel.nl_topLeftAfterTransform;
    UIImage *delImg = [UIImage getBundleImageWithName:@"font_frame_delete" className:NSStringFromClass([self class])];
    [delBtn setImage:delImg forState:UIControlStateNormal];
    [self addSubview:delBtn];
    [[delBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.currentEditingLabel removeFromSuperview];
        [self.labArr removeObject:self.currentEditingLabel];
        [self isHiddenEditBtns:YES];
    }];
    
    //复制
    UIButton *duplicateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.duplicateBtn = duplicateBtn;
    duplicateBtn.bounds = CGRectMake(0, 0, 29, 29);
    duplicateBtn.center = self.currentEditingLabel.nl_bottomLeftAfterTransform;
    [duplicateBtn setImage:[UIImage getBundleImageWithName:@"font_frame_copy" className:NSStringFromClass([self class])] forState:UIControlStateNormal];
    [self addSubview:duplicateBtn];
    [[duplicateBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self resetTextBox];
        [self addTextboxView];
        [self updateEditBtnConstraints];
        
        [self bringSubviewToFront:self.delBtn];
        [self bringSubviewToFront:self.duplicateBtn];
        [self bringSubviewToFront:self.rotateView];
    }];

    //旋转
    UIImage *img = [UIImage getBundleImageWithName:@"font_frame_rotate" className:NSStringFromClass([self class])];
    self.rotateView = [[UIImageView alloc]initWithImage:img];
    self.rotateView.userInteractionEnabled = YES;
    self.rotateView.bounds = CGRectMake(0, 0, 29, 29);
    self.rotateView.center = self.currentEditingLabel.nl_bottomRightAfterTransform;
    [self addSubview:self.rotateView];
}

//输入框
-(void)addTextboxView{
    NLCustomFontLabel *label = [[NLCustomFontLabel alloc]init];
//    label.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.3];
    label.font = [UIFont systemFontOfSize:DEFAULTFONTSIZE];
    label.frame = CGRectMake(0, 0, MAXBORDERWIDTH, MAXBORDERWIDTH/3);
    label.center = self.center;
    label.userInteractionEnabled = YES;
    label.layer.allowsEdgeAntialiasing = YES;
    [self addSubview:label];
    //将之提到最前方
    [self bringSubviewToFront:label];
    
    if (self.currentEditingLabel) {
        label.bounds = self.currentEditingLabel.bounds;
        label.transform = self.currentEditingLabel.transform;
        label.center = CGPointMake(self.currentEditingLabel.center.x+30, self.currentEditingLabel.center.y+30);
    }
    
    //赋值字体内容
    label.text = self.currentEditingLabel.text ? self.currentEditingLabel.text : @"双击输入文字";
    //赋值字体样式
    if (!self.currentEditingLabel.fontModel) {
        NSString *path = [NSObject getBundlePlistWithName:@"FontList" className:NSStringFromClass([self class])];
        NSArray *fontArr = [NLFontModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
        label.fontModel = fontArr.firstObject;
    }else{
        label.fontModel = self.currentEditingLabel.fontModel;
    }
    //赋值字体颜色
    if (!self.currentEditingLabel.colorModel) {
        NSString *path = [NSObject getBundlePlistWithName:@"ColorList" className:NSStringFromClass([self class])];
        NSArray *colorArr = [NLColorModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
        label.colorModel = colorArr.firstObject;
    }else{
        label.colorModel = self.currentEditingLabel.colorModel;
    }
    //每次创建新的都将新创建的Label设定为当前正在编辑lab,并添加到数组中
    self.currentEditingLabel = label;
    [self.labArr addObject:label];
    //发送通知,刷新颜色界面
    [self postNotify];
    
    //设置虚线边框
    CAShapeLayer *imaginaryLine = [self getBorderLayer:[UIColor whiteColor] lineWidth:1 isImaginaryLine:YES];
    CAShapeLayer *realLine = [self getBorderLayer:[UIColor hex:@"#FF4800"] lineWidth:2 isImaginaryLine:NO];
    [label.layer addSublayer:realLine];
    [label.layer addSublayer:imaginaryLine];
    
    objc_setAssociatedObject(label, @"realLine", realLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(label, @"imaginaryLine", imaginaryLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//MARK:注册&发送通知
//注册通知
-(void)registerNotify{
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:CHANGE_FONT_COLOR object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        self.currentEditingLabel.colorModel = x.object;
    }];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:CHANGE_FONT_STYLE object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NLFontModel *model = x.object;
        model.fontSize = self.currentEditingLabel.fontModel.fontSize;
        self.currentEditingLabel.fontModel = model;
    }];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:CHANGE_FONT_CONTENT object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        self.currentEditingLabel.text = x.object;
    }];
}
//发送通知
-(void)postNotify{
    [[NSNotificationCenter defaultCenter]postNotificationName:CURRENT_FONT_COLOR object:self.currentEditingLabel.colorModel];
    [[NSNotificationCenter defaultCenter]postNotificationName:CURRENT_FONT_STYLE object:self.currentEditingLabel.fontModel.fontName];
}
//MARK:添加手势
-(void)addGesture{
    //缩放捏合
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    // 旋转手势
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
    [self addGestureRecognizer:rotationGesture];
    //平移
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:panGesture];
    //旋转缩放
    UIPanGestureRecognizer *panRotateGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRotateGesture:)];
    [self.rotateView addGestureRecognizer:panRotateGesture];
    //点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    //双击手势
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
}
//MARK:处理手势
//缩放捏合
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinchGesture{
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        if (!self.currentEditingLabel) return;
        [self isTextboxEditing:YES];
    }else if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        if (!self.currentEditingLabel) return;
        [self isTextboxEditing:NO];
    }else {
        CGFloat fontSize = self.currentEditingLabel.fontModel.fontSize.floatValue;
        if ((fontSize >= MINFONTSIZE && fontSize <= MAXFONTSIZE) || (fontSize < MINFONTSIZE && pinchGesture.scale > 1) || (fontSize > MAXFONTSIZE && pinchGesture.scale < 1)) {
            [self textboxZoomWithScale:pinchGesture.scale];
        }
        [pinchGesture setScale:1];
    }
}
//旋转手势
- (void)rotationGesture:(UIRotationGestureRecognizer *)rotationGesture{
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        if (!self.currentEditingLabel) return;
        [self isTextboxEditing:YES];
    }else if (rotationGesture.state == UIGestureRecognizerStateEnded) {
        if (!self.currentEditingLabel) return;
        [self isTextboxEditing:NO];
    }else {
        self.currentEditingLabel.transform = CGAffineTransformRotate(self.currentEditingLabel.transform, rotationGesture.rotation);
        [rotationGesture setRotation:0];
    }
}
//平移
-(void)panGesture:(UIPanGestureRecognizer *)panGesture{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (!self.currentEditingLabel) return;
        [self isTextboxEditing:YES];
    }else if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (!self.currentEditingLabel) return;
        [self isTextboxEditing:NO];
    }else {
        CGPoint t = [panGesture translationInView:self.currentEditingLabel];
        self.currentEditingLabel.transform = CGAffineTransformTranslate(self.currentEditingLabel.transform, t.x, t.y);
        [panGesture setTranslation:CGPointZero inView:self];
    }
}
//旋转缩放手势
-(void)panRotateGesture:(UIPanGestureRecognizer *)panRotate{
    if (panRotate.state == UIGestureRecognizerStateBegan) {
        if (!self.currentEditingLabel) return;
        CGPoint loc = [panRotate locationInView:self];
        self.previousPoint = loc;
        [self isTextboxEditing:YES];
    }else if (panRotate.state == UIGestureRecognizerStateEnded) {
        if (!self.currentEditingLabel) return;
        self.previousPoint = [panRotate locationInView:self];
        [self isTextboxEditing:NO];
    }else {
        CGPoint currentTouchPoint = [panRotate locationInView:self];
        CGPoint center = self.currentEditingLabel.center;
        
        //旋转
        CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(self.previousPoint.y - center.y, self.previousPoint.x - center.x);
        self.currentEditingLabel.transform = CGAffineTransformRotate(self.currentEditingLabel.transform, angleInRadians);
        
        //缩放
        CGFloat previousDistance = [self distanceWithPoint:center otherPoint:self.previousPoint];
        CGFloat currentDistance = [self distanceWithPoint:center otherPoint:currentTouchPoint];
        CGFloat scale = currentDistance / previousDistance;
        CGFloat fontSize = self.currentEditingLabel.fontModel.fontSize.floatValue;
        if ((fontSize >= MINFONTSIZE && fontSize <= MAXFONTSIZE) || (fontSize < MINFONTSIZE && scale > 1) || (fontSize > MAXFONTSIZE && scale < 1)) {
            [self textboxZoomWithScale:scale];
        }
        self.previousPoint = [panRotate locationInView:self];
    }
}
//选中相对应的输入框
-(void)tapGesture:(UITapGestureRecognizer *)tapGesture{
    if (!self.currentEditingLabel) return;
    [self postNotify];
    [self isTextboxEditing:NO];
}
//双击输入
-(void)doubleTapGesture:(UITapGestureRecognizer *)doubleTapGesture{
    NLFontTextViewController *fontPage = [NLFontTextViewController new];
    fontPage.currentEditingLabel = self.currentEditingLabel;
    [fontPage presentContext:[self currentVC] finish:^{}];
}
//MARK:更改编辑按钮状态/线框状态
-(void)isTextboxEditing:(BOOL)isEditing{
    //线框置为白灰状态(未选中)
    [self resetTextBox];
    //更改线框颜色与显示
    [self updateLineSatus:isEditing];
    //是否隐藏编辑按钮
    [self isHiddenEditBtns:isEditing];
    //更新编辑按钮约束
    [self updateEditBtnConstraints];
}
//更新编辑按钮约束
-(void)updateEditBtnConstraints{
    self.delBtn.center = self.currentEditingLabel.nl_topLeftAfterTransform;
    self.duplicateBtn.center = self.currentEditingLabel.nl_bottomLeftAfterTransform;
    self.rotateView.center = self.currentEditingLabel.nl_bottomRightAfterTransform;
}
//更新线框状态
-(void)updateLineSatus:(BOOL)isEditing{
    //更新线框状态
    CAShapeLayer *realLine = objc_getAssociatedObject(self.currentEditingLabel, @"realLine");
    CAShapeLayer *imaginaryLine = objc_getAssociatedObject(self.currentEditingLabel, @"imaginaryLine");
    if (realLine) {
        realLine.hidden = NO;
        realLine.strokeColor = isEditing ? [UIColor whiteColor].CGColor : [UIColor hex:@"#FF4800"].CGColor;
    }
    if (imaginaryLine) {
        imaginaryLine.hidden = NO;
        imaginaryLine.strokeColor = isEditing ? [UIColor whiteColor].CGColor : [UIColor whiteColor].CGColor;
    }
}
//是否隐藏编辑按钮
-(void)isHiddenEditBtns:(BOOL) isHidden{
    self.delBtn.hidden = isHidden;
    self.duplicateBtn.hidden = isHidden;
    self.rotateView.hidden = isHidden;
}
//文本框一律置为未选中
-(void)resetTextBox{
    for (UILabel *lab in self.labArr) {
        CAShapeLayer *imaginaryLine = objc_getAssociatedObject(lab, @"imaginaryLine");
        CAShapeLayer *realLine = objc_getAssociatedObject(lab, @"realLine");
        if (imaginaryLine) imaginaryLine.hidden = YES;
        if (realLine) realLine.hidden = YES;
    }
}
//MARK:划线
-(CAShapeLayer *)getBorderLayer:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth  isImaginaryLine:(BOOL)isImaginaryLine{
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    CGFloat width = self.currentEditingLabel.bounds.size.width;
    CGFloat height = self.currentEditingLabel.bounds.size.height;
    borderLayer.bounds = CGRectMake(0, 0, width, height);
    //中心点位置
    borderLayer.position = CGPointMake(width * 0.5, height * 0.5);
    borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;
    //边框的宽度
    borderLayer.lineWidth = lineWidth;
    //边框虚线线段的宽度
    if (isImaginaryLine) {
        borderLayer.lineDashPattern = @[@3.6,@2.5];
    }
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = strokeColor.CGColor;
    return borderLayer;
}
//MARK:私有方法
- (CGFloat)distanceWithPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint{
    return sqrt(pow(point.x - otherPoint.x, 2) + pow(point.y - otherPoint.y, 2));
}
//获得当前正在编辑label
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (NLCustomFontLabel *lab in self.labArr) {
        // 将point转化成为lab坐标系上的点
        CGPoint labPoint = [self convertPoint:point toView:lab];
        // 如果点在绿色label上,则为当前正在编辑的label
        if ([lab pointInside:labPoint withEvent:event]) {
            self.currentEditingLabel = lab;
            [self bringSubviewToFront:self.delBtn];
            [self bringSubviewToFront:self.duplicateBtn];
            [self bringSubviewToFront:self.rotateView];
        }
    }
    return [super hitTest:point withEvent:event];
}
//缩放文本框
-(void)textboxZoomWithScale:(CGFloat)scale{
    CGFloat pointSize = scale * self.currentEditingLabel.font.pointSize;
    self.currentEditingLabel.fontModel.fontSize = @(pointSize);
    if ([self.currentEditingLabel.fontModel.fontName isEqualToString:@"default"]) {
        self.currentEditingLabel.font = [UIFont systemFontOfSize:pointSize];
    }else{
        self.currentEditingLabel.font = [UIFont fontWithName:self.currentEditingLabel.fontModel.fontName size:pointSize];
    }
    CGPoint center = self.currentEditingLabel.center;
    CGFloat width = self.currentEditingLabel.bounds.size.width * scale;
    CGFloat height = self.currentEditingLabel.bounds.size.height * scale;
    CGPoint orgin = CGPointMake(center.x-width/2, center.y-height/2);
    self.currentEditingLabel.bounds = CGRectMake(orgin.x, orgin.y, width, height);
    //更新边框
    CAShapeLayer *realLine = objc_getAssociatedObject(self.currentEditingLabel, @"realLine");
    CAShapeLayer *imaginaryLine = objc_getAssociatedObject(self.currentEditingLabel, @"imaginaryLine");
    realLine.path = [UIBezierPath bezierPathWithRect:self.currentEditingLabel.bounds].CGPath;
    imaginaryLine.path = [UIBezierPath bezierPathWithRect:self.currentEditingLabel.bounds].CGPath;
}
//MARK:外部方法
-(void)hiddenBorderAndEditBtn{
    [self resetTextBox];
    [self isHiddenEditBtns:YES];
}
//MARK:屏幕当前控制控制器
- (UIViewController *)currentVC {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}





@end
