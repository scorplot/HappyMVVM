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
    
    // pull up or pull down insert
    UIEdgeInsets _pullUpDownInsert;
}
@property (nonatomic, strong) HappyVM * vm;

-(void)addObserverForHappyVMForView:(UIScrollView *)contentView;
-(void)updateScrollViewInset;

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

#pragma util
-(void)updateGetMoreFrame {
    UIScrollView* scrollView = self.tableView?self.tableView:self.collectionView;
    CGRect rc = scrollView.frame;
    CGRect destRC = CGRectMake(0, scrollView.contentSize.height+self.insert.bottom+self.insert.top, rc.size.width, _getMoreFooterView.frame.size.height);
    if (!CGRectEqualToRect(_getMoreFooterView.frame, destRC))
        _getMoreFooterView.frame = destRC;
}

-(void)updateGetMoreStatus:(BOOL)value view:(UIScrollView*)contentView {
    // TODO:@chj 不一致的时候才设置
    _getMoreFooterView.gettingMore = value;
    _pullUpDownInsert.bottom = _getMoreFooterView?(value?_getMoreFooterView.frame.size.height:0):0;
    [UIView animateWithDuration:0.3 animations:^{
        [self updateScrollViewInset];
    }];
    if (value) {
        if (_startGetMore) _startGetMore();
    } else {
        if (_didGetMore) _didGetMore();
    }
}

-(void)updateHasMoreStatus:(BOOL)value view:(UIScrollView*)contentView {
    if (value) {
        [contentView addSubview:_getMoreFooterView];
    } else {
        [_getMoreFooterView removeFromSuperview];
    }
}

-(void)addObserverForHappyVMForView:(UIScrollView *)contentView {
    typeof(self) __weak ws = self;
    __weak UIScrollView* __contentView = contentView;
    
    [super addObserverForHappyVMForView:contentView];
    
    [CCMNotifier(self.vm, gettingMore) makeRelation:__contentView withBlock:^(id value) {
        if (__contentView)
            [ws updateGetMoreStatus:[value boolValue] view:__contentView];
    }];
    
    [CCMNotifier(self.vm, hasMore) makeRelation:__contentView withBlock:^(id value) {
        [ws updateHasMoreStatus:[value boolValue] view:contentView];
    }];
}



#pragma mark init
-(instancetype)initWith:(HappyListVM *)vm collectionView:(UICollectionView *)collectionView{
    if (self =  [super initWith:vm collectionView:collectionView]) {
        typeof(self)__weak ws = self;
        [self updateHasMoreStatus:self.vm.hasMore view:collectionView];
        
        // TODO:@chj 用didScroll替代
        _collectionViewArray.willDisplayCellForItemAtIndexPath = ^(UICollectionView * _Nonnull collectionView, UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath,id _Nullable object) {
            if (indexPath.row > [collectionView numberOfItemsInSection:0]-preloadIndex && !ws.vm.gettingMore&&!ws.vm.refreshing) {
                [ws.vm getMore];
            }
        };
    }
    return self;
}

-(instancetype)initWith:(HappyListVM *)vm tableView:(UITableView *)tableView{
    if (self = [super initWith:vm tableView:tableView]) {
        __weak typeof(self) ws = self;
        [self updateHasMoreStatus:self.vm.hasMore view:tableView];

        // TODO:@chj 用didScroll替代
        _tableViewArray.willDisplayCellforRowAtIndexPath = ^(UITableView * _Nullable tableView, UITableViewCell * _Nullable cell, NSIndexPath * _Nullable indexPath,id _Nullable object) {
            if (tableView.contentOffset.y > tableView.contentSize.height-tableView.frame.size.height*1.3 && !ws.vm.gettingMore&&!ws.vm.refreshing) {
                [ws.vm getMore];
            }
            [ws.tableView sendSubviewToBack:ws.refreshHeaderView];
        };
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

        [self updateHasMoreStatus:self.vm.hasMore view:scrollView];
        [self updateGetMoreFrame];
        [self updateScrollViewInset];
        // TODO:@chj bug
        [_getMoreFooterView scrollOffset:scrollView.contentOffset.y + scrollView.contentSize.height + self.insert.bottom - scrollView.frame.size.height];
    }
}
-(UIView<ScrollGetMoreFooterProtocal>*)getMoreFooterView {
    if (_firstGetMore == NO) {
        _firstGetMore = YES;
        
        _getMoreFooterView = [self defaultGetMoreFooterView];
    }
    return _getMoreFooterView;
}

#pragma mark other
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView*)scrollView change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:scrollView change:change context:context];
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        [UIView setAnimationsEnabled:NO];
        [self updateGetMoreFrame];
        [UIView setAnimationsEnabled:YES];
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = scrollView.contentOffset;
        
        // get more
        // TODO:@chj bug
        [_getMoreFooterView scrollOffset:offset.y + scrollView.contentSize.height + self.insert.bottom - scrollView.frame.size.height];
        if (offset.y > scrollView.contentSize.height + self.insert.bottom - scrollView.frame.size.height + _getMoreFooterView.frame.size.height) {
            if (scrollView.isDragging != _isDraaging) {
                _isDraaging = scrollView.isDragging;
                if (scrollView.isDragging == NO) {
                    BOOL shouldTrigger = YES;
                    if (_getMoreFooterView.shouldTrigger) {
                        shouldTrigger = _getMoreFooterView.shouldTrigger();
                    }
                    if (shouldTrigger) {
                        [self.vm getMore];
                        _getMoreFooterView.gettingMore = self.vm.isGettingMore;
                    }
                }
            }
        }
    } else if ([keyPath isEqualToString:@"bounds"]) {
        [UIView setAnimationsEnabled:NO];
        [self updateGetMoreFrame];
        [UIView setAnimationsEnabled:YES];
    }
}
@end
#pragma clang diagnostic pop
