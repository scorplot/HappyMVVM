//
//  HappyListController.m
//  HappyMVVM
//
//  Created by Aruisi on 2017/8/1.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "HappyListController.h"
#import "HappyListVM.h"
#import <CollectionViewArray/CollectionViewArray.h>
#import <CCUIModel/CCUIModel.h>
#import <TableViewArray/TableViewArray.h>
#import "SimpleRefreshingView.h"
#import "SimpleGetMoreView.h"

static const NSInteger preloadIndex  = 5;
@interface HappyController () {
@protected
    CollectionViewArray * _collectionViewArray;
    TableViewArray * _tableViewArray;
    
    BOOL _isDraaging;
    UIEdgeInsets _insert;
}
@property (nonatomic, strong) HappyVM * vm;

-(void)addObserverForHappyVMForView:(UIView *)contentView;

@end



#pragma clang diagnostic push
#pragma clang diagnostic ignored  "-Wincomplete-implementation"
@implementation HappyListController
{
    BOOL _firstGetMore;
    UIView<ScrollGetMoreFooterProtocal>* _getMoreFooterView;
}
@dynamic startRefresh;
@dynamic didRefresh;
@dynamic errorView;
@dynamic loadingView;
@dynamic emptyView;
@dynamic refreshHeaderView;
@dynamic vm;
@dynamic collectionView;
@dynamic tableView;

-(instancetype)initWith:(HappyListVM *)vm collectionView:(UICollectionView *)collectionView{
    if (self =  [super initWith:vm collectionView:collectionView]) {
        typeof(self)__weak ws = self;
        if (self.getMoreFooterView) {
            if (self.vm.hasMore)
                [self.collectionView addSubview:_getMoreFooterView];
            self.getMoreFooterView.shouldTrigger = ^BOOL{
                [ws.vm getMore];
                return ws.vm.isGettingMore;
            };
        }
        
        _collectionViewArray.willDisplayCellForItemAtIndexPath = ^(UICollectionView * _Nonnull collectionView, UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath,id _Nullable object) {
            if (indexPath.row > [collectionView numberOfItemsInSection:0]-preloadIndex && !ws.vm.gettingMore&&!ws.vm.refreshing) {
                [ws.vm getMore];
            }
        };
    }
    return self;
}

-(void)setGetMoreInset{
    CGFloat bottom = 0;
    _getMoreFooterView.gettingMore = self.vm.isGettingMore;
    bottom = _getMoreFooterView?(self.vm.isGettingMore?_getMoreFooterView.frame.size.height:0):0;
    if (bottom != _insert.bottom) {
        UIScrollView* scrollView = self.tableView?self.tableView:self.collectionView;
        UIEdgeInsets insert = scrollView.contentInset;
        insert.bottom = insert.bottom-_insert.bottom+bottom;
        _insert.bottom = bottom;
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentInset:insert];
        }];
    }
}
-(void)updateGetMoreStatus:(BOOL)value view:(UIView*)contentView {
    // TODO:@chj 不一致的时候才设置
    if (self.vm.hasMore) {
        [self.tableView addSubview:_getMoreFooterView];
        [self.collectionView addSubview:_getMoreFooterView];
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

-(void)addObserverForHappyVMForView:(UIScrollView *)contentView {
    typeof(self) __weak SELF = self;
    __weak UIScrollView* __contentView = contentView;
    
    [super addObserverForHappyVMForView:contentView];
    
    [CCMNotifier(SELF.vm, gettingMore) makeRelation:self withBlock:^(id value) {
        if (__contentView)
            [SELF updateGetMoreStatus:[value boolValue] view:__contentView];
    }];
    
    [CCMNotifier(SELF.vm, hasMore) makeRelation:self withBlock:^(id value) {
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



#pragma mark - tableView
-(instancetype)initWith:(HappyListVM *)vm tableView:(UITableView *)tableView{
    if (self = [super initWith:vm tableView:tableView]) {
        
        __weak typeof(self) ws = self;
        _tableViewArray.willDisplayCellforRowAtIndexPath = ^(UITableView * _Nullable tableView, UITableViewCell * _Nullable cell, NSIndexPath * _Nullable indexPath,id _Nullable object) {
            if (tableView.contentOffset.y > tableView.contentSize.height-tableView.frame.size.height*1.3 && !ws.vm.gettingMore&&!ws.vm.refreshing) {
                [ws.vm getMore];
            }
            [ws.tableView sendSubviewToBack:ws.refreshHeaderView];
        };
        
        if (self.getMoreFooterView) {
            if (self.vm.hasMore)
                [self.tableView addSubview:_getMoreFooterView];
            self.getMoreFooterView.shouldTrigger = ^BOOL{
                [ws.vm getMore];
                return ws.vm.isGettingMore;
            };
        }
    }
    return self;
}

#pragma mark sub class
-(UIView<ScrollGetMoreFooterProtocal>*)defaultGetMoreFooterView {
    return [[SimpleGetMoreView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
}

#pragma mark getmore view
-(void)setGetMoreFooterView:(UIView<ScrollGetMoreFooterProtocal> *)getMoreFooterView {
    _firstGetMore = YES;
    if (_getMoreFooterView != getMoreFooterView) {
        [_getMoreFooterView removeFromSuperview];
        _getMoreFooterView = getMoreFooterView;
        UIScrollView* scrollView = self.tableView?self.tableView:self.collectionView;
        //CGPoint offset = scrollView.contentOffset;
        UIEdgeInsets insert = scrollView.contentInset;
        if (_getMoreFooterView) {
            
            if (self.vm.hasMore) {
                [self.tableView addSubview:_getMoreFooterView];
                [self.collectionView addSubview:_getMoreFooterView];
                _getMoreFooterView.frame = CGRectMake(0, scrollView.contentSize.height+insert.bottom-_insert.bottom, scrollView.frame.size.width, _getMoreFooterView.frame.size.height);

            }
        }
        if (self.vm.isGettingMore) {
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
    [super observeValueForKeyPath:keyPath ofObject:scrollView change:change context:context];
    
    UIEdgeInsets insert = scrollView.contentInset;
    if ([keyPath isEqualToString:@"contentSize"]) {
        [UIView setAnimationsEnabled:NO];
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, scrollView.contentSize.height+insert.bottom+insert.top, rc.size.width, _getMoreFooterView.frame.size.height);
        if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
            _getMoreFooterView.frame = destRC;
        [UIView setAnimationsEnabled:YES];
    } else if ([keyPath isEqualToString:@"contentInset"]) {
        [UIView setAnimationsEnabled:NO];
        CGRect rc = scrollView.frame;
        CGRect destRC = CGRectMake(0, scrollView.contentSize.height+insert.bottom+insert.top, rc.size.width, _getMoreFooterView.frame.size.height);
        if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
            _getMoreFooterView.frame = destRC;
        [UIView setAnimationsEnabled:YES];
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = scrollView.contentOffset;
        
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
        CGRect destRC = CGRectMake(0, scrollView.contentSize.height+insert.top+_insert.bottom, rc.size.width, _getMoreFooterView.frame.size.height);
        if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
            _getMoreFooterView.frame = destRC;
        [UIView setAnimationsEnabled:YES];
    }
}
@end
#pragma clang diagnostic pop
