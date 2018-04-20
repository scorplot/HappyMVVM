//
//  BaseVM.m
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import "BaseVM.h"
#import "BaseModel.h"
#import <CollectionViewArray/CollectionViewArray.h>
#import <CCUIModel/CCUIModel.h>
#import <TableViewArray/TableViewArray.h>
//#import <MJRefresh/MJRefresh.h>
@interface BaseVM ()

@property (nonatomic, strong) BaseModel * listModel;

@end

@implementation BaseVM
{
    UICollectionView * _listCollectionView;
    CollectionViewArray * _collectionViewArray;
    
    UITableView * _listTableView;
    TableViewArray * _tableViewArray;
    
    BOOL _firstError;
    UIView* _errorView;
    
    int _ingoreCountRefresh;
}
//-(MJRefreshHeader*)refreshHeader{
//    typeof(self) __weak SELF = self;
//    MJRefreshHeader * header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        [SELF refresh];
//    }];
//
//    return header;
//}
//-(void)setHideHeadRefresh:(BOOL)hideHeadRefresh{
//    _hideHeadRefresh = hideHeadRefresh;
//    if (hideHeadRefresh) {
//        if (self.listTableView) {
//            self.listTableView.mj_header = nil;
//        }
//        if (self.listCollectionView) {
//            self.listCollectionView.mj_header = nil;
//        }
//    }
//}
-(instancetype)initWith:(BaseModel *)model collectionView:(UICollectionView *)collectionView{
    if (self =  [super init]) {
        _listModel  = model;
        _listCollectionView = collectionView;
        _collectionViewArray = [[CollectionViewArray alloc] init];
        
        [self setUpCollectionView:_collectionViewArray collectionView:_listCollectionView];
        
        if (collectionView) {
            CollectionViewConnectArray(_listCollectionView, nil, _collectionViewArray);
        }
        if (!self.hideHeadRefresh) {
//            _listCollectionView.mj_header = [self refreshHeader];
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
//        if ([contentView isKindOfClass:[UICollectionView class]]) {
//            if ([(UICollectionView*)contentView mj_header].state != MJRefreshStateRefreshing)
//                _ingoreCountRefresh++;
//            [[(UICollectionView*)contentView mj_header] beginRefreshing];
//        }else{
//            if ([(UITableView*)contentView mj_header].state != MJRefreshStateRefreshing)
//                _ingoreCountRefresh++;
//            [[(UITableView*)contentView mj_header] beginRefreshing];
//        }
        if (_startRefresh) _startRefresh();
    } else {
        // refresh end
//        if ([contentView isKindOfClass:[UICollectionView class]]) {
//            [[(UICollectionView*)contentView mj_header] endRefreshing];
//        } else {
//            [[(UITableView*)contentView mj_header] endRefreshing];
//        }
        if (_didRefresh) _didRefresh();
    }
}

-(void)updateStatus:(BaseModelStatus)status view:(UIView*)contentView {
    switch (status) {
        case MODEL_ERROR:
            // error
            if (self.errorView) {
                CGRect rc = contentView.bounds;
                rc.origin = CGPointZero;
                _errorView.frame = rc;
                if (self.listModel.model == nil) {
                    [contentView addSubview:self.errorView];
                }
            }
            break;
        default:
            // normal
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

#pragma mark - tableView

-(instancetype)initWith:(BaseModel *)model tableView:(UITableView *)tableView{
    if (self = [super init]) {
        _listModel  = model;
        _listTableView = tableView;
        _tableViewArray = [[TableViewArray alloc] init];
        _listTableView.tableFooterView = [[UIView alloc] init];
        
        [self setUpTableView:_tableViewArray tableView:_listTableView];
        
        if (tableView) {
            TableViewConnectArray(_listTableView, nil, _tableViewArray);
        }
        if (!self.hideHeadRefresh) {
//            _listTableView.mj_header = [self refreshHeader];
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
