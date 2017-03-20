//
//  MovieCollectionViewCell.h
//  MVVM_Demo
//
//  Created by gongwenkai on 2017/3/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;

- (void)renderWithModel:(id)model;


@end
