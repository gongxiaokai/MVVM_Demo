//
//  ModelBase.h
//  MVVM_Demo
//
//  Created by gongwenkai on 2017/3/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelBase : NSObject


//返回数量
@property (nonatomic,assign) NSInteger count;
//分页量
@property (nonatomic,assign) NSInteger start;
//数据库总数量
@property (nonatomic,assign) NSInteger total;
//返回数据相关信息
@property (nonatomic,copy)   NSString *title;
@end
