//
//  NLFilterView.m
//  NLCustomCamera
//
//  Created by yj_zhang on 2019/3/26.
//  Copyright © 2019年 yj_zhang. All rights reserved.
//

#import "NLFilterView.h"
#import "NLFilterCell.h"
#import "MJExtension.h"
#import "NSObject+NLTools.h"

@interface NLFilterView ()<UICollectionViewDelegate,UICollectionViewDataSource>
//滤镜view
@property(nonatomic,strong) UICollectionView *filterCollectView;
//数据源
@property(nonatomic,strong) NSMutableArray *dataSource;

@property(nonatomic,strong) GPUImageFilter *filter;

@end

@implementation NLFilterView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self layoutViews];
    }
    return self;
}
-(void)initData{
    NSString *path = [NSObject getBundlePlistWithName:@"FilterList" className:NSStringFromClass([self class])];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:path];
    self.dataSource = [NLFilterModel mj_objectArrayWithKeyValuesArray:dictArr];
    
}
-(void)layoutViews{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5.f;
    layout.minimumInteritemSpacing = 19.f;
    self.filterCollectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
    self.filterCollectView.delegate = self;
    self.filterCollectView.dataSource = self;
    self.filterCollectView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.filterCollectView];
    
    [self.filterCollectView registerClass:[NLFilterCell class] forCellWithReuseIdentifier:@"filterCell"];
}
//MARK:UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(59, 80);
    return size;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.viewStyle == blackViewStyle ? 15.0f : 0.1f, self.frame.size.height);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(self.viewStyle == blackViewStyle ? 15.0f : 0.1f, self.frame.size.height);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NLFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    NLFilterModel *model = self.dataSource[indexPath.item];
    [cell reloadData:model style:self.viewStyle];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    for (NLFilterModel *model in self.dataSource) {
        model.isSelected = NO;
    }
    NLFilterModel *model = self.dataSource[indexPath.item];
    model.isSelected = YES;
    
    if ([model.filterClass isEqualToString:@"GPUImageToneCurveFilter"]) {
        NSString *path = [NSObject getBundleACVWithName:model.filterName className:NSStringFromClass([self class])];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (!data) {
            return;
        }
        GPUImageToneCurveFilter *filter = [[NSClassFromString(model.filterClass) alloc]initWithACVData:data];
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeFilter:currentFilterIndex:)]) {
            [self.delegate changeFilter:filter currentFilterIndex:indexPath.item];
        }
    }else{
        if (self.filter == nil) {
            self.filter = [GPUImageFilter new];
        }
//        GPUImageFilter *filter = [GPUImageFilter new];
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeFilter:currentFilterIndex:)]) {
            [self.delegate changeFilter:self.filter currentFilterIndex:indexPath.item];
        }
    }
    [self.filterCollectView reloadData];
}

-(void)setViewStyle:(FilterViewStyle)viewStyle{
    _viewStyle = viewStyle;
    if (viewStyle == blackViewStyle) {
        self.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.700];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}
- (void)setCurrentFilterIndex:(NSInteger)currentFilterIndex{
    _currentFilterIndex = self.dataSource.count > currentFilterIndex ? currentFilterIndex : 0;
    NLFilterModel *model = self.dataSource[currentFilterIndex];
    model.isSelected = YES;
}
//重置初始化
-(void)resetInitFilter{
    for (NLFilterModel *model in self.dataSource) {
        model.isSelected = NO;
    }
    NLFilterModel *model = self.dataSource.firstObject;
    model.isSelected = YES;
    [self.filterCollectView reloadData];
}

-(NSString *)getBundlePlistWithName:(NSString *)plistName{
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath
                            stringByAppendingPathComponent:@"/NLCustomCamera.bundle"];
    NSBundle *resource_bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [resource_bundle pathForResource:plistName ofType:@"plist"];
    return path;
}

@end

@implementation NLFilterModel

@end
