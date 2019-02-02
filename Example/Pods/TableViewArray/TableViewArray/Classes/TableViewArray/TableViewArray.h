//
//  TableViewArray.h
//  Pods
//
//  Created by aruisi on 2017/7/13.
//
//

#import <Foundation/Foundation.h>
@class TableViewArray;

#pragma mark  - the picker of array
typedef NSArray* (^subArray)(NSArray* all, NSInteger index);

void TableViewConnectArray(UITableView * _Nonnull tableview ,NSArray<NSObject*>* _Nullable dataSource,TableViewArray * _Nonnull listener);

#pragma mark  - dataSource
typedef NSInteger (^numberOfSectionsBlock)(UITableView *tableView);
typedef NSInteger (^numberOfRowsInSectionBlock)(UITableView *tableView, NSInteger section);
typedef id (^getItemBlock)(NSInteger section, NSInteger row);
typedef id (^getSectionBlock)(NSInteger section);

typedef UITableViewCell* _Nullable (^cellforRowBlock)(UITableView* _Nullable tableView, NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef NSArray <NSString*>*_Nullable(^sectionIndexTitlesBlock)(UITableView * _Nullable tableView);
typedef NSInteger(^sectionForSectionIndexTitleBlock)(UITableView * _Nullable tableView,NSString * _Nullable title,NSInteger index, id _Nullable object);
typedef NSString* _Nullable (^titleForHeaderBlock)(UITableView * _Nullable tableView,NSInteger section, id _Nullable object);
typedef NSString* _Nullable (^titleForFooterBlock)(UITableView * _Nullable tableView,NSInteger section, id _Nullable object);
#pragma mark - Inserting or Deleting table rows
typedef void(^commitEditingStyleBlock)(UITableView * _Nullable tableView, UITableViewCellEditingStyle  editingStyle, NSIndexPath *_Nullable indexPath, id _Nullable object);
typedef BOOL(^canEditRowBlock)(UITableView* _Nullable tableView, NSIndexPath *_Nullable indexPath, id _Nullable object);
#pragma mark  - Recording Table Rows
typedef BOOL(^canMoveRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^moveRowAtIndexPathBlock)(UITableView * _Nullable tableView, NSIndexPath * _Nullable sourceIndexPath, NSIndexPath *_Nullable destinationIndexPath);


#pragma ark  - Delegate
#pragma mark - select protocal
typedef NSIndexPath*_Nullable(^willSelectRowBlock)(UITableView * _Nullable tableView, NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^didSelectRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef NSIndexPath* _Nullable(^willDeselectRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^didDeselectRowBlock)(UITableView * _Nullable tableView, NSIndexPath * _Nullable indexPath, id _Nullable object);

#pragma mark - Configuring Rows for the Table View

typedef CGFloat(^heightForRowBlock)(UITableView * _Nullable tableView,NSIndexPath  * _Nullable indexPath, id _Nullable object);
typedef CGFloat(^estimatedHeightForRowBlock)(UITableView * _Nullable tableView,NSIndexPath  * _Nullable indexPath, id _Nullable object);
typedef NSInteger(^indentationLevelForRowBlock)(UITableView * _Nullable tableView,NSIndexPath *_Nullable indexPath, id _Nullable object);
typedef void(^willDisplayCellForRowBlock)(UITableView* _Nullable tableView,UITableViewCell * _Nullable cell,NSIndexPath * _Nullable indexPath, id _Nullable object);


#pragma mark - Managing Accessory Views

typedef NSArray<UITableViewRowAction*>*_Nullable(^editActionsForRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^accessoryButtonTappedForRowBlock)(UITableView * _Nullable tableview ,NSIndexPath * _Nullable indexPath, id _Nullable object);

#pragma mark - Modifying the Header and Footer of Sections

typedef UIView* _Nullable (^viewForHeaderBlock)(UITableView * _Nullable tableView, NSInteger section, id _Nullable object);
typedef UIView* _Nullable (^viewForFooterBlock)(UITableView * _Nullable tableView, NSInteger section, id _Nullable object);

typedef CGFloat(^heightForHeaderBlock)(UITableView * _Nullable tableView, NSInteger section, id _Nullable object);
typedef CGFloat(^heightForFooterBlock)(UITableView * _Nullable tableView, NSInteger section, id _Nullable object);

typedef CGFloat(^estimatedHeightForHeaderBlock)(UITableView * _Nullable tableView, NSInteger section, id _Nullable object);
typedef CGFloat(^estimatedHeightForFooterBlock)(UITableView * _Nullable tableView, NSInteger section, id _Nullable object);

typedef void(^willDisplayHeaderBlock)(UITableView * _Nullable tableView, UIView * _Nullable view ,NSInteger section, id _Nullable object);
typedef void(^willDisplayFooterBlock)(UITableView * _Nullable tableView, UIView * _Nullable view ,NSInteger section, id _Nullable object);



#pragma mark - Editing Table Rows

typedef void(^willBeginEditingRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^didEndEditingRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);

typedef UITableViewCellEditingStyle(^editingStyleForRowBlock)(UITableView * _Nullable tableView ,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef NSString*_Nullable(^titleForDeleteConfirmationButtonForRowBlock)(UITableView* _Nullable tableView, NSIndexPath * _Nullable indexPath, id _Nullable object);

typedef BOOL(^shouldIndentWhileEditingRowBlock)(UITableView* _Nullable tableView ,NSIndexPath * _Nullable indexPath, id _Nullable object);

#pragma mark - Reordering Table Rows

typedef NSIndexPath* _Nullable (^targetIndexPathForMoveFromRowAtIndexPathBlock)(UITableView* _Nullable tableView,NSIndexPath * _Nullable sourceIndexPath,NSIndexPath* _Nullable proposedDestinationIndexPath);

#pragma mark  - Tracking the Removal of Views
typedef void(^didEndDisplayingCellBlock)(UITableView * _Nullable tableView,UITableViewCell* _Nullable cell ,NSIndexPath * _Nullable indexPath ,id _Nullable object);
typedef void(^didEndDisplayingHeaderViewBlock)(UITableView * _Nullable tableView ,UIView* _Nullable view ,NSInteger  section, id _Nullable object);
typedef void(^didEndDisplayingFooterViewBlock)(UITableView * _Nullable tableView ,UIView* _Nullable view ,NSInteger  section, id _Nullable object);

#pragma mark - Copying and Pasting Row content

typedef BOOL(^shouldShowMenuForRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef BOOL(^canPerformActionForRowBlock)(UITableView* _Nullable tableView ,SEL _Nullable action, NSIndexPath * _Nullable indexPath, id _Nullable sender);
typedef void(^performActionForRowBlock)(UITableView * _Nullable tableView,SEL _Nullable action,NSIndexPath * _Nullable indexPath,id _Nullable sender);

#pragma mark - Managing Table View Highlighting

typedef BOOL(^shouldHighlightRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^didHighlightRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef void(^didUnhighlightRowBlock)(UITableView * _Nullable tableView,NSIndexPath * _Nullable indexPath, id _Nullable object);

#pragma mark - Managing Table View Focus

typedef BOOL(^canFocusRowBlock)(UITableView* _Nullable tableview,NSIndexPath * _Nullable indexPath, id _Nullable object);
typedef BOOL(^shouldUpdateFocusBlock)(UITableView* _Nullable tableView, UITableViewFocusUpdateContext * _Nullable context) NS_AVAILABLE_IOS(9_0);
typedef void(^didUpdateFocusBlock)(UITableView* _Nullable tableView ,UITableViewFocusUpdateContext * _Nullable context,UIFocusAnimationCoordinator* _Nullable coordinator) NS_AVAILABLE_IOS(9_0);
typedef NSIndexPath*_Nullable(^indexPathForPreferredFocusedViewBlock)(UITableView * _Nullable tableView);


#pragma mark  - prefetchDataSource

typedef void(^prefetchRowsBlock)(UITableView* _Nullable tableView,NSArray<NSIndexPath*>* _Nullable indexPaths);
typedef void(^cancelPrefetchingForRowsBlock)(UITableView* _Nullable tableView,NSArray<NSIndexPath*>* _Nullable indexPaths);

@interface TableViewArray : NSObject
@property(nonatomic, assign) BOOL disableAnimation;
@property(nonatomic,copy,nullable) subArray subArray;

#pragma mark  - dataSource
// conflits with auto lisntener array. If implements these block, the TableView is auto connect with virtul data. can not be listener
@property(nonatomic,copy,nullable) numberOfSectionsBlock numberOfSections;
@property(nonatomic,copy,nullable) numberOfRowsInSectionBlock numberOfRowsInSection;
@property(nonatomic,copy,nullable) getItemBlock getItem;
@property(nonatomic,copy,nullable) getSectionBlock getSection;

@property(nonatomic,copy,nonnull) cellforRowBlock   cellForRowAtIndexPath;
@property(nonatomic,copy,nonnull) sectionIndexTitlesBlock  sectionIndexTitlesForTableView;
@property(nonatomic,copy,nonnull) sectionForSectionIndexTitleBlock  sectionForSectionIndexTitleAtIndex;

@property(nonatomic,copy,nonnull) titleForHeaderBlock  titleForHeaderInSection;
@property(nonatomic,copy,nonnull) titleForFooterBlock  titleForFooterInSection;
@property(nonatomic,copy,nonnull) commitEditingStyleBlock  commitEditingStyleForRowAtIndexPath;

@property(nonatomic,copy,nonnull) canEditRowBlock  canEditRowAtIndexPath;
@property(nonatomic,copy,nonnull) canMoveRowBlock  canMoveRowAtIndexPath;
@property(nonatomic,copy,nonnull) moveRowAtIndexPathBlock  moveRowAtIndexPathToIndexPath;

#pragma mark - Delegate
#pragma mark - Managing Selections
@property(nonatomic,copy,nonnull) willSelectRowBlock willSelectRowAtIndexPath;
@property(nonatomic,copy,nonnull) didSelectRowBlock didSelectRowAtIndexPath;
@property(nonatomic,copy,nonnull) willDeselectRowBlock willDeselectRowAtIndexPath;
@property(nonatomic,copy,nonnull) didDeselectRowBlock didDeselectRowAtIndexPath;

#pragma mark - Configuring Rows for the Table View
@property(nonatomic,copy,nonnull) heightForRowBlock  heightForRowAtIndexPath;
@property(nonatomic,copy,nonnull) estimatedHeightForRowBlock estimatedHeightForRowAtIndexPath;
@property(nonatomic,copy,nonnull) indentationLevelForRowBlock indentationLevelForRowAtIndexPath;
@property(nonatomic,copy,nonnull) willDisplayCellForRowBlock willDisplayCellforRowAtIndexPath;

#pragma mark  - Managing Accessory Views
@property(nonatomic,copy,nonnull) editActionsForRowBlock editActionsForRowAtIndexPath;
@property(nonatomic,copy,nonnull) accessoryButtonTappedForRowBlock accessoryButtonTappedForRowWithIndexPath;

#pragma mark - Modifying the Header and Footer of Sections
@property(nonatomic,copy,nonnull) viewForHeaderBlock viewForHeaderInSection;
@property(nonatomic,copy,nonnull) viewForFooterBlock viewForFooterInSection;

@property(nonatomic,copy,nonnull) heightForHeaderBlock heightForHeaderInSection;
@property(nonatomic,copy,nonnull) heightForFooterBlock heightForFooterInSection;

@property(nonatomic,copy,nonnull) estimatedHeightForHeaderBlock estimatedHeightForHeaderInSection;
@property(nonatomic,copy,nonnull) estimatedHeightForFooterBlock estimatedHeightForFooterInSection;

@property(nonatomic,copy,nonnull) willDisplayHeaderBlock willDisplayHeaderViewForSection;
@property(nonatomic,copy,nonnull) willDisplayFooterBlock willDisplayFooterViewForSection;

#pragma mark - Editing Table Rows
@property(nonatomic,copy,nonnull) willBeginEditingRowBlock  willBeginEditingRowAtIndexPath;
@property(nonatomic,copy,nonnull) didEndEditingRowBlock didEndEditingRowAtIndexPath ;
@property(nonatomic,copy,nonnull) editingStyleForRowBlock editingStyleForRowAtIndexPath;

@property(nonatomic,copy,nonnull) titleForDeleteConfirmationButtonForRowBlock titleForDeleteConfirmationButtonForRowAtIndexPath;
@property(nonatomic,copy,nonnull) shouldIndentWhileEditingRowBlock shouldIndentWhileEditingRowAtIndexPath ;

#pragma mark - Reordering Table Rows
@property(nonatomic,copy,nonnull) targetIndexPathForMoveFromRowAtIndexPathBlock targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath;

#pragma mark  - Tracking The Removal of Views
@property(nonatomic,copy,nonnull) didEndDisplayingCellBlock didEndDisplayingCellForRowAtIndexPath;
@property(nonatomic,copy,nonnull) didEndDisplayingHeaderViewBlock didEndDisplayingHeaderViewForSection;
@property(nonatomic,copy,nonnull) didEndDisplayingFooterViewBlock didEndDisplayingFooterViewForSection;

#pragma mark - Copying and Pasting Row content
@property(nonatomic,copy,nonnull) shouldShowMenuForRowBlock  shouldShowMenuForRowAtIndexPath;
@property(nonatomic,copy,nonnull) canPerformActionForRowBlock  canPerformActionForRowAtIndexPath;
@property(nonatomic,copy,nonnull) performActionForRowBlock  performActionForRowAtIndexPath;

#pragma mark  - Managing TableView Highlighting
@property(nonatomic,copy,nonnull) shouldHighlightRowBlock  shouldHighlightRowAtIndexPath;
@property(nonatomic,copy,nonnull) didHighlightRowBlock  didHighlightRowAtIndexPath;
@property(nonatomic,copy,nonnull) didUnhighlightRowBlock  didUnhighlightRowAtIndexPath;

#pragma mark - Managing Table View Focus
@property(nonatomic,copy,nonnull) canFocusRowBlock  canFocusRowAtIndexPath;
@property(nonatomic,copy,nonnull) shouldUpdateFocusBlock  shouldUpdateFocusInContext NS_AVAILABLE_IOS(9_0);
@property(nonatomic,copy,nonnull) didUpdateFocusBlock  didUpdateFocusInContextWithAnimationCoodinator NS_AVAILABLE_IOS(9_0);
@property(nonatomic,copy,nonnull) indexPathForPreferredFocusedViewBlock  indexPathForPreferredFocusedViewInTableView;


#pragma mark - prefetching 
@property(nonatomic,copy,nonnull) prefetchRowsBlock  prefetchRowsAtIndexPaths NS_AVAILABLE_IOS(10_0);
@property(nonatomic,copy,nonnull) cancelPrefetchingForRowsBlock  cancelPrefetchingForRowsAtIndexPaths NS_AVAILABLE_IOS(10_0);

#pragma mark  - UIScrollViewDelegate
@property(nonatomic,copy,nonnull) void (^scrollViewDidScroll)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewDidZoom)(UIScrollView *  _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewWillBeginDragging)(UIScrollView *  _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewWillEndDragging)(UIScrollView * _Nonnull scrollView ,CGPoint velocity , CGPoint * _Nullable targetContentOffset)NS_AVAILABLE_IOS(5_0);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndDragging)(UIScrollView * _Nonnull scrollView, BOOL decelerate);
@property(nonatomic,copy,nonnull) void (^scrollViewWillBeginDecelerating)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndDecelerating)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndScrollingAnimation)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) UIView * _Nullable (^viewForZoomingInScrollView)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) void (^scrollViewWillBeginZooming)(UIScrollView * _Nonnull scrollView, UIView * _Nonnull view)NS_AVAILABLE_IOS(3_2);
@property(nonatomic,copy,nonnull) void (^scrollViewDidEndZooming)(UIScrollView * _Nonnull scrollView, UIView* _Nullable view ,CGFloat scale);
@property(nonatomic,copy,nonnull) BOOL (^scrollViewShouldScrollToTop)(UIScrollView * _Nonnull scrollView);
@property(nonatomic,copy,nonnull) BOOL (^scrollViewDidScrollToTop)(UIScrollView *  _Nonnull ScrollView);
@property(nonatomic,copy,nonnull) BOOL (^scrollViewDidChangeAdjustedContentInset)(UIScrollView* _Nonnull scrollView)API_AVAILABLE(ios(11.0), tvos(11.0));

@end

@interface UITableView (TableViewArray)

@property (nonatomic, strong) TableViewArray *tv_tableViewArray;

@property (nonatomic, strong) NSArray<NSObject*> *tv_dataSource;

@end

