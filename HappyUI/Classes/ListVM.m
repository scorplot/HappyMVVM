//
//  ListVM.m
//  HappyUI
//
//  Created by Aruisi on 2017/8/1.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "ListVM.h"
#import "HappyListBI.h"
#import <CollectionViewArray/CollectionViewArray.h>
#import <CCUIModel/CCUIModel.h>
#import <TableViewArray/TableViewArray.h>
#import "SimpleRefreshingView.h"
#import "SimpleGetMoreView.h"

static const NSInteger preloadIndex  = 5;
@interface ListVM ()

@property (nonatomic, strong) HappyListBI * listModel;

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
    
    UIEdgeInsets _insert;
    BOOL _isDraaging;
}

-(instancetype)initWith:(HappyListBI *)model collectionView:(UICollectionView *)collectionView{
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
            [_listCollectionView insertSubview:self.refreshHeaderView atIndex:0];
            self.refreshHeaderView.shouldTrigger = ^BOOL{
                [ws.listModel refresh];
                return ws.listModel.isRefreshing;
            };
        }
        if (self.getMoreFooterView) {
            if (_listModel.hasMore)
                [_listCollectionView addSubview:_getMoreFooterView];
            self.getMoreFooterView.shouldTrigger = ^BOOL{
                [ws.listModel getMore];
                return ws.listModel.isGettingMore;
            };
        }
        
        model.refreshDidSuccess = ^{
            CGPoint offset = ws.listCollectionView.contentOffset;
            UIEdgeInsets insets = ws.listCollectionView.contentInset;
            offset.y = -insets.top;
            offset.x = -insets.left;
            [ws.listCollectionView setContentOffset:offset animated:YES];
        };
        
        // listener model changed
        [self addObserverForHappyListBIForView:_listCollectionView];
        
        [collectionView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
        [collectionView addObserver:self forKeyPath:@"contentInset" options:0 context:nil];
        [collectionView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
        [collectionView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
    }
    return self;
}

-(void)setRefreshInset {
    CGFloat top = 0;
    _refreshHeaderView.refreshing = _listModel.isRefreshing;
    top = _refreshHeaderView?(_listModel.isRefreshing?_refreshHeaderView.frame.size.height:0):0;
    if (top != _insert.top) {
        UIScrollView* scrollView = _listTableView?_listTableView:_listCollectionView;
        UIEdgeInsets insert = scrollView.contentInset;
        insert.top = insert.top-_insert.top+top;
        _insert.top = top;
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentInset:insert];
        }];
    }
}
-(void)updateRefreshStatus:(BOOL)value view:(UIView*)contentView {
    [self setRefreshInset];
    if (value) {
        if (_startRefresh) _startRefresh();
    } else {
        if (_didRefresh) _didRefresh();
    }
}

-(void)setGetMoreInset{
    CGFloat bottom = 0;
    _getMoreFooterView.gettingMore = _listModel.isGettingMore;
    bottom = _getMoreFooterView?(_listModel.isGettingMore?_getMoreFooterView.frame.size.height:0):0;
    if (bottom != _insert.bottom) {
        UIScrollView* scrollView = _listTableView?_listTableView:_listCollectionView;
        UIEdgeInsets insert = scrollView.contentInset;
        insert.bottom = insert.bottom-_insert.bottom+bottom;
        _insert.bottom = bottom;
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentInset:insert];
        }];
    }
}
-(void)updateGetMoreStatus:(BOOL)value view:(UIView*)contentView {
    if (_listModel.hasMore) {
        [_listTableView addSubview:_getMoreFooterView];
        [_listCollectionView addSubview:_getMoreFooterView];
    } else {
        [_getMoreFooterView removeFromSuperview];
    }
    [self setGetMoreInset];
    if (value) {
        if (_startGetMore) _startGetMore();
    } else {
        if (_didGetMore) _didGetMore();
    }
}

-(void)updateStatus:(ListModelStatus)status view:(UIScrollView*)contentView {
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
            [_loadingView removeFromSuperview];
            if (status == LIST_EMEPTY) {
                // empty data
                [_errorView removeFromSuperview];
                if (self.emptyView) {
                    CGRect rc = contentView.bounds;
                    rc.origin = CGPointZero;
                    if ([contentView isKindOfClass:[UITableView class]]) {
                        CGFloat headerHeight = [(UITableView*)contentView tableHeaderView].frame.size.height;
                        rc.origin.y = headerHeight;
                        rc.size.height -= headerHeight;
                    }
                    _emptyView.frame = rc;
                    [contentView addSubview:_emptyView];
                }
            } else if (status == LIST_ERROR) {
                // error
                [_emptyView removeFromSuperview];
                if (self.errorView) {
                    CGRect rc = contentView.bounds;
                    rc.origin = CGPointZero;
                    if ([contentView isKindOfClass:[UITableView class]]) {
                        CGFloat headerHeight = [(UITableView*)contentView tableHeaderView].frame.size.height;
                        rc.origin.y = headerHeight;
                        rc.size.height -= headerHeight;
                    }
                    _errorView.frame = rc;
                    if (self.listModel.array.count==0) {
                        [contentView addSubview:_errorView];
                    }
                }
            }
        }
    }
}
-(void)addObserverForHappyListBIForView:(UIScrollView *)contentView {
    typeof(self) __weak SELF = self;
    __weak UIScrollView* __contentView = contentView;
    
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
        
        _emptyView = [self defaultEmptyView];
    }
    return _emptyView;
}

-(UIView*)defaultEmptyView {
    UILabel* view = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    view.text = NSLocalizedString(@"no data", nil);
    view.backgroundColor = [UIColor redColor];
    return view;
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
        
        _errorView = [self defaultErrorView];
    }
    return _errorView;
}
-(UIView*)defaultErrorView {
    UILabel* view = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    view.text = NSLocalizedString(@"error occurs", nil);
    view.backgroundColor = [UIColor purpleColor];
    return view;
}

-(void)setLoadingView:(UIView *)loadingView {
    _firstLoading = YES;
    if (_loadingView != loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = loadingView;
    }
}
-(UIView* _Nullable)loadingView {
    if (_firstLoading == NO) {
        _firstLoading = YES;
        
        _loadingView = [self defaultLoadingView];
    }
    return _loadingView;
}
-(UIView*)defaultLoadingView {
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.tintColor = [UIColor blackColor];
    indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [indicator startAnimating];
    
    UIView* loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [loadingView addSubview:indicator];
    indicator.center = CGPointMake(50, 50);
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    return loadingView;
}

#pragma mark - tableView

-(instancetype)initWith:(HappyListBI *)model tableView:(UITableView *)tableView{
    if (self = [super init]) {
        _listModel  = model;
        _listTableView = tableView;
        _tableViewArray = [[TableViewArray alloc] init];
        _tableViewArray.disableAnimation = YES;
        typeof(self)__weak SELF = self;
        _listTableView.tableFooterView = [[UIView alloc] init];
        _tableViewArray.willDisplayCellforRowAtIndexPath = ^(UITableView * _Nullable tableView, UITableViewCell * _Nullable cell, NSIndexPath * _Nullable indexPath,id _Nullable object) {
            if (tableView.contentOffset.y > tableView.contentSize.height-tableView.frame.size.height*1.3 && !SELF.listModel.gettingMore&&!SELF.listModel.refreshing) {
                [SELF.listModel getMore];
            }
            [tableView sendSubviewToBack:SELF.refreshHeaderView];
        };
        
        [self setUpTableView:_tableViewArray tableView:_listTableView];
        
        if (tableView && model.array) {
            TableViewConnectArray(_listTableView, _listModel.array, _tableViewArray);
        }
        __weak typeof(self) ws = self;
        if (self.refreshHeaderView) {
            [_listTableView insertSubview:self.refreshHeaderView atIndex:0];
            self.refreshHeaderView.shouldTrigger = ^BOOL{
                [ws.listModel refresh];
                return ws.listModel.isRefreshing;
            };
        }
        if (self.getMoreFooterView) {
            if (_listModel.hasMore)
                [_listTableView addSubview:_getMoreFooterView];
            self.getMoreFooterView.shouldTrigger = ^BOOL{
                [ws.listModel getMore];
                return ws.listModel.isGettingMore;
            };
        }
        
        model.refreshDidSuccess = ^{
            CGPoint offset = ws.listTableView.contentOffset;
            UIEdgeInsets insets = ws.listTableView.contentInset;
            offset.y = -insets.top;
            [ws.listTableView setContentOffset:offset animated:YES];
        };
        
        // listener model changed
        [self addObserverForHappyListBIForView:_listTableView];
        
        [tableView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
        [tableView addObserver:self forKeyPath:@"contentInset" options:0 context:nil];
        [tableView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
        [tableView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
    }
    return self;
}
#pragma mark sub class
-(void)setUpTableView:(TableViewArray *)binder tableView:(UITableView *)tableView{
}
-(void)setUpCollectionView:(CollectionViewArray*)binder collectionView:(UICollectionView*)collectionView{
}

-(UIView<ScrollRefreshHeaderProtocal>*)defaultRefreshHeaderView {
    return [[SimpleRefreshingView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
}
-(UIView<ScrollGetMoreFooterProtocal>*)defaultGetMoreFooterView {
    return [[SimpleGetMoreView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
}

-(void)dealloc {
    [_listTableView removeObserver:self forKeyPath:@"bounds"];
    [_listTableView removeObserver:self forKeyPath:@"contentInset"];
    [_listTableView removeObserver:self forKeyPath:@"contentOffset"];
    [_listTableView removeObserver:self forKeyPath:@"contentSize"];

    [_listCollectionView removeObserver:self forKeyPath:@"bounds"];
    [_listCollectionView removeObserver:self forKeyPath:@"contentInset"];
    [_listCollectionView removeObserver:self forKeyPath:@"contentOffset"];
    [_listCollectionView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark refreshView
-(void)setRefreshHeaderView:(UIView<ScrollRefreshHeaderProtocal> *)refreshHeaderView {
    _firstRefresh = YES;
    if (_refreshHeaderView != refreshHeaderView) {
        [_refreshHeaderView removeFromSuperview];
        _refreshHeaderView = refreshHeaderView; 

        UIScrollView* scrollView = _listTableView?_listTableView:_listCollectionView;
        if (_refreshHeaderView) {
            [_listTableView addSubview:_refreshHeaderView];
            [_listCollectionView addSubview:_refreshHeaderView];
            
            UIEdgeInsets inset = scrollView.contentInset;
            CGRect rc = scrollView.frame;
            _refreshHeaderView.frame = CGRectMake(0, -inset.top - _refreshHeaderView.frame.size.height+_insert.top, rc.size.width, _refreshHeaderView.frame.size.height);
        }
        [self setRefreshInset];
        CGPoint offset = scrollView.contentOffset;
        UIEdgeInsets insert = scrollView.contentInset;
        [_refreshHeaderView scrollOffset:-offset.y-_insert.top+insert.top];
        [self setRefreshInset];
    }
}
-(UIView<ScrollRefreshHeaderProtocal>*)refreshHeaderView {
    if (_firstRefresh == NO) {
        _firstRefresh = YES;
        
        _refreshHeaderView = [self defaultRefreshHeaderView];
    }
    return _refreshHeaderView;
}

-(void)setGetMoreFooterView:(UIView<ScrollGetMoreFooterProtocal> *)getMoreFooterView {
    _firstGetMore = YES;
    if (_getMoreFooterView != getMoreFooterView) {
        [_getMoreFooterView removeFromSuperview];
        _getMoreFooterView = getMoreFooterView;
        UIScrollView* scrollView = _listTableView?_listTableView:_listCollectionView;
        CGPoint offset = scrollView.contentOffset;
        UIEdgeInsets insert = scrollView.contentInset;
        if (_getMoreFooterView) {
            
            if (_listModel.hasMore) {
                [_listTableView addSubview:_getMoreFooterView];
                [_listCollectionView addSubview:_getMoreFooterView];
                _getMoreFooterView.frame = CGRectMake(0, scrollView.contentSize.height+insert.bottom-_insert.bottom, scrollView.frame.size.width, _getMoreFooterView.frame.size.height);

            }
        }
        if (_listModel.isGettingMore) {
            [self setGetMoreInset];
            [_getMoreFooterView scrollOffset:scrollView.contentSize.height + insert.bottom - _insert.bottom - scrollView.frame.size.height];
        }
        [self setGetMoreInset];
    }
}
-(UIView<ScrollGetMoreFooterProtocal>*)getMoreFooterView {
    if (_firstGetMore == NO) {
        _firstGetMore = YES;
        
        _getMoreFooterView = [self defaultGetMoreFooterView];
    }
    return _getMoreFooterView;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView*)scrollView change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIEdgeInsets insert = scrollView.contentInset;
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, scrollView.contentSize.height+insert.bottom-_insert.bottom, rc.size.width, _getMoreFooterView.frame.size.height);
        if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
            _getMoreFooterView.frame = destRC;
    } else if ([keyPath isEqualToString:@"contentInset"]) {
        [UIView setAnimationsEnabled:NO];
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, -insert.top - _refreshHeaderView.frame.size.height+_insert.top, rc.size.width, _refreshHeaderView.frame.size.height);
        if (!CGRectEqualToRect(_refreshHeaderView.frame, destRC))
            _refreshHeaderView.frame = destRC;
        
        destRC = CGRectMake(0, scrollView.contentSize.height+insert.bottom-_insert.bottom, rc.size.width, _getMoreFooterView.frame.size.height);
        if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
            _getMoreFooterView.frame = destRC;
        [UIView setAnimationsEnabled:YES];
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = scrollView.contentOffset;
        // refresh header
        [_refreshHeaderView scrollOffset:-offset.y-_insert.top+insert.top];
        if (-offset.y-_insert.top+insert.top > _refreshHeaderView.frame.size.height) {
            if (scrollView.isDragging != _isDraaging) {
                _isDraaging = scrollView.isDragging;
                if (scrollView.isDragging == NO) {
                    BOOL trigger = NO;
                    if (_refreshHeaderView.shouldTrigger) {
                        trigger = _refreshHeaderView.shouldTrigger();
                    }
                    _refreshHeaderView.refreshing = trigger;
                }
            }
        }
        
        // get more
        [_getMoreFooterView scrollOffset:scrollView.contentSize.height + insert.bottom - _insert.bottom - scrollView.frame.size.height];
        if (offset.y > scrollView.contentSize.height + insert.bottom - _insert.bottom - scrollView.frame.size.height + _getMoreFooterView.frame.size.height) {
            if (scrollView.isDragging != _isDraaging) {
                _isDraaging = scrollView.isDragging;
                if (scrollView.isDragging == NO) {
                    BOOL trigger = NO;
                    if (_getMoreFooterView.shouldTrigger) {
                        trigger = _getMoreFooterView.shouldTrigger();
                    }
                    _getMoreFooterView.gettingMore = trigger;
                }
            }
        }
    } else if ([keyPath isEqualToString:@"bounds"]) {
        [UIView setAnimationsEnabled:NO];
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, -insert.top - _refreshHeaderView.frame.size.height+_insert.top, rc.size.width, _refreshHeaderView.frame.size.height);
        if (!CGRectEqualToRect(_refreshHeaderView.frame, destRC))
            _refreshHeaderView.frame = destRC;
        
        destRC = CGRectMake(0, scrollView.contentSize.height+insert.bottom-_insert.bottom, rc.size.width, _getMoreFooterView.frame.size.height);
        if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
            _getMoreFooterView.frame = destRC;
        [UIView setAnimationsEnabled:YES];
    }
}
@end
