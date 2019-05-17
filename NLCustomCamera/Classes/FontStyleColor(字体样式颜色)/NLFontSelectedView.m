//
//  NLFontSelectedView.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/3.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLFontSelectedView.h"
#import "NLColorCell.h"
#import "NLFontColorView.h"
#import "MJExtension.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSObject+NLTools.h"

@interface NLFontSelectedView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//字体
@property(nonatomic,strong)UICollectionView *fontCollectionView;
//字体数据源
@property(nonatomic,strong)NSMutableArray *fontDataSource;

@end

@implementation NLFontSelectedView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initData];
        [self layoutViews];
        [self registerNotify];
    }
    return self;
}
-(void)initData{
    NSString *fontPath = [NSObject getBundlePlistWithName:@"FontList" className:NSStringFromClass([self class])];
    self.fontDataSource = [NLFontModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:fontPath]].mutableCopy;
}

-(void)layoutViews{
    NLFontColorView *colorView = [[NLFontColorView alloc]initWithFrame:CGRectMake(0, 15, self.frame.size.width, 45)];
    [self addSubview:colorView];
    
    //字体
    UICollectionViewFlowLayout *fontLayout = [[UICollectionViewFlowLayout alloc]init];
    fontLayout.minimumLineSpacing = 16;
    self.fontCollectionView = [self getCollectionView:fontLayout];
    [self.fontCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(colorView.mas_bottom).offset(7);
        make.height.mas_equalTo(30);
    }];
    [self.fontCollectionView registerClass:[NLFontCell class] forCellWithReuseIdentifier:NSStringFromClass([NLFontCell class])];
}
//MARK:注册通知
-(void)registerNotify{
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:CURRENT_FONT_STYLE object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSString *fontName = x.object;
        NSInteger item = 0;
        for (NLFontModel *model in self.fontDataSource) {
            if ([model.fontName isEqualToString:fontName]) {
                model.isSelected = YES;
                item = [self.fontDataSource indexOfObject:model];
            }else{
                model.isSelected = NO;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fontCollectionView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:item inSection:0];
            [self.fontCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
        });
    }];
}
//MARK:UICollectionViewDataSource && UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fontDataSource.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NLFontCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NLFontCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell reloadData:self.fontDataSource[indexPath.item]];
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    for (NLFontModel *model in self.fontDataSource) {
        model.isSelected = NO;
    }
    NLFontModel *model = self.fontDataSource[indexPath.item];
    model.isSelected = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANGE_FONT_STYLE object:model];
    [collectionView reloadData];

}
//MARK:UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fontName = ((NLFontModel *)(self.fontDataSource[indexPath.item])).fontName;
    CGFloat itemWidth = [self getLabelWidthFontName:fontName];
    return CGSizeMake(itemWidth+5, 30);
}

//MARK:私有方法
-(UICollectionView *)getCollectionView:(UICollectionViewFlowLayout *)layout{
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 15, self.bounds.size.width, 45) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:collectionView];
    return collectionView;
}
//计算文本宽度
-(CGFloat)getLabelWidthFontName:(NSString *)fontName{
    UIFont *titleFont = [UIFont systemFontOfSize:16];
    if (![fontName isEqualToString:@"default"]) {
        titleFont = [UIFont fontWithName:fontName size:16];
        if (!titleFont) {
            titleFont = [UIFont systemFontOfSize:16];
        }
    }

    NSDictionary *attrs = @{NSFontAttributeName:titleFont};
    CGFloat itemWidth = [@"老街村" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
    return itemWidth;
}


@end


