//
//  UITableView+TableViewArray.m
//  CircleReferenceCheck
//
//  Created by 李扬 on 2018/12/10.
//

#import "UITableView+CCUIModel.h"
#import <CCUIModel/CCUIModel.h>

@implementation UITableView (CCUIModel)

+(void)load{
    initListenerProperty([UITableView class], @"tv_dataSource", [NSArray class]);
}

@end
