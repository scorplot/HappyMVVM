//
//  UICollectionView+CCUIModel.m
//  TableView_Demo
//
//  Created by 李扬 on 2018/12/11.
//  Copyright © 2018 maimai. All rights reserved.
//

#import "UICollectionView+CCUIModel.h"
#import <CCUIModel/CCUIModel.h>

@implementation UICollectionView (CCUIModel)

+(void)load{
    initListenerProperty([UICollectionView class], @"cv_dataSource", [NSArray class]);
}

@end
