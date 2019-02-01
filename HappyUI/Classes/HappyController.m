//
//  HappyController.m
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import "HappyController.h"
#import "HappyVM.h"
#import <CollectionViewArray/CollectionViewArray.h>
#import <CCUIModel/CCUIModel.h>
#import <TableViewArray/TableViewArray.h>
#import "SimpleRefreshingView.h"
@interface HappyController ()

@property (nonatomic, strong) HappyVM * vm;

@end

@implementation HappyController
{
    UICollectionView * _collectionView;
    CollectionViewArray * _collectionViewArray;
    
    UITableView * _tableView;
    TableViewArray * _tableViewArray;
    
    BOOL _firstError;
    UIView* _errorView;
    BOOL _firstLoading;
    UIView* _loadingView;
    BOOL _firstEmpty;
    UIView* _emptyView;
    
    BOOL _firstRefresh;
    UIView<ScrollRefreshHeaderProtocal>* _refreshHeaderView;

    UIEdgeInsets _insert;
    BOOL _isDraaging;
}

-(void)setRefreshInset {
    CGFloat top = 0;
    _refreshHeaderView.refreshing = _vm.isRefreshing;
    top = _refreshHeaderView?(_vm.isRefreshing?_refreshHeaderView.frame.size.height:0):0;
    if (top != _insert.top) {
        UIScrollView* scrollView = _tableView?_tableView:_collectionView;
        UIEdgeInsets insert = scrollView.contentInset;
        insert.top = insert.top-_insert.top+top;
        _insert.top = top;
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentInset:insert];
        }];
    }
}

-(void)setRefreshHeaderView:(UIView<ScrollRefreshHeaderProtocal> *)refreshHeaderView {
    _firstRefresh = YES;
    if (_refreshHeaderView != refreshHeaderView) {
        [_refreshHeaderView removeFromSuperview];
        _refreshHeaderView = refreshHeaderView;
        
        UIScrollView* scrollView = _tableView?_tableView:_collectionView;
        if (_refreshHeaderView) {
            [_tableView addSubview:_refreshHeaderView];
            [_collectionView addSubview:_refreshHeaderView];
            
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

-(instancetype)initWith:(HappyVM *)vm collectionView:(UICollectionView *)collectionView{
    if (self =  [super init]) {
        _vm  = vm;
        _collectionView = collectionView;
        _collectionViewArray = [[CollectionViewArray alloc] init];
        
        [self setUpCollectionView:_collectionViewArray collectionView:_collectionView];
        
        if (collectionView) {
            CollectionViewConnectArray(_collectionView, nil, _collectionViewArray);
        }
        __weak typeof(self) ws = self;
        if (self.refreshHeaderView) {
            [_collectionView addSubview:self.refreshHeaderView];
            self.refreshHeaderView.shouldTrigger = ^BOOL{
                [ws.vm refresh];
                return ws.vm.isRefreshing;
            };
        }

        // listener model changed
        [self addObserverForHappyListVMForView:_collectionView];
        [createNotifer(_vm, @"model") makeRelation:self withBlock:^(id value) {
            typeof(self) SELF = ws;
            if (SELF) {
                [SELF->_collectionView reloadData];
            }
        }];
        
        [collectionView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
        [collectionView addObserver:self forKeyPath:@"contentInset" options:0 context:nil];
        [collectionView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
    return self;
}

-(void)updateRefreshStatus:(BOOL)value view:(UIView*)contentView {
    _refreshHeaderView.refreshing = _vm.isRefreshing;
    [self setRefreshInset];
    if (value) {
        if (_startRefresh) _startRefresh();
    } else {
        if (_didRefresh) _didRefresh();
    }
}

-(void)updateStatus:(HappyViewModelStatus)status view:(UIView*)contentView {
    if (status == VIEW_MODEL_NORMAL) {
        [self.errorView removeFromSuperview];
        [self.loadingView removeFromSuperview];
    } else {
        if (_vm.isRefreshing) {
            [self.errorView removeFromSuperview];
            if (self.loadingView) {
                CGRect rc = contentView.bounds;
                rc.origin = CGPointZero;
                _loadingView.frame = rc;
                [contentView addSubview:_loadingView];
            }
        } else {
            [_loadingView removeFromSuperview];
            if (status == VIEW_MODEL_ERROR) {
                // error
                if (self.errorView) {
                    CGRect rc = contentView.bounds;
                    rc.origin = CGPointZero;
                    if ([contentView isKindOfClass:[UITableView class]]) {
                        CGFloat headerHeight = [(UITableView*)contentView tableHeaderView].frame.size.height;
                        rc.origin.y = headerHeight;
                        rc.size.height -= headerHeight;
                    }
                    _errorView.frame = rc;
                    if (self.vm.model == nil) {
                        [contentView addSubview:self.errorView];
                    }
                }
            } else {
                [self.errorView removeFromSuperview];
            }
        }
    }
}
-(void)addObserverForHappyListVMForView:(UIView *)contentView {
    typeof(self) __weak SELF = self;
    __weak UIView* __contentView = contentView;
    
    [createNotifer(SELF.vm, @"status") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            [SELF updateRefreshStatus:SELF.vm.isRefreshing view:__contentView];
            [SELF updateStatus:[value intValue] view:__contentView];
        }
    }];
    [createNotifer(SELF.vm, @"refreshing") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            [SELF updateRefreshStatus:[value boolValue] view:__contentView];
            [SELF updateStatus:SELF.vm.status view:__contentView];
        }
    }];
}

#pragma mark - lazy load
-(void)setErrorView:(UIView *)errorView {
    _firstError = YES;
    if (_errorView != errorView) {
        [_errorView removeFromSuperview];
        _errorView = errorView;
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

-(void)setEmptyView:(UIView *)emptyView {
    _firstEmpty = YES;
    if (_emptyView != emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = emptyView;
    }
}
-(UIView * _Nullable)emptyView{
    if (_firstEmpty == NO) {
        _firstEmpty = YES;
        
        _emptyView = [self defaultErrorView];
    }
    return _emptyView;
}
-(UIView*)defaultEmptyView {
    UILabel* view = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    view.text = NSLocalizedString(@"empty", nil);
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
-(instancetype)initWith:(HappyVM *)model tableView:(UITableView *)tableView{
    if (self = [super init]) {
        _vm  = model;
        _tableView = tableView;
        _tableViewArray = [[TableViewArray alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        
        [self setUpTableView:_tableViewArray tableView:_tableView];
        
        if (tableView) {
            TableViewConnectArray(_tableView, nil, _tableViewArray);
        }
        __weak typeof(self) ws = self;
        if (self.refreshHeaderView) {
            [_tableView addSubview:self.refreshHeaderView];
            self.refreshHeaderView.shouldTrigger = ^BOOL{
                [ws.vm refresh];
                return ws.vm.isRefreshing;
            };
        }

        // listener model changed
        [self addObserverForHappyListVMForView:_tableView];
        [createNotifer(_vm, @"model") makeRelation:self withBlock:^(id value) {
            typeof(self) SELF = ws;
            if (SELF) {
                [SELF->_tableView reloadData];
            }
        }];
        [tableView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
        [tableView addObserver:self forKeyPath:@"contentInset" options:0 context:nil];
        [tableView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
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

-(void)dealloc {
    [_tableView removeObserver:self forKeyPath:@"bounds"];
    [_tableView removeObserver:self forKeyPath:@"contentInset"];
    [_tableView removeObserver:self forKeyPath:@"contentOffset"];
    
    [_collectionView removeObserver:self forKeyPath:@"bounds"];
    [_collectionView removeObserver:self forKeyPath:@"contentInset"];
    [_collectionView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark refresh header
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView*)scrollView change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIEdgeInsets insert = scrollView.contentInset;
    if ([keyPath isEqualToString:@"contentInset"]) {
        [UIView setAnimationsEnabled:NO];
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, -insert.top - _refreshHeaderView.frame.size.height+_insert.top, rc.size.width, _refreshHeaderView.frame.size.height);
        if (!CGRectEqualToRect(_refreshHeaderView.frame, destRC))
            _refreshHeaderView.frame = destRC;
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
    } else if ([keyPath isEqualToString:@"bounds"]) {
        [UIView setAnimationsEnabled:NO];
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, -insert.top - _refreshHeaderView.frame.size.height+_insert.top, rc.size.width, _refreshHeaderView.frame.size.height);
        if (!CGRectEqualToRect(_refreshHeaderView.frame, destRC))
            _refreshHeaderView.frame = destRC;
        [UIView setAnimationsEnabled:YES];
    }
}

@end
