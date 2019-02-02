//
//  HappyListController.h
//  HappyMVVM
//
//  Created by Aruisi on 2017/8/1.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HappyMVVMProtocal.h"
#import "HappyController.h"

@class CollectionViewArray;
@class TableViewArray;
@class HappyListVM;

@interface HappyListController : HappyController
/**
 refresh callback
 */
@property (nonatomic, copy) void(^startRefresh)(void);
@property (nonatomic, copy) void(^didRefresh)(void);

/**
 get more callback
 */
@property (nonatomic, copy) void(^startGetMore)(void);
@property (nonatomic, copy) void(^didGetMore)(void);

/**
 error view
 */
@property (nonatomic, strong) UIView* _Nullable errorView;

/**
 loading from empty
 */
@property (nonatomic, strong) UIView* _Nullable loadingView;

/**
 empty view
 */
@property (nonatomic, strong) UIView* _Nullable emptyView;


@property (nonatomic, strong) UIView<ScrollRefreshHeaderProtocal>* _Nullable refreshHeaderView;
@property (nonatomic, strong) UIView<ScrollGetMoreFooterProtocal>* _Nullable getMoreFooterView;

#pragma clang diagnostic push
#pragma clang diagnostic ignored  "-Wincompatible-property-type"
@property (nonatomic, readonly) HappyListVM * _Nullable vm;
#pragma clang diagnostic pop

@property (nonatomic, readonly)  UICollectionView* _Nullable  collectionView;
@property (nonatomic, readonly)  UITableView* _Nullable  tableView;

//collectioView
-(instancetype _Nonnull )initWith:(HappyListVM*_Nonnull)vm collectionView:(UICollectionView*_Nonnull)collectionView;

//tableView
-(instancetype _Nonnull )initWith:(HappyListVM *_Nonnull)vm tableView:(UITableView *_Nonnull)tableView;

#pragma mark sub class
/**
 The sub class need to do as following
 1. set collectionView with a layout
 2. compute cell size
 3. register nib for collectionView, used to create cell
 4. implement cellForItem block
 5. handel cell click
 */
-(void)setUpCollectionView:(CollectionViewArray*_Nonnull)binder collectionView:(UICollectionView*_Nonnull)collectionView;

/**
 The sub class need to do as following
 1. compute cell height
 2. register nib for tableview, used to create cell
 3. implement cellForRow block
 4. handel cell click
 */
-(void)setUpTableView:(TableViewArray* _Nonnull)binder tableView:(UITableView* _Nonnull)tableView;

-(UIView<ScrollRefreshHeaderProtocal>* _Nullable)defaultRefreshHeaderView;
-(UIView<ScrollGetMoreFooterProtocal>* _Nullable)defaultGetMoreFooterView;
-(UIView* _Nullable)defaultEmptyView;
-(UIView* _Nullable)defaultErrorView;
-(UIView* _Nonnull)defaultLoadingView;

@end
