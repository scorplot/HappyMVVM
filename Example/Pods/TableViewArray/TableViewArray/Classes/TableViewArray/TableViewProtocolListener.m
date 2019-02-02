//
//  TableViewProtocolListener.m
//  Pods
//
//  Created by aruisi on 2017/7/13.
//
//

#import "TableViewProtocolListener.h"
#import <objc/runtime.h>
#import "NSMutableArray+Listener.h"
#import "CircleReferenceCheck.h"
#import <objc/runtime.h>

#pragma mark  - prefecthing

@interface TableViewProtocolListener ()
@property(nonatomic,strong)NSMutableArray * observerArray;
@property(nonatomic,weak)id<UITableViewDelegate>delegate;
@end

typedef void (*setDelegate_IMP)(id self,SEL _cmd ,id delegate);
static setDelegate_IMP origin_setDelegate_IMP = nil;
static void replace_setDelegate_IMP(id self,SEL _cmd ,id delegate){
    if ([self isKindOfClass:[UITableView class]]) {
        if (!delegate) {
            origin_setDelegate_IMP(self, _cmd, delegate);
            return;
        }
        id<UITableViewDelegate> tableDelegate = [self delegate];
        if ([delegate isKindOfClass:[TableViewProtocolListener class]]) {
            [(TableViewProtocolListener*)delegate setDelegate:tableDelegate];
            origin_setDelegate_IMP(self, _cmd, delegate);
        } else if ([tableDelegate isKindOfClass:[TableViewProtocolListener class]]) {
            [(TableViewProtocolListener*)tableDelegate setDelegate:delegate];
            if (delegate == nil) {
                origin_setDelegate_IMP(self, _cmd, nil);
            }
        } else {
            origin_setDelegate_IMP(self, _cmd, delegate);
        }
    } else {
        origin_setDelegate_IMP(self, _cmd, delegate);
    }
}

static void* keyArrayIndex;
static void setArrayIndex(NSArray* arr, NSInteger index) {
    objc_setAssociatedObject(arr, &keyArrayIndex, @(index), OBJC_ASSOCIATION_RETAIN);
}
static NSInteger getArrayIndex(NSArray* arr) {
    NSNumber* number = objc_getAssociatedObject(arr, &keyArrayIndex);
    if (number) {
        return [number integerValue];
    }
    return NSNotFound;
}


@implementation TableViewProtocolListener {
    BOOL _fakeArray;
}
+(void)load {
    Method method;
    method = class_getInstanceMethod([UITableView class], @selector(setDelegate:));
    origin_setDelegate_IMP =(setDelegate_IMP)method_setImplementation(method, (IMP)replace_setDelegate_IMP);
}

-(void)dealloc {
    
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(tableView:willSelectRowAtIndexPath:)&& !_listener.willSelectRowAtIndexPath) {
        return NO;
    }
    if (aSelector == @selector(tableView:didSelectRowAtIndexPath:)&& !_listener.didSelectRowAtIndexPath) {
        return NO;
    }
    if (aSelector == @selector(tableView:willDeselectRowAtIndexPath:)&& !_listener.willDeselectRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didDeselectRowAtIndexPath:))&& !_listener.didDeselectRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:heightForRowAtIndexPath:))&& !_listener.heightForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:estimatedHeightForRowAtIndexPath:))&& !_listener.estimatedHeightForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:indentationLevelForRowAtIndexPath:))&& !_listener.indentationLevelForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:willDisplayCell:forRowAtIndexPath:))&& !_listener.willDisplayCellforRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:editActionsForRowAtIndexPath:))&& !_listener.editActionsForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:accessoryButtonTappedForRowWithIndexPath:))&& !_listener.accessoryButtonTappedForRowWithIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:viewForHeaderInSection:))&& !_listener.viewForHeaderInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:viewForFooterInSection:))&& !_listener.viewForFooterInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:heightForHeaderInSection:))&& !_listener.heightForHeaderInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:heightForFooterInSection:))&& !_listener.heightForFooterInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:estimatedHeightForHeaderInSection:))&& !_listener.estimatedHeightForHeaderInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:estimatedHeightForFooterInSection:))&& !_listener.estimatedHeightForFooterInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:willDisplayHeaderView:forSection:))&& !_listener.willDisplayHeaderViewForSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:willDisplayFooterView:forSection:))&& !_listener.willDisplayFooterViewForSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:willBeginEditingRowAtIndexPath:))&& !_listener.willBeginEditingRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didEndEditingRowAtIndexPath:))&& !_listener.didEndEditingRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:editingStyleForRowAtIndexPath:))&& !_listener.editingStyleForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:))&& !_listener.titleForDeleteConfirmationButtonForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:shouldIndentWhileEditingRowAtIndexPath:))&& !_listener.shouldIndentWhileEditingRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:))&& !_listener.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didEndDisplayingCell:forRowAtIndexPath:))&& !_listener.didEndDisplayingCellForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didEndDisplayingHeaderView:forSection:))&& !_listener.didEndDisplayingHeaderViewForSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didEndDisplayingFooterView:forSection:))&& !_listener.didEndDisplayingFooterViewForSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:shouldShowMenuForRowAtIndexPath:))&& !_listener.shouldShowMenuForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:canPerformAction:forRowAtIndexPath:withSender:))&& !_listener.canPerformActionForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:performAction:forRowAtIndexPath:withSender:))&& !_listener.performActionForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:shouldHighlightRowAtIndexPath:))&& !_listener.shouldHighlightRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didHighlightRowAtIndexPath:))&& !_listener.didHighlightRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:didUnhighlightRowAtIndexPath:))&& !_listener.didUnhighlightRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:canFocusRowAtIndexPath:))&& !_listener.canFocusRowAtIndexPath) {
        return NO;
    }
    if (@available(iOS 9_0, *)) {
        if (sel_isEqual(aSelector, @selector(tableView:shouldUpdateFocusInContext:))&& !_listener.shouldUpdateFocusInContext) {
            return NO;
        }
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 9_0, *)) {
        if (sel_isEqual(aSelector, @selector(tableView:didUpdateFocusInContext:withAnimationCoordinator:))&& !_listener.didUpdateFocusInContextWithAnimationCoodinator) {
            return NO;
        }
    } else {
        // Fallback on earlier versions
    }
    if (sel_isEqual(aSelector, @selector(indexPathForPreferredFocusedViewInTableView:))&& !_listener.indexPathForPreferredFocusedViewInTableView) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(sectionIndexTitlesForTableView:))&& !_listener.sectionIndexTitlesForTableView) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:sectionForSectionIndexTitle:atIndex:))&& !_listener.sectionForSectionIndexTitleAtIndex) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:titleForHeaderInSection:))&& !_listener.titleForHeaderInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:titleForFooterInSection:))&& !_listener.titleForFooterInSection) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:commitEditingStyle:forRowAtIndexPath:))&& !_listener.commitEditingStyleForRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:canEditRowAtIndexPath:))&& !_listener.canEditRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:canMoveRowAtIndexPath:))&& !_listener.canMoveRowAtIndexPath) {
        return NO;
    }
    if (sel_isEqual(aSelector, @selector(tableView:moveRowAtIndexPath:toIndexPath:))&& !_listener.moveRowAtIndexPathToIndexPath) {
        return NO;
    }
    if (@available(iOS 10_0, *)) {
        if (sel_isEqual(aSelector, @selector(tableView:prefetchRowsAtIndexPaths:))&& !_listener.prefetchRowsAtIndexPaths) {
            return NO;
        }
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 10_0, *)) {
        if (sel_isEqual(aSelector, @selector(tableView:cancelPrefetchingForRowsAtIndexPaths:))&& !_listener.cancelPrefetchingForRowsAtIndexPaths) {
            return NO;
        }
    } else {
        // Fallback on earlier versions
    }
    
    return [super respondsToSelector:aSelector];
}

-(id)getObject:(NSIndexPath*)indexPath {
    id object = nil;
    if (_fakeArray) {
        object = _listener.getItem(indexPath.section, indexPath.row);
    } else {
        if (self.listener.subArray) {
            object = self.listener.subArray(_dataSource, indexPath.section)[indexPath.row];
        } else {
            object = _dataSource[indexPath.row];
        }
    }
    return object;
}
-(id)getSection:(NSUInteger)section {
    id object = nil;
    if (_fakeArray) {
        object = _listener.getSection(section);
    } else {
        if (self.listener.subArray) {
            object = _dataSource[section];
        } else {
            object = _dataSource;
        }
    }
    return object;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.willSelectRowAtIndexPath(tableView, indexPath, [self getObject:indexPath]);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    return  self.listener.willDeselectRowAtIndexPath(tableView, indexPath, [self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.didSelectRowAtIndexPath(tableView, indexPath, [self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.didDeselectRowAtIndexPath(tableView, indexPath, [self getObject:indexPath]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.heightForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.estimatedHeightForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.indentationLevelForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.willDisplayCellforRowAtIndexPath(tableView, cell, indexPath,[self getObject:indexPath]);
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.editActionsForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    self.listener.accessoryButtonTappedForRowWithIndexPath(tableView, indexPath,[self getObject:indexPath]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return  self.listener.viewForHeaderInSection(tableView,section,[self getSection:section]);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.listener.viewForFooterInSection(tableView,section,[self getSection:section]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.listener.heightForHeaderInSection(tableView,section,[self getSection:section]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.listener.heightForFooterInSection(tableView,section,[self getSection:section]);
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return self.listener.estimatedHeightForHeaderInSection(tableView,section,[self getSection:section]);
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return self.listener.estimatedHeightForFooterInSection(tableView,section,[self getSection:section]);
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    self.listener.willDisplayHeaderViewForSection(tableView, view, section,[self getSection:section]);
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    self.listener.willDisplayFooterViewForSection(tableView, view, section,[self getSection:section]);
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.willBeginEditingRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.didEndEditingRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.editingStyleForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.titleForDeleteConfirmationButtonForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.shouldIndentWhileEditingRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

#pragma mark - Reordering Table Rows

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return self.listener.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath(tableView,sourceIndexPath,proposedDestinationIndexPath);
}

#pragma mark - Tacking the Removal of Views

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.didEndDisplayingCellForRowAtIndexPath(tableView,cell,indexPath,[self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    self.listener.didEndDisplayingHeaderViewForSection(tableView,view,section,[self getSection:section]);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    self.listener.didEndDisplayingFooterViewForSection(tableView, view, section,[self getSection:section]);
}

#pragma mark - Copying and Pasting Row content

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.shouldShowMenuForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return self.listener.canPerformActionForRowAtIndexPath(tableView,action,indexPath,sender);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    self.listener.performActionForRowAtIndexPath(tableView, action, indexPath, sender);
}

#pragma mark - Managing Table View Highlighting

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.shouldHighlightRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.didHighlightRowAtIndexPath(tableView, indexPath,[self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.didUnhighlightRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

#pragma mark  - Managing TableView Focus

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.canFocusRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context  API_AVAILABLE(ios(9.0)){
    return self.listener.shouldUpdateFocusInContext(tableView,context);
}

- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator  API_AVAILABLE(ios(9.0)){
    self.listener.didUpdateFocusInContextWithAnimationCoodinator(tableView, context, coordinator);
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView {
    return self.listener.indexPathForPreferredFocusedViewInTableView(tableView);
}

#pragma mark - dataSource

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.listener.sectionIndexTitlesForTableView(tableView);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return self.listener.sectionForSectionIndexTitleAtIndex(tableView,title,index,[self getSection:index]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.listener.titleForHeaderInSection(tableView,section,[self getSection:section]);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.listener.titleForFooterInSection(tableView,section,[self getSection:section]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.listener.commitEditingStyleForRowAtIndexPath(tableView, editingStyle, indexPath, [self getObject:indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.canEditRowAtIndexPath(tableView,indexPath, [self getObject:indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.listener.canMoveRowAtIndexPath(tableView,indexPath, [self getObject:indexPath]);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    self.listener.moveRowAtIndexPathToIndexPath(tableView, sourceIndexPath, destinationIndexPath);
}

#pragma mark  - prefecthing

- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths {
    if (@available(iOS 10.0, *)) {
        self.listener.prefetchRowsAtIndexPaths(tableView, indexPaths);
    } else {
        // Fallback on earlier versions
    }
}

- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths {
    if (@available(iOS 10.0, *)) {
        self.listener.cancelPrefetchingForRowsAtIndexPaths(tableView, indexPaths);
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark  require

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_fakeArray) {
        return _listener.numberOfRowsInSection(tableView, section);
    } else {
        if (self.listener.subArray) {
            return self.listener.subArray(_dataSource, section).count;
        } else {
            return _dataSource.count ;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.listener.cellForRowAtIndexPath(tableView,indexPath,[self getObject:indexPath]);
}
#pragma mark - UIScrollView Delegate
// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_listener.scrollViewDidScroll) {
        _listener.scrollViewDidScroll(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:scrollView];
    }
}
// any zoom scale changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2){
    
    if(_listener.scrollViewDidZoom){
        _listener.scrollViewDidZoom(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [_delegate scrollViewDidZoom:scrollView];
    }
}


// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_listener.scrollViewWillBeginDragging) {
        _listener.scrollViewWillBeginDragging(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0){
    
    if(_listener.scrollViewWillEndDragging){
        _listener.scrollViewWillEndDragging(scrollView, velocity, targetContentOffset);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_listener.scrollViewDidEndDragging) {
        _listener.scrollViewDidEndDragging(scrollView, decelerate);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

// called on finger up as we are moving
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (_listener.scrollViewWillBeginDecelerating) {
        _listener.scrollViewWillBeginDecelerating(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_delegate scrollViewWillBeginDecelerating:scrollView];
    }
}
// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_listener.scrollViewDidEndDecelerating) {
        _listener.scrollViewDidEndDecelerating(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:scrollView];
    }
}
// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (_listener.scrollViewDidEndScrollingAnimation) {
        _listener.scrollViewDidEndScrollingAnimation(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

// return a view that will be scaled. if delegate returns nil, nothing happens
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (_listener.viewForZoomingInScrollView) {
        return _listener.viewForZoomingInScrollView(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [_delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
// called before the scroll view begins zooming its content
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view NS_AVAILABLE_IOS(3_2){
    if (_listener.scrollViewWillBeginZooming){
        _listener.scrollViewWillBeginZooming(scrollView, view);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [_delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (_listener.scrollViewDidEndZooming) {
        _listener.scrollViewDidEndZooming(scrollView, view, scale);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [_delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
// return a yes if you want to scroll to the top. if not defined, assumes YES
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if (_listener.scrollViewShouldScrollToTop) {
        return _listener.scrollViewShouldScrollToTop(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_delegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}
// called when scrolling animation finished. may be called immediately if already at top
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if (_listener.scrollViewShouldScrollToTop) {
        _listener.scrollViewShouldScrollToTop(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [_delegate scrollViewDidScrollToTop:scrollView];
    }
}

/* Also see -[UIScrollView adjustedContentInsetDidChange]
 */
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView API_AVAILABLE(ios(11.0), tvos(11.0)){
    if(_listener.scrollViewDidChangeAdjustedContentInset){
        _listener.scrollViewDidChangeAdjustedContentInset(scrollView);
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidChangeAdjustedContentInset:)]) {
        [_delegate scrollViewDidChangeAdjustedContentInset:scrollView];
    }
}

#pragma mark   optional
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_fakeArray) {
        return _listener.numberOfSections(tableView);
    } else {
        if (_listener.subArray) {
            return _dataSource.count;
        } else {
            return 1;
        }
    }
}

- (NSMutableArray *)observerArray{
    if (!_observerArray) {
        _observerArray = [NSMutableArray array];
    }
    return _observerArray;
}

-(void)setListener:(TableViewArray *)listener{
    _listener = listener;
    [self checkCircleReference:_listener];
    _fakeArray = _listener.numberOfSections != nil;
}
-(void)checkCircleReference:(TableViewArray*)listener{
    NSAssert(!checkCircleReference(listener.subArray, listener), @"raise a block circle reference reason: subArray");

    /**dataSource*/
    NSAssert(!checkCircleReference(listener.numberOfSections, listener), @"raise a block circle reference reason: numberOfSections");
    NSAssert(!checkCircleReference(listener.numberOfRowsInSection, listener), @"raise a block circle reference reason: numberOfRowsInSection");
    NSAssert(!checkCircleReference(listener.getItem, listener), @"raise a block circle reference reason: getItem");
    NSAssert(!checkCircleReference(listener.getSection, listener), @"raise a block circle reference reason: getSection");
    NSAssert(!checkCircleReference(listener.cellForRowAtIndexPath, listener), @"raise a block circle reference reason: cellForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.sectionIndexTitlesForTableView, listener), @"raise a block circle reference reason: sectionIndexTitlesForTableView");
    NSAssert(!checkCircleReference(listener.sectionForSectionIndexTitleAtIndex, listener), @"raise a block circle reference reason: sectionForSectionIndexTitleAtIndex");
    
    NSAssert(!checkCircleReference(listener.titleForHeaderInSection, listener), @"raise a block circle reference reason: titleForHeaderInSection");
    NSAssert(!checkCircleReference(listener.titleForFooterInSection, listener), @"raise a block circle reference reason: titleForFooterInSection");
    NSAssert(!checkCircleReference(listener.commitEditingStyleForRowAtIndexPath, listener), @"raise a block circle reference reason: commitEditingStyleForRowAtIndexPath");
    
    NSAssert(!checkCircleReference(listener.canEditRowAtIndexPath, listener), @"raise a block circle reference reason: canEditRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.canMoveRowAtIndexPath, listener), @"raise a block circle reference reason: canMoveRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.moveRowAtIndexPathToIndexPath, listener), @"raise a block circle reference reason: moveRowAtIndexPathToIndexPath");
    
#pragma mark - Delegate
#pragma mark - Managing Selections
    NSAssert(!checkCircleReference(listener.willSelectRowAtIndexPath, listener), @"raise a block circle reference reason: willSelectRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.didSelectRowAtIndexPath, listener), @"raise a block circle reference reason: didSelectRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.willDeselectRowAtIndexPath, listener), @"raise a block circle reference reason: willDeselectRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.didDeselectRowAtIndexPath, listener), @"raise a block circle reference reason: didDeselectRowAtIndexPath");
    
#pragma mark - Configuring Rows for the Table View
    NSAssert(!checkCircleReference(listener.heightForRowAtIndexPath, listener), @"raise a block circle reference reason: heightForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.estimatedHeightForRowAtIndexPath, listener), @"raise a block circle reference reason: estimatedHeightForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.indentationLevelForRowAtIndexPath, listener), @"raise a block circle reference reason: indentationLevelForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.willDisplayCellforRowAtIndexPath, listener), @"raise a block circle reference reason: willDisplayCellforRowAtIndexPath");
    
#pragma mark  - Managing Accessory Views
    NSAssert(!checkCircleReference(listener.editActionsForRowAtIndexPath, listener), @"raise a block circle reference reason: editActionsForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.accessoryButtonTappedForRowWithIndexPath, listener), @"raise a block circle reference reason: accessoryButtonTappedForRowWithIndexPath");
    
#pragma mark - Modifying the Header and Footer of Sections
    NSAssert(!checkCircleReference(listener.viewForHeaderInSection, listener), @"raise a block circle reference reason: viewForHeaderInSection");
    NSAssert(!checkCircleReference(listener.viewForFooterInSection, listener), @"raise a block circle reference reason: viewForFooterInSection");
    
    NSAssert(!checkCircleReference(listener.heightForHeaderInSection, listener), @"raise a block circle reference reason: heightForHeaderInSection");
    NSAssert(!checkCircleReference(listener.heightForFooterInSection, listener), @"raise a block circle reference reason: heightForFooterInSection");
    
    NSAssert(!checkCircleReference(listener.estimatedHeightForHeaderInSection, listener), @"raise a block circle reference reason: estimatedHeightForHeaderInSection");
    NSAssert(!checkCircleReference(listener.estimatedHeightForFooterInSection, listener), @"raise a block circle reference reason: estimatedHeightForFooterInSection");
    
    NSAssert(!checkCircleReference(listener.willDisplayHeaderViewForSection, listener), @"raise a block circle reference reason: willDisplayHeaderViewForSection");
    NSAssert(!checkCircleReference(listener.willDisplayFooterViewForSection, listener), @"raise a block circle reference reason: willDisplayFooterViewForSection");
    
#pragma mark - Editing Table Rows
    NSAssert(!checkCircleReference(listener.willBeginEditingRowAtIndexPath, listener), @"raise a block circle reference reason: willBeginEditingRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.didEndEditingRowAtIndexPath, listener), @"raise a block circle reference reason: didEndEditingRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.editingStyleForRowAtIndexPath, listener), @"raise a block circle reference reason: editingStyleForRowAtIndexPath");
    
    NSAssert(!checkCircleReference(listener.titleForDeleteConfirmationButtonForRowAtIndexPath, listener), @"raise a block circle reference reason: titleForDeleteConfirmationButtonForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.shouldIndentWhileEditingRowAtIndexPath, listener), @"raise a block circle reference reason: shouldIndentWhileEditingRowAtIndexPath");
    
#pragma mark - Reordering Table Rows
    NSAssert(!checkCircleReference(listener.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath, listener), @"raise a block circle reference reason: targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath");
    
#pragma mark  - Tracking The Removal of Views
    NSAssert(!checkCircleReference(listener.didEndDisplayingCellForRowAtIndexPath, listener), @"raise a block circle reference reason: didEndDisplayingCellForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.didEndDisplayingHeaderViewForSection, listener), @"raise a block circle reference reason: didEndDisplayingHeaderViewForSection");
    NSAssert(!checkCircleReference(listener.didEndDisplayingFooterViewForSection, listener), @"raise a block circle reference reason: didEndDisplayingFooterViewForSection");
#pragma mark - Copying and Pasting Row content
    
    NSAssert(!checkCircleReference(listener.shouldShowMenuForRowAtIndexPath, listener), @"raise a block circle reference reason: shouldShowMenuForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.canPerformActionForRowAtIndexPath, listener), @"raise a block circle reference reason: canPerformActionForRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.performActionForRowAtIndexPath, listener), @"raise a block circle reference reason: performActionForRowAtIndexPath");
    
#pragma mark  - Managing TableView Highlighting
    NSAssert(!checkCircleReference(listener.shouldHighlightRowAtIndexPath, listener), @"raise a block circle reference reason: shouldHighlightRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.didHighlightRowAtIndexPath, listener), @"raise a block circle reference reason: didHighlightRowAtIndexPath");
    NSAssert(!checkCircleReference(listener.didUnhighlightRowAtIndexPath, listener), @"raise a block circle reference reason: didUnhighlightRowAtIndexPath");
    
#pragma mark - Managing Table View Focus
    
    NSAssert(!checkCircleReference(listener.canFocusRowAtIndexPath, listener), @"raise a block circle reference reason: canFocusRowAtIndexPath");
    if (@available(iOS 9_0, *)) {
        NSAssert(!checkCircleReference(listener.shouldUpdateFocusInContext, listener), @"raise a block circle reference reason: shouldUpdateFocusInContext");
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 9.0, *)) {
        NSAssert(!checkCircleReference(listener.didUpdateFocusInContextWithAnimationCoodinator, listener), @"raise a block circle reference reason: didUpdateFocusInContextWithAnimationCoodinator");
    } else {
        // Fallback on earlier versions
    }
    NSAssert(!checkCircleReference(listener.indexPathForPreferredFocusedViewInTableView, listener), @"raise a block circle reference reason: indexPathForPreferredFocusedViewInTableView");
    
#pragma mark - prefetching
    
    if (@available(iOS 10.0, *)) {
        NSAssert(!checkCircleReference(listener.prefetchRowsAtIndexPaths, listener), @"raise a block circle reference reason: prefetchRowsAtIndexPaths");
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 10.0, *)) {
        NSAssert(!checkCircleReference(listener.cancelPrefetchingForRowsAtIndexPaths, listener), @"raise a block circle reference reason: cancelPrefetchingForRowsAtIndexPaths");
    } else {
        // Fallback on earlier versions
    }
    
    
}

-(void)setDataSource:(NSArray *)dataSource{
    if (!_fakeArray) {
        if (_dataSource!=dataSource) {
            [self removeObserver];
        }
        _dataSource = dataSource;
        
        if ([dataSource isKindOfClass:[NSMutableArray class]]) {
            [self addObserverForDataSource:(NSMutableArray*)self.dataSource];
            if (_listener.subArray) {
                for (NSInteger i = 0; i < self.dataSource.count; i++) {
                    NSArray* subArray = _listener.subArray(_dataSource, i);
                    if ([subArray isKindOfClass:[NSMutableArray class]]) {
                        [self addObserverForDataSource:(NSMutableArray*)subArray];
                        setArrayIndex(subArray, i);
                    }
                }
            }
        }
    }
}

-(void)addObserverForDataSource:(NSMutableArray * )array{
    BOOL isGroup = _listener.subArray != nil;
    typeof(self)__weak weakself = self;
    typeof(_listener.subArray)__weak weakSubArray = _listener.subArray;

    MutableArrayListener *observer = [[MutableArrayListener alloc]init];
    observer.didAddObjects = ^(NSMutableArray *array, NSArray *objects, NSIndexSet *indexes) {
        if (array==weakself.dataSource) {
            if (isGroup) {
                if (weakself.listener.disableAnimation) {
                    [weakself.tableView reloadData];
                } else {
                    [weakself.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationNone];
                }
                typeof(weakself.listener.subArray) strongSubArray = weakSubArray;
                if (strongSubArray) {
                    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray* subArray = strongSubArray(array, idx);
                        if ([subArray isKindOfClass:[NSMutableArray class]]) {
                            [weakself addObserverForDataSource:(NSMutableArray*)subArray];
                            setArrayIndex(subArray, idx);
                        }
                    }];
                }
            }else{
                NSMutableArray * indexPaths = [NSMutableArray array];
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }];
                if (weakself.listener.disableAnimation) {
                    [weakself.tableView reloadData];
                } else {
                    [weakself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }else{
            NSInteger section = getArrayIndex(array);
            NSMutableArray * indexPaths = [NSMutableArray array];
            [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
            }];
            if (weakself.listener.disableAnimation) {
                [weakself.tableView reloadData];
            } else {
                [weakself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    };
    observer.didDeleteObjects = ^(NSMutableArray *array, NSArray *objects, NSIndexSet *indexes) {
//        [weakself.tableView beginUpdates];
        if (array==weakself.dataSource) {
            if (isGroup) {
                if (weakself.listener.disableAnimation) {
                    [weakself.tableView reloadData];
                } else {
                    [weakself.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationNone];
                }
                for (NSInteger i = 0; i < array.count; i++) {
                    NSArray* subArray = weakSubArray(array, i);
                    if ([subArray isKindOfClass:[NSMutableArray class]]) {
                        setArrayIndex(subArray, i);
                    }
                }
            }else{
                NSMutableArray * indexPaths = [NSMutableArray array];
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }];
                if (weakself.listener.disableAnimation) {
                    [weakself.tableView reloadData];
                } else {
                    [weakself.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }else{
            NSInteger section = getArrayIndex(array);
            NSMutableArray * indexPaths = [NSMutableArray array];
            [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
            }];
            if (weakself.listener.disableAnimation) {
                [weakself.tableView reloadData];
            } else {
                [weakself.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
        }
//        [weakself.tableView endUpdates];
    };
    observer.didExchangeIndex = ^(NSMutableArray *array, NSUInteger index1, NSUInteger index2) {
//        [weakself.tableView beginUpdates];
        if (array==weakself.dataSource) {
            if (isGroup) {
                NSArray* subArray = weakSubArray(array, index1);
                if ([subArray isKindOfClass:[NSMutableArray class]]) {
                    setArrayIndex(subArray, index1);
                }
                subArray = weakSubArray(array, index2);
                if ([subArray isKindOfClass:[NSMutableArray class]]) {
                    setArrayIndex(subArray, index2);
                }
                [weakself.tableView moveSection:index1 toSection:index2];
                [weakself.tableView moveSection:index2 toSection:index1];
            }else{
                [weakself.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:index2 inSection:0]];
                [weakself.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index2 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:index1 inSection:0]];
            }
        }else{
            NSInteger section = getArrayIndex(array);
            [weakself.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index1 inSection:section] toIndexPath:[NSIndexPath indexPathForRow:index2 inSection:section]];
            [weakself.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index2 inSection:section ] toIndexPath:[NSIndexPath indexPathForRow:index1 inSection:section]];
        }
//        [weakself.tableView endUpdates];
    };
    observer.didReplaceObject = ^(NSMutableArray *array, id anObject, id withObject, NSUInteger index) {
        if (array==weakself.dataSource) {
            if (isGroup) {
                [weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
                typeof(weakself.listener.subArray) strongSubArray = weakSubArray;
                if (strongSubArray) {
                    NSArray* subArray = strongSubArray(array, index);
                    if ([subArray isKindOfClass:[NSMutableArray class]]) {
                        [weakself addObserverForDataSource:(NSMutableArray*)subArray];
                        setArrayIndex(subArray, index);
                    }
                }
            }else{
                [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }else{
            NSInteger section = getArrayIndex(array);
            [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    observer.didChanged = ^(NSMutableArray *array) {
        if (array==weakself.dataSource) {
            [weakself.tableView reloadData];
            [weakself removeObserver];
            [weakself addObserverForDataSource:(NSMutableArray *)weakself.dataSource];
            typeof(weakself.listener.subArray) strongSubArray = weakSubArray;
            if (strongSubArray) {
                for (NSInteger i = 0; i < weakself.dataSource.count; i++) {
                    NSArray* subArray = strongSubArray(weakself.dataSource, i);
                    if ([subArray isKindOfClass:[NSMutableArray class]]) {
                        [weakself addObserverForDataSource:(NSMutableArray*)subArray];
                        setArrayIndex(subArray, i);
                    }
                }
            }
        } else {
            NSInteger section = getArrayIndex(array);
            [weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    
    [array addListener:observer];
    [self.observerArray addObject:observer];
    
}

-(void)removeObserver{
    for (MutableArrayListener * obs in self.observerArray) {
        [(NSMutableArray*)self.dataSource removeListener:obs];
        if (_listener.subArray) {
            for (NSInteger i = 0; i < _dataSource.count; i++) {
                NSArray* subArray = _listener.subArray(_dataSource, i);
                if ([subArray isKindOfClass:[NSMutableArray class]]) {
                    for (MutableArrayListener * obs in self.observerArray) {
                        [(NSMutableArray*)subArray removeListener:obs];
                    }
                }
            }
        }
    }
    [self.observerArray removeAllObjects];
}

@end

