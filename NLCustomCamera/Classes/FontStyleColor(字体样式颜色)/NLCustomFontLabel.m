//
//  NLCustomFontLabel.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLCustomFontLabel.h"
#import "UIColor+NLCustomColor.h"

@implementation NLCustomFontLabel

-(instancetype)init{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.numberOfLines = 2;
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(void)setColorModel:(NLColorModel *)colorModel{
    _colorModel = colorModel;
    self.textColor = [UIColor hex:colorModel.colorName]; 
}
-(void)setFontModel:(NLFontModel *)fontModel{
    _fontModel = fontModel;
    if ([fontModel.fontName isEqualToString:@"default"]) {
        self.font = [UIFont systemFontOfSize:fontModel.fontSize.floatValue];
    }else{
        self.font = [UIFont fontWithName:fontModel.fontName size:fontModel.fontSize.floatValue];
    }
}

@end
