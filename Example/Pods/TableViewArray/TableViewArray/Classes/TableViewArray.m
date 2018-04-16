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
        self.tableViewStyle = UITableViewStylePlain;
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

