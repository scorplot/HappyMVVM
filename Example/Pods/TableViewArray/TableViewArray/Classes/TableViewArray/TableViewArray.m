//
//  TableViewArray.m
//  Pods
//
//  Created by aruisi on 2017/7/13.
//
//

#import "TableViewArray.h"
#import "TableViewProtocolListener.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
@implementation TableViewArray
-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}
@end


void TableViewConnectArray(UITableView* tableview ,NSArray<NSObject*>* dataSource,TableViewArray * listener){
    TableViewProtocolListener * protocalListener =  [[TableViewProtocolListener alloc]init];
    protocalListener.listener = listener;
    protocalListener.dataSource= dataSource;
    protocalListener.tableView = tableview;
    tableview.dataSource= protocalListener;
    tableview.delegate= protocalListener;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            tableview.prefetchDataSource=protocalListener;
        } else {
            // Fallback on earlier versions
        }
     }
    static const void* key;
    objc_setAssociatedObject(tableview, &key, protocalListener, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [tableview reloadData];
}


@implementation UITableView (TableViewArray)

- (void)setTv_tableViewArray:(TableViewArray *)tv_tableViewArray
{
    if (tv_tableViewArray == nil)
    {
        TableViewConnectArray(self, nil, nil);
    }
    else
    {
        TableViewConnectArray(self, self.tv_dataSource, tv_tableViewArray);
    }
    objc_setAssociatedObject(self, @"tv_tableViewArray", tv_tableViewArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TableViewArray *)tv_tableViewArray
{
    return objc_getAssociatedObject(self, @"tv_tableViewArray");
}


- (void)setTv_dataSource:(NSArray<NSObject *> *)tv_dataSource
{
    if (tv_dataSource == nil)
    {
        TableViewConnectArray(self, nil, nil);
    }
    else
    {
        TableViewConnectArray(self, tv_dataSource, self.tv_tableViewArray);
    }
    objc_setAssociatedObject(self, @"tv_dataSource", tv_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSObject *> *)tv_dataSource
{
    return objc_getAssociatedObject(self, @"tv_dataSource");
}

@end
