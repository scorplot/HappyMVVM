//
//  BaseVM.m
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import "HappyVM.h"
#import "HappyModel.h"
#import <CollectionViewArray/CollectionViewArray.h>
#import <CCUIModel/CCUIModel.h>
#import <TableViewArray/TableViewArray.h>
#import "SimpleRefreshingView.h"
@interface HappyVM ()

@property (nonatomic, strong) HappyModel * model;

@end

@implementation HappyVM
{
    UICollectionView * _collectionView;
    CollectionViewArray * _collectionViewArray;
    
    UITableView * _tableView;
    TableViewArray * _tableViewArray;
    
    BOOL _firstError;
    UIView* _errorView;
    BOOL _firstLoading;
    UIView* _loadingView;
    
    BOOL _firstRefresh;
    UIView<ScrollRefreshHeaderProtocal>* _refreshHeaderView;
}

-(void)setRefreshHeaderView:(UIView<ScrollRefreshHeaderProtocal> *)refreshHeaderView {
    _firstRefresh = YES;
    _firstRefresh = YES;
    if (_refreshHeaderView != refreshHeaderView) {
        [_refreshHeaderView removeFromSuperview];
        _refreshHeaderView = refreshHeaderView;
        if (_refreshHeaderView) {
            [_tableView addSubview:_refreshHeaderView];
            [_collectionView addSubview:_refreshHeaderView];
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

-(instancetype)initWith:(HappyModel *)model collectionView:(UICollectionView *)collectionView{
    if (self =  [super init]) {
        _model  = model;
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
                [ws.model refresh];
                return ws.model.isRefreshing;
            };
        }
        // listener model changed
        [self addObserverForListBaseModelForView:_collectionView];
    }
    return self;
}

-(void)updateRefreshStatus:(BOOL)value view:(UIView*)contentView {
    _refreshHeaderView.refreshing = _model.isRefreshing;
    if (value) {
        if (_startRefresh) _startRefresh();
    } else {
        if (_didRefresh) _didRefresh();
    }
}

-(void)updateStatus:(BaseModelStatus)status view:(UIView*)contentView {
    if (status == MODEL_NORMAL) {
        [self.loadingView removeFromSuperview];
    } else {
        if (_model.isRefreshing) {
            [self.errorView removeFromSuperview];
            if (self.loadingView) {
                CGRect rc = contentView.bounds;
                rc.origin = CGPointZero;
                _loadingView.frame = rc;
                [contentView addSubview:_loadingView];
            }
        } else {
            if (status == MODEL_ERROR) {
                // error
                if (self.errorView) {
                    CGRect rc = contentView.bounds;
                    rc.origin = CGPointZero;
                    _errorView.frame = rc;
                    if (self.model.model == nil) {
                        [contentView addSubview:self.errorView];
                    }
                }
            } else {
                [self.errorView removeFromSuperview];
            }
            [self.loadingView removeFromSuperview];
        }
    }
}
-(void)addObserverForListBaseModelForView:(UIView *)contentView {
    typeof(self) __weak SELF = self;
    __weak UIView* __contentView = contentView;
    
    [createNotifer(SELF.model, @"status") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            [SELF updateRefreshStatus:SELF.model.isRefreshing view:__contentView];
            [SELF updateStatus:[value intValue] view:__contentView];
        }
    }];
    [createNotifer(SELF.model, @"refreshing") makeRelation:self withBlock:^(id value) {
        if (__contentView) {
            [SELF updateRefreshStatus:[value boolValue] view:__contentView];
            [SELF updateStatus:SELF.model.status view:__contentView];
        }
    }];
}

#pragma mark - lazy load
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

-(void)setLoadingView:(UIView *)loadingView {
    _firstLoading = YES;
    _loadingView = loadingView;
}
-(UIView* _Nullable)loadingView {
    if (_firstLoading == NO) {
        _firstLoading = YES;
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
-(instancetype)initWith:(HappyModel *)model tableView:(UITableView *)tableView{
    if (self = [super init]) {
        _model  = model;
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
                [ws.model refresh];
                return ws.model.isRefreshing;
            };
        }
        
        // listener model changed
        [self addObserverForListBaseModelForView:_tableView];
    }
    return self;
}
#pragma mark sub class
-(void)setUpTableView:(TableViewArray *)binder tableView:(UITableView *)tableView{
}
-(void)setUpCollectionView:(CollectionViewArray*)binder collectionView:(UICollectionView*)collectionView{
}
@end
