//
//  SubTask.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/29.
//

#import <Foundation/Foundation.h>

@class TaskRoute;
@interface SubTask : NSObject
@property (nonatomic, strong, readonly) id context; // context
@property (nonatomic, weak, readonly) TaskRoute* task;
@property (nonatomic, strong) id result; // result
@property (nonatomic, strong, readonly) NSError* error; // error

@property (nonatomic, readonly) NSTimeInterval beginTime; // beginTime
@property (nonatomic, readonly) NSTimeInterval endTime; // endTime

@property (nonatomic, readwrite) float weight; // the weight for progress

// is executing
@property (nonatomic, readonly) BOOL executing;
@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) BOOL canceled;

// progress
@property (nonatomic, readonly) NSUInteger compeleted;
@property (nonatomic, readonly) NSUInteger expected;
@property (nonatomic, readonly) double progress; // progress = compeleted/expected;

// the dispatch queue for executing, the default value is dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
@property (atomic, readwrite) dispatch_queue_t executingQueue;

// the dispatch queue for callback, the default value is  dispatch_get_main_queue()
@property (atomic, readwrite) dispatch_queue_t callbackQueue;

// the dispatch queue for progress, the default value is dispatch_get_main_queue()
@property (atomic, readwrite) dispatch_queue_t progressQueue;

// will start
@property (nonatomic, copy) void (^willStart)(SubTask *subTask);

//did start
@property (nonatomic, copy) void (^didStart)(SubTask *subTask);

//did cancel
@property (nonatomic, copy) void (^didCancel)(SubTask *subTask);

//subTask did finished block
//This block may be called many times, each call back mean a subTask finished.
//The finished value is YES in last call.
//If finished value is No the error always nil.
@property (nonatomic, copy) void (^didFinished)(SubTask *subTask, NSError *error, BOOL finished);

//progress callback
@property (nonatomic, copy) void (^progressCallback)(SubTask *subTask, NSUInteger compeleted, NSUInteger expected);

// start
-(void)start;

// cancel the taskRoute, If task started, the taskDidCancel will be called
-(void)cancel;

// notify progress
-(void)notifyProgress:(NSInteger)compeleted expected:(NSInteger)expected;

// For a long time taskRoute, we can report result part by part.
// Call this method to report result partly.
-(void)reportDaily;

#pragma mark SubClass need to override method

// physis executing task
-(void)doExecute:(void (^)(NSError* error))block;

// physis cancel task
-(void)doCancel;

@end
