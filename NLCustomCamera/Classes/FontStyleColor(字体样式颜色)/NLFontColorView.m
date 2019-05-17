//
//  NLFontColorView.m
//  AncientVillage
//
//  Created by yj_zhang on 2019/4/10.
//  Copyright © 2019年 LSJ. All rights reserved.
//

#import "NLFontColorView.h"
#import "MJExtension.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSObject+NLTools.h"

@interface NLFontColorView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
//颜色
@property(nonatomic,strong)UICollectionView *colorCollectionView;
//颜色数据源
@property(nonatomic,strong)NSMutableArray *colorDataSource;
//当前颜色
@property(nonatomic,assign)NSInteger selectColorIndex;

@end

@implementation NLFontColorView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initData];
        [self layoutViews];
        [self registerNotify];
    }
    return self;
}
//MARK:Data
-(void)initData{
    NSString *path = [NSObject getBundlePlistWithName:@"ColorList" className:NSStringFromClass([self class])];
    self.colorDataSource = [NLColorModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]].mutableCopy;
}
//MARK:Views
-(void)layoutViews{
    //颜色
    UICollectionViewFlowLayout *colorLayout = [[UICollectionViewFlowLayout alloc]init];
    colorLayout.minimumLineSpacing = 19;
    colorLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 15, self.bounds.size.width, 45) collectionViewLayout:colorLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    self.colorCollectionView = collectionView;
    [self addSubview:collectionView];
    [self.colorCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.top.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.colorCollectionView registerClass:[NLColorCell class] forCellWithReuseIdentifier:NSStringFromClass([NLColorCell class])];
}
//MARK:注册通知
-(void)registerNotify{
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:CURRENT_FONT_COLOR object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NLColorModel *currentModel = x.object;
        NSInteger item = 0;
        for (NLColorModel *model in self.colorDataSource) {
            if ([model.colorName isEqualToString:currentModel.colorName]) {
                model.isSelected = YES;
                item = [self.colorDataSource indexOfObject:model];
            }else{
                model.isSelected = NO;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.colorCollectionView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            [self.colorCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
        });
    }];
}
//MARK:UICollectionViewDataSource && UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colorDataSource.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NLColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NLColorCell class]) forIndexPath:indexPath];
    [cell reloadData:self.colorDataSource[indexPath.item]];
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectColorIndex = indexPath.item;
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANGE_FONT_COLOR object:self.colorDataSource[indexPath.item]];
}
//MARK:UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(27, 42);
}

-(void)setSelectColorIndex:(NSInteger)selectColorIndex{
    _selectColorIndex = selectColorIndex;
    for (NLColorModel *model in self.colorDataSource) {
        model.isSelected = NO;
    }
    NLColorModel *model = (selectColorIndex >= self.colorDataSource.count || selectColorIndex == 0) ? self.colorDataSource.firstObject : self.colorDataSource[selectColorIndex];
    model.isSelected = YES;
    [self.colorCollectionView reloadData];
}

@end
