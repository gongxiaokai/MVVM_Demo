//
//  MovieViewModel.h
//  MVVM_Demo
//
//  Created by gongwenkai on 2017/3/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MovieViewModel : NSObject

//command处理实际事务  网络请求
@property (nonatomic,strong,readonly)RACCommand *command;

@end
