//
//  TaskRoute.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/30.
//

// A TaskRoute could be combined with one or more SubTask, JointTask.

#import <Foundation/Foundation.h>

@class SubTask;
@interface TaskRoute : NSObject
@property (nonatomic, strong) id result; // executed result
@property (nonatomic, strong, readonly) id<NSObject> context; // context

@property (nonatomic, readonly) NSTimeInterval beginTime;
@property (nonatomic, readonly) NSTimeInterval endTime;

-(instancetype)initWithSubTasks:(NSArray<SubTask*>*)subTasks context:(id<NSObject>)context;

-(instancetype)initWithSingleTask:(SubTask*)subTask context:(id<NSObject>)context;

@property (nonatomic, readonly) NSArray<SubTask*>* subTasks; // all sub tasks

/**
 when trigger is YES, TaskRoute will retian self when task start, and release self when task finished or cancled.
 when trigger is No, TaskRoute should not retian self whatever task start, cancel or finished.
 
 The default value is NO
 */
@property (nonatomic, assign) BOOL autoRetain;

// The taskroute is executing
@property (nonatomic, readonly, getter = isExecuting) BOOL executing;
// The taskroute is finished
@property (nonatomic, readonly, getter = isFinished) BOOL finished;

// progress
@property (nonatomic, readonly) NSUInteger compeleted;
@property (nonatomic, readonly) NSUInteger expected;
@property (nonatomic, readonly) double progress; // progress = compeleted/expected;

// callback dispatch queue the default value is dispatch_get_main_queue()
@property (atomic, readwrite) dispatch_queue_t callbackQueue;

// progress callback dispatch queue，default value is dispatch_get_main_queue()
@property (atomic, readwrite) dispatch_queue_t progressQueue;

//taskRoute did start block
@property (nonatomic, copy) void (^didStart)(TaskRoute *task);

//taskRoute did cancel block
@property (nonatomic, copy) void (^didCancel)(TaskRoute *task);

//taskRoute did finished block
//This block may be called many times, each call back mean a subTask finished.
//The finished value is YES in last call.
//If finished value is No the error always nil.
@property (nonatomic, copy) void (^didFinished)(TaskRoute *task, NSError *error, BOOL finished);

//taskRoute progress block
@property (nonatomic, copy) void (^progressCallback)(TaskRoute *task, NSUInteger compeleted, NSUInteger expected);

// start taskRoute
-(void)start;

// cancel the taskRoute, If task started, the taskDidCancel will be called
-(void)cancel;

// try again
-(void)tryContinue;

// For a long time taskRoute, we can report result part by part.
// Call this method to report result partly.
-(void)reportDaily;

#pragma mark SubClass need to override method

// To execute task, need to override method, should return which subtasks should be execute
// return nil-->No sub task should be start right now.
// return empty array-->TaskRoute should be finished.
// return non empty array-->subtasks which should be execute.
-(NSArray<SubTask*>*)selectSubTask;

// When a subTask finished, this method will be called, sub class should gether information from subtask
-(void)subSubTaskDidFinish:(SubTask*)item;

@end
