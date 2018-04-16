//
//  JointTaskManager.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/30.
//

#import "JointTaskManager.h"
#import "JointTaskItem.h"
#import "TaskRoute.h"

@interface JointTaskItem()
@property (nonatomic, copy) id<NSCopying> key;
@property (atomic, weak) JointTaskManager* manager;

@property (nonatomic, assign) NSTimeInterval beginTime; // beginTime
@property (nonatomic, assign) NSTimeInterval endTime; // endTime

@property (nonatomic, assign) NSUInteger compeleted;
@property (nonatomic, assign) NSUInteger expected;
@property (nonatomic, assign) double progress;

@end

@interface JointTaskItemInfo : NSObject
@property (nonatomic, strong) TaskRoute* task;
@property (nonatomic, strong) NSMutableArray<JointTaskItem*>* subTasks;
@property (nonatomic, assign) NSUInteger compeleted;
@property (nonatomic, assign) NSUInteger expected;
@property (nonatomic, assign) double progress;

@property (nonatomic, assign) NSTimeInterval beginTime; // beginTime
@property (nonatomic, assign) NSTimeInterval endTime; // endTime
@end

@implementation JointTaskManager {
    NSMutableDictionary<id<NSCopying>, JointTaskItemInfo*>* _tasks;
    NSMutableArray<id<NSCopying>>* _executingArray;
    NSMutableArray<id<NSCopying>>* _waittingArray;
    
    dispatch_queue_t _executingQueue;
}
-(instancetype)init {
    if (self) {
        _tasks = [[NSMutableDictionary alloc] init];
        _executingArray = [[NSMutableArray alloc] init];
        _waittingArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// check is executing
-(BOOL)isExecuting:(id<NSCopying>)key {
    if (key) {
        @synchronized(self) {
            return [_executingArray containsObject:key] || [_waittingArray containsObject:key];
        }
    }
    return NO;
}

// progress
-(NSUInteger)compeleted:(id<NSCopying>)key {
    @synchronized(self) {
        return [_tasks objectForKey:key].compeleted;
    }
    return 0;
}
-(NSUInteger)expected:(id<NSCopying>)key {
    @synchronized(self) {
        return [_tasks objectForKey:key].expected;
    }
    return 0;
}
-(double)progress:(id<NSCopying>)key {
    @synchronized(self) {
        return [_tasks objectForKey:key].progress;
    }
    return 0;
}

// executingQueue
-(dispatch_queue_t)executingQueue {
    @synchronized(self) {
        if (_executingQueue == nil)
            _executingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        return _executingQueue;
    }
}
-(void)setExecutingQueue:(dispatch_queue_t)executingQueue {
    @synchronized(self) {
        _executingQueue = executingQueue;
    }
}

-(void)appendTask:(JointTaskItem*)task {
    BOOL bExecuting = NO;
    @synchronized(self) {
        task.manager = self;
        JointTaskItemInfo* info = [_tasks objectForKey:task.key];
        if (info == nil) {
            info = [[JointTaskItemInfo alloc] init];
            info.subTasks = [[NSMutableArray alloc] init];
            [_tasks setObject:info forKey:task.key];
        }
        task.beginTime = info.beginTime;
        task.endTime = info.endTime;
        task.expected = info.expected;
        task.compeleted = info.compeleted;
        task.progress = info.progress;
        [info.subTasks addObject:task];
        
        bExecuting = [_executingArray containsObject:task.key];
        BOOL bWaitting = [_waittingArray containsObject:task.key];
        if (!bExecuting && !bWaitting) {
            [_waittingArray addObject:task.key];
        }
    }
    
    if (bExecuting)
        [self notifyDidStartWithSubTask:task];
}

// main logic
-(void)tick {
    typeof(self) ws = self;
    dispatch_async(self.executingQueue, ^{
        @autoreleasepool {
            typeof(self) SELF = ws;
            JointTaskItemInfo* info = nil;
            id<NSCopying> key = nil;
            @synchronized(self) {
                key = [SELF selectTask];
                if (key == nil) return;
                
                [SELF->_waittingArray removeObject:key];
                [SELF->_executingArray addObject:key];
                
                info = [SELF->_tasks objectForKey:key];
                info.beginTime = [[NSDate date] timeIntervalSince1970];
                for (JointTaskItem* item in info.subTasks) {
                    item.beginTime = info.beginTime;
                }
                info.task = [SELF doExecute:key];
            }
            
            if (info) {
                
                // task will start
                [SELF notifyDidStart:info];
                
                __block void (^old)(TaskRoute *task, NSError *error, BOOL finished) = info.task.didFinished;
                // execute task
                void (^taskDidFinished)(TaskRoute *task, NSError *error, BOOL finished) = ^(TaskRoute *task, NSError *error, BOOL finished) {
                    typeof(self) SELF = ws;
                    if (SELF) {
                        if (finished) {
                            NSArray* tasks = nil;
                            // task finished，progress set to 1
                            @synchronized(SELF) {
                                info.endTime = [[NSDate date] timeIntervalSince1970];
                                for (JointTaskItem* item in info.subTasks) {
                                    item.endTime = info.endTime;
                                }
                                
                                if (error == nil)
                                    info.progress = 1;
                                tasks = info.subTasks; //move to temporary array
                                info.subTasks = nil; //clean array
                                info.task = nil;
                                
                                [SELF->_executingArray removeObject:key];
                                [SELF->_waittingArray removeObject:key];
                                [SELF->_tasks removeObjectForKey:key];
                            }
                            
                            // task finished
                            [SELF notifyDidFinish:tasks error:error finished:YES];
                            if (old)
                                old(task, error, finished);
                            
                            [SELF tick];
                        } else {
                            [SELF reportDaily:key];
                        }
                    }
                };
                
                TaskRoute* task = nil;
                @synchronized(SELF) {
                    task = info.task;
                    old = task.didFinished;
                    if (task) {
                        task.didFinished = taskDidFinished;
                    } else {
                        taskDidFinished(nil, nil, YES);
                    }
                }
                [task start];
            }
            [SELF tick];
        }
    });
}

// requset a query with a key
-(JointTaskItem*)request:(id<NSCopying>)key {
    if (key) {
        JointTaskItem* item = [[JointTaskItem alloc] init];
        item.key = key;
        [self appendTask:item];
        
        [self tick];
        return item;
    }
    return nil;
}

// cancel all query with key
-(void)cancelWithKey:(id<NSCopying>)key {
    NSArray* tasks = nil;
    TaskRoute* task = nil;
    @synchronized(self) {
        JointTaskItemInfo* info = [_tasks objectForKey:key];
        if (key && [_executingArray containsObject:key]) {
            [_executingArray removeObject:key];
            task = info.task;
            info.task = nil;
        }
        [_waittingArray removeObject:key];
        [_tasks removeObjectForKey:key];
        tasks = info.subTasks;
        info.subTasks = nil;
    }
    [self notifyDidCancel:tasks];
    [task cancel];
}

// cancel a task
-(void)cancelWithTask:(JointTaskItem*)task {
    NSArray* tasks = nil;
    TaskRoute* t = nil;
    @synchronized(self) {
        id<NSCopying> key = task.key;
        if (key) {
            JointTaskItemInfo* info = [_tasks objectForKey:key];
            [info.subTasks removeObjectIdenticalTo:task]; // 取消其中一个任务
            
            if (info.subTasks.count == 0 && [_executingArray containsObject:key]) {// 全部都取消了，那么就真的取消这个任务
                [_executingArray removeObject:key];
                t = info.task;
                info.task = nil;
                
                tasks = @[task];
                info.subTasks = nil;
                
                [_waittingArray removeObject:key];
                [_tasks removeObjectForKey:key];
            }
        }
    }
    [t cancel];
    [self notifyDidCancel:tasks];
}

//callback did start
// TODO:@chj the same queue, only dispatch once
-(void)notifyDidStart:(JointTaskItemInfo*)info {
    for (__strong JointTaskItem* item in info.subTasks) {
        dispatch_queue_t queue = item.callbackQueue;
        if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
            void (^disStart)(JointTaskItem *item) = item.didStart;
            if (disStart)
                disStart(item);
        } else {
            dispatch_async(queue, ^{
                void (^disStart)(JointTaskItem *item) = item.didStart;
                if (disStart)
                    disStart(item);
            });
        }
    }
}

-(void)notifyDidStartWithSubTask:(JointTaskItem*)item {
    dispatch_queue_t queue = item.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        void (^didStart)(JointTaskItem *item) = item.didStart;
        if (didStart)
            didStart(item);
    } else {
        dispatch_async(queue, ^{
            void (^didStart)(JointTaskItem *item) = item.didStart;
            if (didStart)
                didStart(item);
        });
    }
}

//callback did cancel
// TODO:@chj the same queue, only dispatch once
-(void)notifyDidCancel:(NSArray*)tasks {
    for (__strong JointTaskItem* item in tasks) {
        dispatch_queue_t queue = item.callbackQueue;
        if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
            void (^didCancel)(JointTaskItem *item) = item.didCancel;
            if (didCancel)
                didCancel(item);
        } else {
            dispatch_async(queue, ^{
                void (^didCancel)(JointTaskItem *item) = item.didCancel;
                if (didCancel)
                    didCancel(item);
            });
        }
    }
}

//callback did finish, if error is not nil, the error occues
// TODO:@chj the same queue, only dispatch once
-(void)notifyDidFinish:(NSArray*)tasks error:(NSError*)error finished:(BOOL)finished {
    for (__strong JointTaskItem* item in tasks) {
        dispatch_queue_t queue = item.callbackQueue;
        if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
            void (^didFinished)(JointTaskItem *item, NSError *error, BOOL finished) = item.didFinished;
            if (didFinished)
                didFinished(item, error, finished);
        } else {
            dispatch_async(queue, ^{
                void (^didFinished)(JointTaskItem *item, NSError *error, BOOL finished) = item.didFinished;
                if (didFinished)
                    didFinished(item, error, finished);
            });
        }
    }
}

//report progress
-(void)notifyProgress:(id<NSCopying>)key compeleted:(NSUInteger)compeleted expected:(NSUInteger)expected {
    NSArray<JointTaskItem*>* tasks = nil;
    @synchronized(self) {
        if (_tasks != nil) {
            JointTaskItemInfo* info = [_tasks objectForKey:key];
            if (info != nil) {
                info.compeleted = compeleted;
                info.expected = expected;
                if (expected != 0)
                    info.progress = compeleted*1.0/expected;
            }
            tasks = info.subTasks;
        }
    }
    
    for (__strong JointTaskItem* item in tasks) {
        dispatch_queue_t queue = item.progressQueue;
        if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
            void (^taskItemProgress)(JointTaskItem *item, NSUInteger compeleted, NSUInteger expected) = item.progressCallback;
            if (taskItemProgress)
                taskItemProgress(item, compeleted, expected);
        } else {
            dispatch_async(queue, ^{
                void (^taskItemProgress)(JointTaskItem *item, NSUInteger compeleted, NSUInteger expected) = item.progressCallback;
                if (taskItemProgress)
                    taskItemProgress(item, compeleted, expected);
            });
        }
    }
}
// report daily, some task will need a long time, report part by part
-(void)reportDaily:(id<NSCopying>)key {
    NSArray* arr = nil;
    @synchronized(self) {
        arr = [[_tasks objectForKey:key] subTasks];
    }
    [self notifyDidFinish:arr error:nil finished:NO];
}

#pragma mark SubClassNeedOverrid

// select a task which should be start
-(id<NSCopying>)selectTask {
    return nil;
}

// really executing task
-(TaskRoute*)doExecute:(id<NSCopying>)key {
    return nil;
}
@end

@implementation JointTaskItemInfo
@end
