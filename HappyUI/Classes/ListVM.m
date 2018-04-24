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
#import "SimpleRefreshingView.h"
#import "SimpleGetMoreView.h"

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
    BOOL _firstLoading;
    UIView* _loadingView;
    
    BOOL _firstRefresh;
    UIView<ScrollRefreshHeaderProtocal>* _refreshHeaderView;

    BOOL _firstGetMore;
    UIView<ScrollGetMoreFooterProtocal>* _getMoreFooterView;
}

-(void)setRefreshHeaderView:(UIView<ScrollRefreshHeaderProtocal> *)refreshHeaderView {
    _firstRefresh = YES;
    if (_refreshHeaderView != refreshHeaderView) {
        [_refreshHeaderView removeFromSuperview];
        _refreshHeaderView = refreshHeaderView;
        if (_refreshHeaderView) {
            [_listTableView addSubview:_refreshHeaderView];
            [_listCollectionView addSubview:_refreshHeaderView];
        }
    }
}
-(UIView<ScrollRefreshHeaderProtocal>*)refreshHeaderView {
    if (_firstRefresh == NO) {
        _firstRefresh = YES;
        
        _refreshHeaderView = [[SimpleRefreshingView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    }
    return _refreshHeaderView;
}
-(void)setGetMoreFooterView:(UIView<ScrollGetMoreFooterProtocal> *)getMoreFooterView {
    _firstGetMore = YES;
    if (_getMoreFooterView != getMoreFooterView) {
        [_getMoreFooterView removeFromSuperview];
        _getMoreFooterView = getMoreFooterView;
        if (_getMoreFooterView) {
            [_listTableView addSubview:_getMoreFooterView];
            [_listCollectionView addSubview:_getMoreFooterView];
        }
    }
}
-(UIView<ScrollGetMoreFooterProtocal>*)getMoreFooterView {
    if (_firstGetMore == NO) {
        _firstGetMore = YES;
        
        _getMoreFooterView = [[SimpleGetMoreView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    }
    return _getMoreFooterView;
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
        __weak typeof(self) ws = self;
        if (self.refreshHeaderView) {
            [_listCollectionView addSubview:self.refreshHeaderView];
            self.refreshHeaderView.shouldTrigger = ^BOOL{
                [ws.listModel refresh];
                return ws.listModel.isRefreshing;
            };
        }
        if (self.getMoreFooterView) {
            [_listCollectionView addSubview:self.getMoreFooterView];
            self.getMoreFooterView.shouldTrigger = ^BOOL{
                [ws.listModel getMore];
                return ws.listModel.isGettingMore;
            };
        }
        // listener model changed
        [self addObserverForListBaseModelForView:_listCollectionView];
    }
    return self;
}

-(void)updateRefreshStatus:(BOOL)value view:(UIView*)contentView {
    _refreshHeaderView.refreshing = _listModel.isRefreshing;
    if (value) {
        if (_startRefresh) _startRefresh();
    } else {
        if (_didRefresh) _didRefresh();
    }
}

-(void)updateGetMoreStatus:(BOOL)value view:(UIView*)contentView {
    _getMoreFooterView.gettingMore = _listModel.isGettingMore;
    if (value) {
        if (_startGetMore) _startGetMore();
    } else {
        if (_didGetMore) _didGetMore();
    }
}

-(void)updateStatus:(ListModelStatus)status view:(UIView*)contentView {
    if (status == LIST_NORMAL) {
        [_emptyView removeFromSuperview];
        [_errorView removeFromSuperview];
        [_loadingView removeFromSuperview];
    } else {
        if (_listModel.isRefreshing) {
            [_emptyView removeFromSuperview];
            [_errorView removeFromSuperview];
            if (self.loadingView) {
                CGRect rc = contentView.bounds;
                rc.origin = CGPointZero;
                _loadingView.frame = rc;
                [contentView addSubview:_loadingView];
            }
        } else {
            if (status == LIST_EMEPTY) {
                // empty data
                [_errorView removeFromSuperview];
                if (self.emptyView) {
                    CGRect rc = contentView.bounds;
                    rc.origin = CGPointZero;
                    _emptyView.frame = rc;
                    [contentView addSubview:_emptyView];
                }
            } else if (status == LIST_ERROR) {
                // error
                [_emptyView removeFromSuperview];
                if (self.errorView) {
                    CGRect rc = contentView.bounds;
                    rc.origin = CGPointZero;
                    _errorView.frame = rc;
                    if (self.listModel.array.count==0) {
                        [contentView addSubview:_errorView];
                    }
                }
            }
        }
    }
}
-(void)addObserverForListBaseModelForView:(UIView *)contentView {
    typeof(self) __weak SELF = self;
    __weak UIView* __contentView = contentView;
    
    [createNotifer(SELF.listModel, @"status") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            [SELF updateRefreshStatus:SELF.listModel.isRefreshing view:__contentView];
            [SELF updateStatus:[value intValue] view:__contentView];
        }
    }];
    [createNotifer(SELF.listModel, @"refreshing") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            [SELF updateRefreshStatus:[value boolValue] view:__contentView];
            [SELF updateStatus:SELF.listModel.status view:__contentView];
        }
    }];
    
    [createNotifer(SELF.listModel, @"gettingMore") makeRelation:self withBlock:^(id value) {
        if (__contentView)
            [SELF updateGetMoreStatus:[value boolValue] view:__contentView];
    }];
    
    [createNotifer(SELF.listModel, @"hasMore") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            UIView* footer = SELF.getMoreFooterView;
            if ([value boolValue]) {
                [(UIScrollView*)__contentView addSubview:footer];
            } else {
                [footer removeFromSuperview];
            }
        }
    }];
}

#pragma mark - lazy load
-(void)setEmptyView:(UIView *)emptyView {
    _firstEmpty = YES;
    if (_emptyView != emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = emptyView;
        if (_emptyView) {
            [self updateStatus:_listModel.status view:_listTableView?_listTableView:_listCollectionView];
        }
    }
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
    if (_errorView != errorView) {
        [_errorView removeFromSuperview];
        _errorView = errorView;
        if (_errorView) {
            [self updateStatus:_listModel.status view:_listTableView?_listTableView:_listCollectionView];
        }
    }
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

-(void)setLoadingView:(UIView *)loadingView {
    _firstLoading = YES;
    if (_loadingView != loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = loadingView;
        if (_loadingView) {
            [self updateRefreshStatus:_listModel.isRefreshing view:_listTableView?_listTableView:_listCollectionView];
        }
    }
}
-(UIView* _Nullable)loadingView {
    if (_firstLoading == NO) {
        _firstLoading = YES;
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.tintColor = [UIColor blackColor];
        indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [indicator startAnimating];
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_loadingView addSubview:indicator];
        indicator.center = CGPointMake(50, 50);
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _loadingView;
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
        __weak typeof(self) ws = self;
        if (self.refreshHeaderView) {
            [_listTableView addSubview:self.refreshHeaderView];
            self.refreshHeaderView.shouldTrigger = ^BOOL{
                [ws.listModel refresh];
                return ws.listModel.isRefreshing;
            };
        }
        if (self.getMoreFooterView) {
            [_listTableView addSubview:self.getMoreFooterView];
            self.getMoreFooterView.shouldTrigger = ^BOOL{
                [ws.listModel getMore];
                return ws.listModel.isGettingMore;
            };
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
