//
//  MovieModel.h
//  MVVM_Demo
//
//  Created by gongwenkai on 2017/3/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"


@protocol MovieModelProtocol <NSObject>
@optional
//将模型渲染
- (void)renderWithModel:(id)model;
@end

@interface MovieModel : NSObject

//电影名
@property (nonatomic,copy) NSString *title;
//剧照
@property (nonatomic,strong) NSDictionary *images;
//电影分类
@property (nonatomic,strong) NSArray *genres;
//排名信息
@property (nonatomic,strong) NSDictionary *rating;
//原型
@property (nonatomic,strong) NSArray *casts;
//电影时长
@property (nonatomic,strong) NSArray *durations;
//多少人看过
@property (nonatomic,assign) NSInteger collect_count;
//大陆上映时间
@property (nonatomic,copy) NSString *mainland_pubdate;
//是否有资源
@property (nonatomic,copy) NSString *has_video;
//电影原名
@property (nonatomic,copy) NSString *original_title;
//固定值movie
@property (nonatomic,copy) NSString *subtype;
//导演信息
@property (nonatomic,strong) NSArray *directors;
//各地上映日期
@property (nonatomic,strong) NSArray *pubdates;
//上映年
@property (nonatomic,copy) NSString *year;
//网页链接
@property (nonatomic,copy) NSString *alt;
//电影 id，用于电影介绍
@property (nonatomic,copy) NSString *id;
@end

@interface MoviewModelList : ModelBase
//具体电影信息 主要数据都在这里面
@property (nonatomic,strong) NSArray<MovieModel *> *subjects;

@end
