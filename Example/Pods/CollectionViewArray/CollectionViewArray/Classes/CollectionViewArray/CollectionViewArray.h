//
//  CollectionViewArray.h
//  Pods
//
//  Created by aruisi on 2017/7/19.
//
//

#import <Foundation/Foundation.h>

@class CollectionViewArray;

#pragma mark  - the picker of array
typedef NSArray* (^subArray)(NSArray* all, NSInteger index);

void CollectionViewConnectArray(UICollectionView * _Nonnull collectionView ,NSArray<NSObject*>* _Nullable dataSource,CollectionViewArray * _Nonnull listener);

#pragma mark  - CollectionView DataSource
typedef NSInteger (^numberOfGroupsBlock)(UICollectionView *collectionView);
typedef NSInteger (^numberOfRowsInGroupBlock)(UICollectionView *collectionView, NSInteger section);
typedef id (^getItemBlock)(NSInteger section, NSInteger row);
typedef id (^getSectionBlock)(NSInteger section);

typedef __kindof UICollectionViewCell * _Nonnull (^cellForItemBlock)(UICollectionView* _Nonnull collectionView,NSIndexPath * _Nonnull indexPath,id _Nullable object);

typedef UICollectionReusableView*_Nonnull(^viewForSupplementaryElementOfKindBlock)(UICollectionView * _Nonnull collectionView,NSString * _Nonnull kind ,NSIndexPath * _Nonnull indexPath,id _Nullable object);

/* Reordering Items */
typedef BOOL(^canMoveItemBlock)(UICollectionView* _Nonnull collectionView,NSIndexPath* _Nonnull indexPath,id _Nullable object);
typedef void(^moveItemAtIndexPathBlock)(UICollectionView* _Nonnull collectionView,NSIndexPath* _Nonnull sourceIndexPath,NSIndexPath* _Nonnull destinationIndexPath);

/* Instance Methods */
typedef NSIndexPath*_Nonnull(^indexPathForIndexTitleBlock)(UICollectionView* _Nonnull collectionView,NSString * _Nonnull title,NSInteger index);
typedef NSArray<NSString*>* _Nonnull (^indexTitlesBlock)(UICollectionView* _Nonnull collectionView);

#pragma mark  - CollectionView DeleteGate
/* CollectionView DeleteGate protocal  block */
/*Managing the selected cells */
typedef BOOL(^shouldSelectItemBlock)(UICollectionView * _Nonnull collectionView ,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef void(^didSelectItemBlock)(UICollectionView* _Nonnull collectionView,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef BOOL(^shouldDeselectItemBlock)(UICollectionView* _Nonnull collectionView ,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef void(^didDeselectItemBlock)(UICollectionView * _Nonnull collectionView,NSIndexPath * _Nonnull indexPath,id _Nullable object);

/*Mananing cell Highting */
typedef BOOL(^shouldHiglightItemBlock)(UICollectionView * _Nonnull collectionView,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef void(^didHighlightItemBlock)(UICollectionView * _Nonnull collectionView ,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef void(^didUnhighlightItemBlock)(UICollectionView *_Nonnull collectionView,NSIndexPath *_Nonnull indexPath,id _Nullable object);

/*Tracking the addition adn removal of views*/
typedef void(^willDisplayCellForItemBlock)(UICollectionView* _Nonnull collectionView,UICollectionViewCell* _Nonnull cell ,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef void(^wilDisplaySupplementaryViewForElementKindBlock)(UICollectionView* _Nonnull collectionView,UICollectionReusableView*_Nonnull view,NSString* _Nonnull elementKind,NSIndexPath* _Nonnull indexPath,id _Nullable object);
typedef void(^didEndDisplayingCellForItemBlock)(UICollectionView * _Nonnull collectionView,UICollectionViewCell* _Nonnull cell,NSIndexPath * _Nonnull indexPath,id _Nullable object);
typedef void(^didEndDisplayingSupplementaryViewForElementKindBlock)(UICollectionView * _Nonnull collectionView,UICollectionReusableView*_Nonnull view,NSString* _Nonnull elementKind,NSIndexPath *_Nonnull indexPath,id _Nullable object);

/*Handing layout Changes*/
typedef UICollectionViewTransitionLayout*_Nonnull(^transitionLayoutForOldLayoutBlock)(UICollectionView * _Nonnull collectionView,UICollectionViewLayout* _Nonnull fromLayout,UICollectionViewLayout * _Nonnull toLayout);
typedef CGPoint(^targetContentOffsetForProposedContentOffsetBlock)(UICollectionView *_Nonnull collectionView,CGPoint  proposedContentOffset);
typedef NSIndexPath*_Nonnull(^targetIndexPathForMoveFromItemAtIndexPathBlock)(UICollectionView * _Nonnull collectionView,NSIndexPath *_Nonnull originalIndexPath,NSIndexPath*_Nonnull proposedIndexPath);

/*manaing actions of Cells*/
typedef BOOL(^shouldShowMenuForItemBlock)(UICollectionView *_Nonnull collectionView,NSIndexPath *_Nonnull indexPath,id _Nullable object);
typedef BOOL(^canPerformActionForItemBlock)(UICollectionView * _Nonnull collectionView,SEL _Nonnull action,NSIndexPath*_Nonnull indexPath,id _Nonnull sender,id _Nullable object);
typedef void(^performActionForItemBlock)(UICollectionView * _Nonnull collectionView,SEL _Nonnull action,NSIndexPath*_Nonnull indexPath,id _Nonnull sender,id _Nullable object);

/*Managing focus in a Collection view*/
typedef BOOL(^canFocusItemBlock)(UICollectionView *_Nonnull collectionView,NSIndexPath *_Nonnull indexPath,id _Nullable object);
typedef NSIndexPath*_Nonnull(^indexPathForPreferredFocusedViewInCollectionView)(UICollectionView *_Nonnull collectionView);
typedef BOOL(^shouldUpdateFocusInContextBlock)(UICollectionView* _Nonnull collectionView,UICollectionViewFocusUpdateContext *_Nonnull context)NS_AVAILABLE_IOS(9_0);
typedef void(^didUpdateFocusInContextBlock)(UICollectionView* _Nonnull collectionView,UICollectionViewFocusUpdateContext *_Nonnull context,UIFocusAnimationCoordinator *_Nonnull coordinator)NS_AVAILABLE_IOS(9_0);

#pragma mark  - CollectionView Delegate Flowlayout
/* CollectionView Delegate Flowlayout protocal block*/
/*Getting the Size of Items*/
typedef CGSize(^layoutSizeForItemBlock)(UICollectionView* _Nonnull collectionView,UICollectionViewLayout*_Nonnull collectionViewLayout,NSIndexPath*_Nonnull indexPath,id _Nullable object);

/* Getting the Section Spacing */
typedef UIEdgeInsets(^layoutInsetForSectionBlock)(UICollectionView*_Nonnull collectionView,UICollectionViewLayout* _Nonnull collectionViewLayout,NSInteger section,id _Nullable object);
typedef CGFloat(^layoutminimumLineSpacingForSectionBlock)(UICollectionView*_Nonnull collectionView,UICollectionViewLayout* _Nonnull collectionViewLayout,NSInteger section,id _Nullable object);
typedef CGFloat(^layoutminimumInteritemSpacingForSectionBlock)(UICollectionView*_Nonnull collectionView,UICollectionViewLayout* _Nonnull collectionViewLayout,NSInteger section,id _Nullable object);

/*Getting the Header and Footer Sizes*/
typedef CGSize(^layoutReferenceSizeForHeaderBlock)(UICollectionView*_Nonnull collectionView,UICollectionViewLayout* _Nonnull collectionViewLayout,NSInteger section,id _Nullable object);
typedef CGSize(^layoutReferenceSizeForFooterBlock)(UICollectionView*_Nonnull collectionView,UICollectionViewLayout* _Nonnull collectionViewLayout,NSInteger section,id _Nullable object);


#pragma mark  - UICollecionViewDataSourcePrefectching
/* UICollecionView DataSource Prefectching protocal block*/
/*Managing Data Prefetching*/
typedef void(^prefetchItemsBlock)(UICollectionView* _Nonnull collectionView,NSArray<NSIndexPath*>* _Nonnull indexPaths);
typedef void(^cancelPrefetchingForItemsBlock)(UICollectionView* _Nonnull collectionView,NSArray<NSIndexPath*>* _Nonnull indexPaths);

@interface CollectionViewArray : NSObject
@property(nonatomic,copy,nullable) subArray subArray;


#pragma mark  - CollectionView DataSource
// conflits with auto lisntener array. If implements these block, the TableView is auto connect with virtul data. can not be listener
@property(nonatomic,copy,nullable) numberOfGroupsBlock numberOfGroups;
@property(nonatomic,copy,nullable) numberOfRowsInGroupBlock numberOfRowsInGroup;
@property(nonatomic,copy,nullable) getItemBlock getItem;
@property(nonatomic,copy,nullable) getSectionBlock getSection;

/* CollectionView DataSource protocal block*/
/* Getting Views for Items */
@property(nonatomic,copy,nonnull) cellForItemBlock  cellForItemAtIndexPath;
@property(nonatomic,copy,nonnull) viewForSupplementaryElementOfKindBlock  viewForSupplementaryElementOfKindatIndexPath;

/* Reordering Items */
@property(nonatomic,copy,nonnull) canMoveItemBlock  canMoveItemAtIndexPath;
@property(nonatomic,copy,nonnull) moveItemAtIndexPathBlock  moveItemAtIndexPathtoIndexPath;

/* Instance Methods */
@property(nonatomic,copy,nonnull) indexPathForIndexTitleBlock  indexPathForIndexTitleAtIndex;
@property(nonatomic,copy,nonnull) indexTitlesBlock  indexTitlesForCollectionView;

#pragma mark  - CollectionView DeleteGate
/* CollectionView DeleteGate protocal block */
/*Managing the selected cells */
@property(nonatomic,copy,nonnull) shouldSelectItemBlock  shouldSelectItemAtIndexPath;
@property(nonatomic,copy,nonnull) didSelectItemBlock  didSelectItemAtIndexPath;
@property(nonatomic,copy,nonnull) shouldDeselectItemBlock  shouldDeselectItemAtIndexPath;
@property(nonatomic,copy,nonnull) didDeselectItemBlock  didDeselectItemAtIndexPath;

/*Mananing cell Highting */
@property(nonatomic,copy,nonnull) shouldHiglightItemBlock  shouldHighlightItemAtIndexPath;
@property(nonatomic,copy,nonnull) didHighlightItemBlock  didHighlightItemAtIndexPath;
@property(nonatomic,copy,nonnull) didUnhighlightItemBlock  didUnhighlightItemAtIndexPath;

/*Tracking the addition adn removal of views*/
@property(nonatomic,copy,nonnull) willDisplayCellForItemBlock  willDisplayCellForItemAtIndexPath;
@property(nonatomic,copy,nonnull) wilDisplaySupplementaryViewForElementKindBlock  wilDisplaySupplementaryViewForElementKindAtIndexPath;
@property(nonatomic,copy,nonnull) didEndDisplayingCellForItemBlock  didEndDisplayingCellForItemAtIndexPath;
@property(nonatomic,copy,nonnull) didEndDisplayingSupplementaryViewForElementKindBlock  didEndDisplayingSupplementaryViewForElementKindAtIndexPath;

/*Handing layout Changes*/
@property(nonatomic,copy,nonnull) transitionLayoutForOldLayoutBlock  transitionLayoutForOldLayoutWithNewLayout;
@property(nonatomic,copy,nonnull) targetContentOffsetForProposedContentOffsetBlock  targetContentOffsetForProposedContentOffset;
@property(nonatomic,copy,nonnull) targetIndexPathForMoveFromItemAtIndexPathBlock  targetIndexPathForMoveFromItemAtIndexPathToProposedIndexPath;

/*manaing actions of Cells*/
@property(nonatomic,copy,nonnull) shouldShowMenuForItemBlock  shouldShowMenuForItemAtIndexPath;
@property(nonatomic,copy,nonnull) canPerformActionForItemBlock  canPerformActionForItemAtIndexPath;
@property(nonatomic,copy,nonnull) performActionForItemBlock  performActionForItemAtIndexPath;

/*Managing focus in a Collection view*/
@property(nonatomic,copy,nonnull) canFocusItemBlock  canFocusItemAtIndexPath;
@property(nonatomic,copy,nonnull) indexPathForPreferredFocusedViewInCollectionView  indexPathForPreferredFocusedViewInCollectionView;
@property(nonatomic,copy,nonnull) shouldUpdateFocusInContextBlock  shouldUpdateFocusInContext NS_AVAILABLE_IOS(9_0);
@property(nonatomic,copy,nonnull) didUpdateFocusInContextBlock  didUpdateFocusInContextWithAnimationCoordinator NS_AVAILABLE_IOS(9_0);

#pragma mark  - CollectionView Delegate Flowlayout
/* CollectionView Delegate Flowlayout protocal block*/
/* Getting the Section Spacing */
@property(nonatomic,copy,nonnull) layoutSizeForItemBlock  sizeForItemAtIndexPath;

/*Getting the Header and Footer Sizes*/
@property(nonatomic,copy,nonnull) layoutInsetForSectionBlock  layoutInsetForSectionAtIndex;
@property(nonatomic,copy,nonnull) layoutminimumLineSpacingForSectionBlock  minimumLineSpacingForSectionAtIndex;
@property(nonatomic,copy,nonnull) layoutminimumInteritemSpacingForSectionBlock  minimumInteritemSpacingForSectionAtIndex;

/*Getting the Size of Items*/
@property(nonatomic,copy,nonnull) layoutReferenceSizeForHeaderBlock  layoutReferenceSizeForHeaderInSection;
@property(nonatomic,copy,nonnull) layoutReferenceSizeForFooterBlock  layoutReferenceSizeForFooterInSection;


#pragma mark  - UICollecionViewDataSourcePrefectching
/* UICollecionView DataSource Prefectching protocal block*/
@property(nonatomic,copy,nonnull) prefetchItemsBlock  prefetchItemsAtIndexPaths;
@property(nonatomic,copy,nonnull) cancelPrefetchingForItemsBlock  cancelPrefetchingForItemsAtIndexPaths;

#pragma mark  - UIScrollViewDelegate
@property(nonatomic,copy,nonnull) void (^scrollViewDidScroll)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewDidZoom)(UIScrollView *  _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewWillBeginDragging)(UIScrollView *  _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewWillEndDragging)(UIScrollView * scrollView ,CGPoint velocity , CGPoint * targetContentOffset)NS_AVAILABLE_IOS(5_0);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndDragging)(UIScrollView * scrollView, BOOL decelerate);
@property(nonatomic,copy,nonnull) void (^scrollViewWillBeginDecelerating)(UIScrollView * scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndDecelerating)(UIScrollView * scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndScrollingAnimation)(UIScrollView * scrollView);
@property(nonatomic,copy,nonnull) UIView * _Nullable (^viewForZoomingInScrollView)(UIScrollView * scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewWillBeginZooming)(UIScrollView * scrollView, UIView * view)NS_AVAILABLE_IOS(3_2);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndZooming)(UIScrollView * scrollView, UIView* _Nullable view ,CGFloat scale);
@property(nonatomic,copy,nonnull) BOOL (^scrollViewShouldScrollToTop)(UIScrollView * scrollView);
@property(nonatomic,copy,nonnull) BOOL (^scrollViewDidScrollToTop)(UIScrollView * ScrollView);
@property(nonatomic,copy,nonnull) BOOL (^scrollViewDidChangeAdjustedContentInset)(UIScrollView* scrollView)API_AVAILABLE(ios(11.0), tvos(11.0));

@end

@interface UICollectionView (CollectionViewArray)

@property (nonatomic, strong) CollectionViewArray *cv_collectionViewArray;

@property (nonatomic, strong) NSArray<NSObject*> *cv_dataSource;

@end
