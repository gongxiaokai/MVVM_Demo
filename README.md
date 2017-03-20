# MVVM_Demo

[简书地址](http://www.jianshu.com/p/830358e81da5)

#Demo效果

使用MVVM+RAC请求网络数据


![demo.gif](http://upload-images.jianshu.io/upload_images/4009159-b47b9333536e743f.gif?imageMogr2/auto-orient/strip)


#ReactiveCocoa简介

在iOS开发过程中，当某些事件响应的时候，需要处理某些业务逻辑,这些事件都用不同的方式来处理。
比如按钮的点击使用action，ScrollView滚动使用delegate，属性值改变使用KVO等系统提供的方式。
其实这些事件，都可以通过RAC处理
ReactiveCocoa为事件提供了很多处理方法，而且利用RAC处理事件很方便，可以把要处理的事情，和监听的事情的代码放在一起，这样非常方便我们管理，就不需要跳到对应的方法里。非常符合我们开发中高聚合，低耦合的思想。

基础的话我还是[推荐这篇博文](http://www.jianshu.com/p/87ef6720a096) 讲的都挺细的
当然不爽的话可以试试这个[视频版](https://pan.baidu.com/s/1geHdnhh)的，也是某培训机构流出的

#Demo分析
本文使用的是[豆瓣API（非官方）](https://github.com/jokermonn/-Api/blob/master/DoubanMovie.md)
Demo所要做的功能很简单： 从网络中请求数据，并加载到UI上。
MVVM中最重要也就是这个VM了，VM通常与RAC紧密结合在一起，主要用于事务数据的处理和信号间的传递。

Demo中主要使用了下面这些第三方库

```
  pod 'SDWebImage'
  pod 'Motis'
  pod 'ReactiveCocoa', '2.5'
  pod 'BlocksKit'
  pod 'AFNetworking'
  pod 'Masonry'
  pod 'SVProgressHUD'
```

这里除了RAC 还有一个值得提一下

>`BlocksKit`
众所周知Block已被广泛用于iOS编程。它们通常被用作可并发执行的逻辑单元的封装，或者作为事件触发的回调。Block比传统回调函数有2点优势： 
>
- 允许在调用点上下文书写执行逻辑，不用分离函数
- Block可以使用local variables.
>
基于以上种种优点Cocoa Touch越发支持Block式编程，这点从UIView的各种动画效果可用Block实现就可以看出。而BlocksKit是对Cocoa Touch Block编程更进一步的支持，它简化了Block编程，发挥Block的相关优势，让更多UIKit类支持Block式编程。




#代码
由于BlocksKit的使用，当我们写Delegate和Datasource时 就不用分离函数，整个逻辑都能凑在一起，比如这样定义一个collectionView：

```

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

```

这就将所有有关collectionView的内容都包含在一起了，这样更符合逻辑。


我们让viewModel来处理网络请求，controller需要做的就是启动这个开关，并接受数据而已，所有的工作交给viewModel来处理

MovieViewModel.m
```
- (void)initViewModel {
    @weakify(self);
    self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self getDoubanList:^(NSArray<MovieModel *> *array) {
                [subscriber sendNext:array];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];

}



/**
 网络请求

 @param succeedBlock 成功回调
 */
- (void)getDoubanList:(void(^)(NSArray<MovieModel*> *array))succeedBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *array = [NSMutableArray array];
        MoviewModelList *base = [[MoviewModelList alloc] init];
        [base mts_setValuesForKeysWithDictionary:responseObject];
        
        //遍历数组取出 存入数组并回调出去
        [base.subjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MovieModel *model = [[MovieModel alloc] init];
            [model mts_setValuesForKeysWithDictionary:obj];
            [array addObject:model];
        }];
        if (succeedBlock) {
            succeedBlock(array);
        }
    } failure:nil];
    
}

```

ViewController.m
```
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
```

#Demo地址
[GitHub](https://github.com/gongxiaokai/MVVM_Demo)








