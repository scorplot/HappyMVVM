//
//  TableViewProtocolListener.h
//  Pods
//
//  Created by aruisi on 2017/7/13.
//
//

#import <Foundation/Foundation.h>
#import "TableViewArray.h"
@interface TableViewProtocolListener : NSObject<UITableViewDataSource,UITableViewDelegate,UITableViewDataSourcePrefetching,UIScrollViewDelegate>
@property(nonatomic,strong) NSArray * dataSource;
@property(nonatomic,strong) TableViewArray * listener;
@property(nonatomic,weak) UITableView  * tableView;
@end

