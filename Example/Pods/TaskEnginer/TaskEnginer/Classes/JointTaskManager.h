//
//  JointTaskManager.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/30.
//

// JointTaskManager is design for joint task system. for example images download from network, maybe many place to download same image, but only one physis request shoudl be made.

#import <Foundation/Foundation.h>

@class JointTaskItem;
@class TaskRoute;
@interface JointTaskManager : NSObject
// check is executing
-(BOOL)isExecuting:(id<NSCopying>)key;

// progress
-(NSUInteger)compeleted:(id<NSCopying>)key;
-(NSUInteger)expected:(id<NSCopying>)key;
-(double)progress:(id<NSCopying>)key; // progress = compeleted/expected;

// executing array
@property (atomic, readonly) NSArray<id<NSCopying>>* executingArray;

// waitting to executing array
@property (atomic, readonly) NSArray<id<NSCopying>>* waittingArray;

// the dispatch queue which to execute task, the default value isdispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
@property (atomic, readwrite) dispatch_queue_t executingQueue;

// request a query with key
-(JointTaskItem*)request:(id<NSCopying>)key;

// cancel all query with key
-(void)cancelWithKey:(id<NSCopying>)key;

// cancel a task
-(void)cancelWithTask:(JointTaskItem*)task;

#pragma mark Subclass need to override

// select a task which should be start
-(id<NSCopying>)selectTask;

// really executing task
-(TaskRoute*)doExecute:(id<NSCopying>)key;

@end
