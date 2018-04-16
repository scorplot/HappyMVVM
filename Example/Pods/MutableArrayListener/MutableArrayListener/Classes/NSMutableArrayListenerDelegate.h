//
//  MutableArrayDelegate.h
//  Pods
//
//  Created by aruisi on 2017/7/7.
//
//

#import <Foundation/Foundation.h>

@protocol NSMutableArrayListenerDelegate <NSObject>
@required
#pragma mark - insert

/**
 A Item insert into array
 
 @param array the array
 @param objects the objects did insert into array
 @param indexSet the position of objects did insert into array
 */
-(void)mutableArray:(NSMutableArray*)array didAddObjects:(NSArray *)objects atIndexes:(NSIndexSet*)indexSet;

#pragma mark - remove
/**
 Items did removed from array
 
 @param array the array
 @param objects the objects did removed from array
 @param indexes the positions did removed from array
 */
-(void)mutableArray:(NSMutableArray *)array didDeleteObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes;

#pragma mark  - replace
/**
 The index of array has been replaced
 
 @param array the array
 @param object the object which to be replaced
 @param anObject the object which did replaced
 @param index the index which did replaced
 */
-(void)mutableArray:(NSMutableArray*)array replaceObject:(id )object withObject:(id)anObject atIndex:(NSUInteger)index;

#pragma mark  - sort
/**
 The array have been sort
 
 @param array the array
 */
-(void)mutableArrayhasChanged:(NSMutableArray*)array;

#pragma mark - exhcange

/**
 The index1 and index2 have been exchanged
 
 @param array the array
 @param index1 the index1
 @param index2 the index2
 */
-(void)mutableArray:(NSMutableArray*)array exchangeObjectAtIndex:(NSUInteger)index1 withObjectAtIndex:(NSUInteger)index2;
@end
