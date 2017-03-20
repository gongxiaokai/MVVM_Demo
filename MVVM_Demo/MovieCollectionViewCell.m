//
//  MovieCollectionViewCell.m
//  MVVM_Demo
//
//  Created by gongwenkai on 2017/3/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "MovieCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "MovieModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MovieCollectionViewCell()

@property (nonatomic,weak) UIImageView* imageView;
@property (nonatomic,weak) UILabel* labelTitle;
@property (nonatomic,weak) UILabel* labelPoint;
@end

@implementation MovieCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initStyle];
    }
    return self;
}

//初始化UI
- (void)initStyle {
    UIImageView* imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(imageView.superview);
        make.height.equalTo(imageView.mas_width);
    }];
    self.imageView = imageView;
    
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(imageView);
        make.top.equalTo(imageView.mas_bottom);
        make.bottom.equalTo(self.contentView);
    }];
    self.labelTitle = label;
    
    
    UILabel *labelP = [[UILabel alloc] init];
    labelP.textAlignment = NSTextAlignmentCenter;
    labelP.backgroundColor = [UIColor whiteColor];
    [self.imageView addSubview:labelP];
    [labelP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(labelP.superview);
        make.size.mas_equalTo(CGSizeMake(30, 20));
    }];
    self.labelPoint = labelP;
    
}

- (void)prepareForReuse {
    self.labelTitle.text = @"";
    self.labelPoint.text = @"";
    self.imageView.image = nil;
}


//模型渲染
- (void)renderWithModel:(id)model {
    if ([model isKindOfClass:[MovieModel  class]]) {
        MovieModel *movie = model;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:movie.images[@"large"]?:nil]];
        self.labelTitle.text = movie.title?:@"";
        self.labelPoint.text = [NSString stringWithFormat:@"%@",movie.rating[@"average"]?:@(0)];
    }
}


//cell标识
+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass(self.class);
}
@end
