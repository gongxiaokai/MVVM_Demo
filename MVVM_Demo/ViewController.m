//
//  ViewController.m
//  MVVM_Demo
//
//  Created by gongwenkai on 2017/3/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "ViewController.h"
#import "ModelBase.h"
#import "MovieModel.h"
#import "MovieViewModel.h"
#import "MovieCollectionViewCell.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <Motis/Motis.h>
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()
//viewModel
@property (nonatomic,strong) MovieViewModel *viewModel;
//列表
@property (nonatomic,weak) UICollectionView *collectionView;
//列表数据
@property (nonatomic,strong) NSArray *listArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化UI
    [self initStyle];
    //绑定ViewModel
    [self bindViewModel];

}

- (void)initStyle {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    collectionView.backgroundColor = [UIColor redColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    self.collectionView = collectionView;
    
    //注册cell
    [self.collectionView registerClass:[MovieCollectionViewCell class] forCellWithReuseIdentifier:[MovieCollectionViewCell cellReuseIdentifier]];
    
    //collectionView dataSouce
    A2DynamicDelegate *dataSouce = self.collectionView.bk_dynamicDataSource;
    
    //item个数
    [dataSouce implementMethod:@selector(collectionView:numberOfItemsInSection:) withBlock:^NSInteger(UICollectionView *collectionView, NSInteger section) {
        return self.listArray.count;
    }];
    //item配置
    [dataSouce implementMethod:@selector(collectionView:cellForItemAtIndexPath:) withBlock:^UICollectionViewCell*(UICollectionView *collectionView,NSIndexPath *indexPath) {
        id<MovieModelProtocol> cell = nil;
        Class cellClass = [MovieCollectionViewCell class];
        if (cellClass) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MovieCollectionViewCell cellReuseIdentifier] forIndexPath:indexPath];
            if ([cell respondsToSelector:@selector(renderWithModel:)]) {
                [cell renderWithModel:self.listArray[indexPath.row]];
            }
        }
        return (UICollectionViewCell *)cell;
    }];
    self.collectionView.dataSource = (id)dataSouce;
    
#define scaledCellValue(value) ( floorf(CGRectGetWidth(collectionView.frame) / 375 * (value)) )

    //collectionView delegate
    A2DynamicDelegate *delegate = self.collectionView.bk_dynamicDelegate;
    
    //item Size
    [delegate implementMethod:@selector(collectionView:layout:sizeForItemAtIndexPath:) withBlock:^CGSize(UICollectionView *collectionView,UICollectionViewLayout *layout,NSIndexPath *indexPath) {
        return CGSizeMake(scaledCellValue(100), scaledCellValue(120));
    }];
    
    //内边距
    [delegate implementMethod:@selector(collectionView:layout:insetForSectionAtIndex:) withBlock:^UIEdgeInsets(UICollectionView *collectionView ,UICollectionViewLayout *layout, NSInteger section) {
        return UIEdgeInsetsMake(0, 15, 0, 15);
    }];

    self.collectionView.delegate = (id)delegate;
    
}



/**
 viewModel绑定
 */
- (void)bindViewModel {
    @weakify(self);
    //将命令执行后的数据交给controller
    [self.viewModel.command.executionSignals.switchToLatest subscribeNext:^(NSArray<MovieModel *> *array) {
        @strongify(self);
        [SVProgressHUD showSuccessWithStatus:@"加载成功"];
        self.listArray = array;
        [self.collectionView reloadData];
        [SVProgressHUD dismissWithDelay:1.5];
    }];
    
    //执行command
    [self.viewModel.command execute:nil];
    [SVProgressHUD showWithStatus:@"加载中..."];
}

- (MovieViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MovieViewModel alloc] init];
    }
    return _viewModel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
