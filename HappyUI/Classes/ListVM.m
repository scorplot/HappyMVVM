//
//  ListVM.m
//  HappyUI
//
//  Created by Aruisi on 2017/8/1.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "ListVM.h"
#import "ListBaseModel.h"
#import <CollectionViewArray/CollectionViewArray.h>
#import <CCUIModel/CCUIModel.h>
#import <TableViewArray/TableViewArray.h>
//#import <MJRefresh/MJRefresh.h>
static const NSInteger preloadIndex  = 5;
@interface ListVM ()

@property (nonatomic, strong) ListBaseModel * listModel;

@end

@implementation ListVM
{
    UICollectionView * _listCollectionView;
    CollectionViewArray * _collectionViewArray;
    
    UITableView * _listTableView;
    TableViewArray * _tableViewArray;
    
    BOOL _firstEmpty;
    UIView* _emptyView;
    BOOL _firstError;
    UIView* _errorView;
    
    int _ingoreCountRefresh;
    int _ingoreCountGetMore;
}
//-(MJRefreshHeader*)refreshHeader{
//    typeof(self) __weak SELF = self;
//    MJRefreshHeader * header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        [SELF refresh];
//    }];
//
//    return header;
//}
//-(MJRefreshFooter*)refreshFooter{
//    typeof(self) __weak SELF = self;
//    MJRefreshFooter * footer = [MJRefreshFooter footerWithRefreshingBlock:^{
//        [SELF getMore];
//    }];
//    return footer;
//}
-(void)setHideHeadRefresh:(BOOL)hideHeadRefresh{
    _hideHeadRefresh = hideHeadRefresh;
    if (hideHeadRefresh) {
        if (self.listTableView) {
//            self.listTableView.mj_header = nil;
        }
        if (self.listCollectionView) {
//            self.listCollectionView.mj_header = nil;
        }
    }
}
-(void)setHideFooterGetMore:(BOOL)hideFooterRefresh{
    _hideFooterGetMore = hideFooterRefresh;
    if (hideFooterRefresh) {
        if (self.listTableView) {
//            self.listTableView.mj_footer = nil;
        }
        if (self.listCollectionView) {
//            self.listCollectionView.mj_footer = nil;
        }
    }
}
-(instancetype)initWith:(ListBaseModel *)model collectionView:(UICollectionView *)collectionView{
    if (self =  [super init]) {
        _listModel  = model;
        _listCollectionView = collectionView;
        _collectionViewArray = [[CollectionViewArray alloc] init];
        typeof(self)__weak SELF = self;
        _collectionViewArray.willDisplayCellForItemAtIndexPath = ^(UICollectionView * _Nonnull collectionView, UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath,id _Nullable object) {
            if (indexPath.row > [collectionView numberOfItemsInSection:0]-preloadIndex && !SELF.listModel.gettingMore&&!SELF.listModel.refreshing) {
                [SELF.listModel getMore];
            }
        };
        
        [self setUpCollectionView:_collectionViewArray collectionView:_listCollectionView];
        
        if (collectionView && model.array) {
            CollectionViewConnectArray(_listCollectionView, _listModel.array, _collectionViewArray);
        }
        if (!self.hideHeadRefresh) {
//            _listCollectionView.mj_header = [self refreshHeader];
        }
        if (!self.hideFooterGetMore) {
//            _listCollectionView.mj_footer = [self refreshFooter];
        }
        // listener model changed
        [self addObserverForListBaseModelForView:_listCollectionView];
    }
    return self;
}

-(void)refresh{
    if (_ingoreCountRefresh > 0) {
        _ingoreCountRefresh--;
        return;
    }
    
    [_listModel refresh];
}
-(void)updateRefreshStatus:(BOOL)value view:(UIView*)contentView {
    if (value) {
        // being refresh
        if ([contentView isKindOfClass:[UICollectionView class]]) {
//            if ([(UICollectionView*)contentView mj_header].state != MJRefreshStateRefreshing)
//                _ingoreCountRefresh++;
//            [[(UICollectionView*)contentView mj_header] beginRefreshing];
        }else{
//            if ([(UITableView*)contentView mj_header].state != MJRefreshStateRefreshing)
//                _ingoreCountRefresh++;
//            [[(UITableView*)contentView mj_header] beginRefreshing];
        }
        if (_startRefresh) _startRefresh();
    } else {
        // refresh end
        if ([contentView isKindOfClass:[UICollectionView class]]) {
//            [[(UICollectionView*)contentView mj_header] endRefreshing];
        } else {
//            [[(UITableView*)contentView mj_header] endRefreshing];
        }
        if (_didRefresh) _didRefresh();
    }
}

-(void)getMore {
    if (_ingoreCountGetMore > 0) {
        _ingoreCountGetMore--;
        return;
    }
    
    [_listModel getMore];
}
-(void)updateGetMoreStatus:(BOOL)value view:(UIView*)contentView {
    if (value) {
        // being get more
        if ([contentView isKindOfClass:[UICollectionView class]]) {
//            if ([(UICollectionView*)contentView mj_footer].state != MJRefreshStateRefreshing)
//                _ingoreCountGetMore++;
//            [[(UICollectionView*)contentView mj_footer] beginRefreshing];
        }else{
//            if ([(UITableView*)contentView mj_footer].state != MJRefreshStateRefreshing)
//                _ingoreCountGetMore++;
//            [[(UITableView*)contentView mj_footer] beginRefreshing];
        }
        if (_startGetMore) _startGetMore();
    } else {
        // get more end
//        if ([contentView isKindOfClass:[UICollectionView class]]) {
//            [[(UICollectionView*)contentView mj_footer] endRefreshing];
//        } else {
//            [[(UITableView*)contentView mj_footer] endRefreshing];
//        }
        if (_didGetMore) _didGetMore();
    }
}

-(void)updateStatus:(ListModelStatus)status view:(UIView*)contentView {
    switch (status) {
        case LIST_EMEPTY:
            // empty data
            [_errorView removeFromSuperview];
            if (self.emptyView) {
                CGRect rc = contentView.bounds;
                rc.origin = CGPointZero;
                _emptyView.frame = rc;
                [contentView addSubview:self.emptyView];
            }
            break;
        case LIST_ERROR:
            // error
            [_emptyView removeFromSuperview];
            if (self.errorView) {
                CGRect rc = contentView.bounds;
                rc.origin = CGPointZero;
                _errorView.frame = rc;
                if (self.listModel.array.count==0) {
                    [contentView addSubview:self.errorView];
                }
                
            }
            break;
        default:
            // normal
            [self.emptyView removeFromSuperview];
            [self.errorView removeFromSuperview];
            break;
    }
}
-(void)addObserverForListBaseModelForView:(UIView *)contentView {
    typeof(self) __weak SELF = self;
    __weak UIView* __contentView = contentView;
    
    [createNotifer(SELF.listModel, @"status") makeRelation:self withBlock:^(id value) {
        if (__contentView)
            [SELF updateStatus:[value intValue] view:__contentView];
    }];
    [createNotifer(SELF.listModel, @"refreshing") makeRelation:self withBlock:^(id value) {
        if (__contentView)
            [SELF updateRefreshStatus:[value boolValue] view:__contentView];
    }];
    
    [createNotifer(SELF.listModel, @"gettingMore") makeRelation:self withBlock:^(id value) {
        if (__contentView)
            [SELF updateGetMoreStatus:[value boolValue] view:__contentView];
    }];
    
    [createNotifer(SELF.listModel, @"hasMore") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            if ([value boolValue]) {
//                if ([__contentView isKindOfClass:[UICollectionView class]]) {
//                    [(UICollectionView*)__contentView mj_footer].hidden = NO ;
//
//                }else{
//                    [(UITableView*)__contentView mj_footer].hidden = NO;
//                }
            }else{
//                if ([__contentView isKindOfClass:[UICollectionView class]]) {
//                    [(UICollectionView*)__contentView mj_footer].hidden = YES ;
//
//                }else{
//                    [(UITableView*)__contentView mj_footer].hidden = YES;
//                }
            }
        }
    }];
}

#pragma mark - lazy load
-(void)setEmptyView:(UIView *)emptyView {
    _firstEmpty = YES;
    _emptyView = emptyView;
}
-(UIView * _Nullable)emptyView{
    if (_firstEmpty == NO) {
        _firstEmpty = YES;
        UILabel* view = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
        view.text = NSLocalizedString(@"no data", nil);
        view.backgroundColor = [UIColor redColor];
        
        _emptyView = view;
    }
    return _emptyView;
}

-(void)setErrorView:(UIView *)errorView {
    _firstError = YES;
    _errorView = errorView;
}
-(UIView * _Nullable)errorView{
    if (_firstError == NO) {
        _firstError = YES;
        
        UILabel* view = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
        view.text = NSLocalizedString(@"error occurs", nil);
        view.backgroundColor = [UIColor purpleColor];
        
        _errorView = view;
    }
    return _errorView;
}

#pragma mark - tableView

-(instancetype)initWith:(ListBaseModel *)model tableView:(UITableView *)tableView{
    if (self = [super init]) {
        _listModel  = model;
        _listTableView = tableView;
        _tableViewArray = [[TableViewArray alloc] init];
        typeof(self)__weak SELF = self;
        _listTableView.tableFooterView = [[UIView alloc] init];
        _tableViewArray.willDisplayCellforRowAtIndexPath = ^(UITableView * _Nullable tableView, UITableViewCell * _Nullable cell, NSIndexPath * _Nullable indexPath,id _Nullable object) {
            if (indexPath.row > [tableView numberOfRowsInSection:0]- preloadIndex && !SELF.listModel.gettingMore&&!SELF.listModel.refreshing) {
                [SELF.listModel getMore];
            }
        };
        
        [self setUpTableView:_tableViewArray tableView:_listTableView];
        
        if (tableView && model.array) {
            TableViewConnectArray(_listTableView, _listModel.array, _tableViewArray);
        }
        if (!self.hideHeadRefresh) {
//            _listTableView.mj_header = [self refreshHeader];
        }
        if (!self.hideFooterGetMore) {
//            _listTableView.mj_footer = [self refreshFooter];
        }
        
        // listener model changed
        [self addObserverForListBaseModelForView:_listTableView];
    }
    return self;
}
#pragma mark sub class
-(void)setUpTableView:(TableViewArray *)binder tableView:(UITableView *)tableView{
}
-(void)setUpCollectionView:(CollectionViewArray*)binder collectionView:(UICollectionView*)collectionView{
}

@end
