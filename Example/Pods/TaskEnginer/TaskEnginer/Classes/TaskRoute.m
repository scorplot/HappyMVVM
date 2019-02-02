//
//  TaskRoute.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/30.
//

#import "TaskRoute.h"
#import "SubTask.h"
#import "CircleReferenceCheck.h"

@interface SubTask()
@property (nonatomic, readwrite) NSTimeInterval beginTime;
@property (nonatomic, readwrite) NSTimeInterval endTime;

// is executing
@property (nonatomic, readwrite) BOOL executing;
@property (nonatomic, readwrite) BOOL finished;

@property (nonatomic, readonly) int tickCount; // the tick count, every executing will increase

// progress
@property (nonatomic, readwrite) NSUInteger compeleted;
@property (nonatomic, readwrite) NSUInteger expected;
@property (nonatomic, readwrite) double progress; // progress = compeleted/expected;

@property (nonatomic, weak) TaskRoute* task;
@end

@interface TaskRoute()
@property (nonatomic, readwrite) NSTimeInterval beginTime;
@property (nonatomic, readwrite) NSTimeInterval endTime;

// is executing
@property (nonatomic, readwrite) BOOL executing;
@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) BOOL canceled;

// progress
@property (nonatomic, readwrite) NSUInteger compeleted;
@property (nonatomic, readwrite) NSUInteger expected;
@property (nonatomic, readwrite) double progress; // progress = compeleted/expected;

@property (nonatomic, strong) id strongSelf;
@end

@interface TaskRoute()
@property (nonatomic, readonly) int tickCount; // every start task,this count will be add with one
@property (nonatomic, readonly) NSArray<SubTask*>* subTaskDoing; // sub tasks which is executing
@end

@implementation TaskRoute {
    NSArray* _subTasks;
    NSMutableDictionary* _itemsExecutingCount;
    NSMutableArray* _subTaskDoing;
    dispatch_queue_t _callbackQueue;
    dispatch_queue_t _progressQueue;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        NSAssert(false, @"should use initWithContext:");
    }
    return self;
}

-(void)setDidStart:(void (^)(TaskRoute *))taskDidStart {
    _didStart = taskDidStart;
    NSAssert(!checkCircleReference(taskDidStart, self), @"raise a block circle reference");
}

-(void)setDidCancel:(void (^)(TaskRoute *))taskDidCancel {
    _didCancel = taskDidCancel;
    NSAssert(!checkCircleReference(taskDidCancel, self), @"raise a block circle reference");
}

-(void)setDidFinished:(void (^)(TaskRoute *, NSError *, BOOL))taskDidFinished {
    _didFinished = taskDidFinished;
    NSAssert(!checkCircleReference(taskDidFinished, self), @"raise a block circle reference");
}

-(void)setProgressCallback:(void (^)(TaskRoute *, NSUInteger, NSUInteger))taskProgress {
    _progressCallback = taskProgress;
    NSAssert(!checkCircleReference(taskProgress, self), @"raise a block circle reference");
}

-(void)dealloc {
    
}

-(void)setAutoRetain:(BOOL)autoRetain {
    @synchronized(self) {
        _autoRetain = autoRetain;
        if (_executing) {
            if (_autoRetain) self.strongSelf = self;
            else self.strongSelf = nil;
        }
    }
}

// callbackQueue
-(dispatch_queue_t)callbackQueue {
    @synchronized(self) {
        if (_callbackQueue == nil)
            _callbackQueue = dispatch_get_main_queue();
        return _callbackQueue;
    }
}
-(void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    @synchronized(self) {
        _callbackQueue = callbackQueue;
    }
}

// progressQueue
-(dispatch_queue_t)progressQueue {
    @synchronized(self) {
        if (_progressQueue == nil)
            _progressQueue = dispatch_get_main_queue();
        return _progressQueue;
    }
}
-(void)setProgressQueue:(dispatch_queue_t)progressQueue {
    @synchronized(self) {
        _progressQueue = progressQueue;
    }
}

-(instancetype)initWithSubTasks:(NSArray<SubTask*>*)subTasks context:(id)context{
    self = [super init];
    if (self) {
        _context = context;
        _subTasks = [subTasks copy];
        _subTaskDoing = [[NSMutableArray alloc] init];
        _itemsExecutingCount = [[NSMutableDictionary alloc] init];
        for (__strong SubTask* subTask in subTasks) {
            subTask.task = self;
        }
    }
    return self;
}

-(instancetype)initWithSingleTask:(SubTask*)subTask context:(id)context {
    return [self initWithSubTasks:@[subTask] context:context];
}

//callback did start
-(void)notifyDidStart:(int)tickCount {
    dispatch_queue_t queue = self.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (tickCount != _tickCount) return;
        void (^didStart)(TaskRoute *task) = self.didStart;
        if (didStart)
            didStart(self);
    } else {
        dispatch_async(queue, ^{
            if (tickCount != self->_tickCount) return;
            void (^disStart)(TaskRoute *task) = self.didStart;
            if (disStart)
                disStart(self);
        });
    }
}

//callback did cancel
-(void)notifyDidCancel:(int)tickCount {
    // avoid crash when dealloc
    __block __strong id strongSelf = self;

    dispatch_queue_t queue = self.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (tickCount + 1 != _tickCount) return;
        void (^dicCancel)(TaskRoute *task) = self.didCancel;
        if (dicCancel)
            dicCancel(self);
        self.strongSelf = nil;
        strongSelf = nil;
    } else {
        dispatch_async(queue, ^{
            if (tickCount + 1 != self->_tickCount) return;
            void (^didCancel)(TaskRoute *task) = self.didCancel;
            if (didCancel)
                didCancel(self);
            self.strongSelf = nil;
            strongSelf = nil;
        });
    }
}

//callback did finish, if error is not nil, the error occues
-(void)notifyDidFinish:(NSError*)error finished:(BOOL)finished tickCount:(int)tickCount {
    // avoid crash when dealloc
    __block __strong id strongSelf = self;
    
    dispatch_queue_t queue = self.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (!finished && tickCount != _tickCount) return;
        if (finished && tickCount + 1 != _tickCount) return;
        void (^didFinished)(TaskRoute *task, NSError *error, BOOL finished) = self.didFinished;
        if (didFinished)
            didFinished(self, error, finished);
        if (finished) self.strongSelf = nil;
        strongSelf = nil;
    } else {
        dispatch_async(queue, ^{
            if (!finished && tickCount != self->_tickCount) return;
            if (finished && tickCount + 1 != self->_tickCount) return;
            void (^didFinished)(TaskRoute *task, NSError *error, BOOL finished) = self.didFinished;
            if (didFinished)
                didFinished(self, error, finished);
            if (finished) self.strongSelf = nil;
            strongSelf = nil;
        });
    }
}

// start task
-(void)start {
    int tickCount = 0;
    @synchronized(self) {
        if (self.executing == NO) {
            self.executing = YES;
            if (_autoRetain) self.strongSelf = self;
            self.beginTime = [[NSDate date] timeIntervalSince1970];
            tickCount = _tickCount;
            
            // init SubTask，cancel all executing. Don't handle the subtask which already done. the same as retry
            for (__strong SubTask* item in _subTasks) {
                @synchronized(item) {
                    if (item.executing) {
                        [item cancel];
                        item.compeleted = 0;
                        item.expected = 0;
                        item.progress = 0;
                    }
                }
            }
            [_subTaskDoing removeAllObjects];
            [_itemsExecutingCount removeAllObjects];
        } else {
            return;
        }
    }
    if (tickCount != _tickCount) return;
    [self notifyDidStart:tickCount];
    
    // avoid crash when dealloc
    __strong id strongSelf = self;
    
    // start task
    BOOL finished = NO;
    @synchronized(self) {
        if (tickCount == _tickCount) {
            NSArray<SubTask*>* items = [self selectSubTask];
            if (items && items.count == 0 && _subTaskDoing.count == 0) { // there is no more task, it's done
                _tickCount++;
                self.compeleted = YES;
                self.executing = NO;
                if (_autoRetain) self.strongSelf = nil;
                self.endTime = [[NSDate date] timeIntervalSince1970];
                finished = YES;
            } else if (items.count > 0) {
                [self startSubItems:items];
            }
        }
    }
    
    if (finished)
        [self notifyDidFinish:nil finished:YES tickCount:tickCount];
    strongSelf = nil;
}

// cancel the taskRoute, If task started, the taskDidCancel will be called
-(void)cancel {
    // avoid crash when dealloc
    __strong id strongSelf = self;
    
    BOOL canceled = NO;
    int tickCount = 0;
    @synchronized(self) {
        if (self.executing) {
            self.executing = NO;
            if (_autoRetain) self.strongSelf = nil;
            tickCount = _tickCount;
            _tickCount++;
            canceled = YES;
            BOOL allCanceled = YES;
            for (__strong SubTask* item in _subTasks) {
                allCanceled &= item.canceled;
            }
            if (!allCanceled) {
                for (__strong SubTask* item in _subTasks) {
                    [item cancel];
                }
            }
        }
    }
    if (canceled)
        [self notifyDidCancel:tickCount];
    strongSelf = nil;
}

-(void)startSubItems:(NSArray<SubTask*>*)items {
    for (__strong SubTask* item in items) {
        if ([_subTaskDoing indexOfObjectIdenticalTo:item] == NSNotFound) {
            [_subTaskDoing addObject:item];
            @synchronized(item) {
                [_itemsExecutingCount setObject:@(item.tickCount) forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(item)]];
                [item start];
            }
        }
    }
}

-(BOOL)doContinue:(int)tickCount {
    BOOL finished = NO;
    @synchronized(self) {
        tickCount = _tickCount;
        if (self.executing) {
            NSArray<SubTask*>* items = [self selectSubTask];
            if (items && items.count == 0 && _subTaskDoing.count == 0) { // there is no more task, it's done
                _tickCount++;
                self.compeleted = YES;
                self.executing = NO;
                if (_autoRetain) self.strongSelf = nil;
                self.endTime = [[NSDate date] timeIntervalSince1970];
                finished = YES;
            } else if (items.count > 0) {
                [self startSubItems:items];
            }
        }
    }
    return finished;
}

-(void)tryContinue {
    // avoid crash when dealloc
    __strong id strongSelf = self;
    
    int tickCount = 0;
    BOOL finished = [self doContinue:tickCount];
    if (finished)
        [self notifyDidFinish:nil finished:YES tickCount:tickCount];
    
    strongSelf = nil;
}

-(void)subTaskDidFinish:(SubTask*)item error:(NSError*)error finished:(BOOL)finished {
    // avoid crash when dealloc
    __strong id strongSelf = self;
    
    int tickCount = 0;
    if (finished) {
        BOOL allFinished = NO;
        @synchronized(item) {
            @synchronized(self) {
                tickCount = _tickCount;
                int count = [[_itemsExecutingCount objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(item)]] intValue];
                if (count + 1 != item.tickCount)
                    return;
                
                [self subSubTaskDidFinish:item];
                
                [_subTaskDoing removeObjectIdenticalTo:item];
                [_itemsExecutingCount removeObjectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(item)]];
                if (error != nil) {
                    NSArray<SubTask*>* items = [self selectSubTask];
                    if (items && items.count == 0 && _subTaskDoing.count == 0) { // there is no more task, it's fail
                        _tickCount++;
                        self.compeleted = YES;
                        self.executing = NO;
                        if (_autoRetain) self.strongSelf = nil;
                        self.endTime = [[NSDate date] timeIntervalSince1970];
                        allFinished = YES;
                    } else if (items.count > 0) { // if no, try other possible
                        [self startSubItems:items];
                    }
                }
            }
        }
        if (error == nil) {
            allFinished |= [self doContinue:tickCount];
        }
        if (allFinished)
            [self notifyDidFinish:error finished:YES tickCount:tickCount];
        //else
        //    [self notifyDidFinish:error finished:NO tickCount:tickCount];
    } else {
        //[self notifyDidFinish:error finished:NO tickCount:tickCount];
    }
    strongSelf = nil;
}

-(void)subTaskDidCancel:(SubTask*)item {
    // avoid crash when dealloc
    __strong id strongSelf = self;
    int tickCount = 0;
    
    BOOL didCancel = NO;
    @synchronized(item) {
        int count = [[_itemsExecutingCount objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(item)]] intValue];
        if (count + 1 != item.tickCount)
            return;
        
        NSArray<SubTask*>* items = nil;
        @synchronized(self) {
            tickCount = _tickCount;
            [_subTaskDoing removeObjectIdenticalTo:item];
            [_itemsExecutingCount removeObjectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(item)]];
            items = [self selectSubTask];
            if (items && items.count == 0 && _subTaskDoing.count == 0) { // there is no more task, it's canceled
                _tickCount++;
                self.canceled = YES;
                self.executing = NO;
                if (_autoRetain) self.strongSelf = nil;
                didCancel = YES;
            } else if (items.count > 0) { // if no, try other possible
                [self startSubItems:items];
            }
        }
    }
    if (didCancel)
        [self notifyDidCancel:tickCount];
    strongSelf = nil;
}

-(void)subTaskProgress:(SubTask*)item compeleted:(NSUInteger)compeleted expected:(NSUInteger)expected {
    int tickCount = 0;
    
    NSUInteger allCompeleted = 0;
    NSUInteger allExpected = 0;
    
    @synchronized(self) {
        tickCount = _tickCount;
        @synchronized(item) {
            int count = [[_itemsExecutingCount objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(item)]] intValue];
            if (count != item.tickCount)
                return;
        }
        
        for (__strong SubTask* item in _subTasks) {
            @synchronized(item) {
                allCompeleted += item.compeleted;
                allExpected += item.expected;
            }
        }
        self.compeleted = allCompeleted;
        self.expected = allExpected;
        if (expected != 0)
            self.progress = allCompeleted*1.0/allExpected;
    }
    dispatch_queue_t queue = self.progressQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (tickCount != _tickCount) return;
        void (^taskProgress)(TaskRoute *task, NSUInteger compeleted, NSUInteger expected) = self.progressCallback;
        if (taskProgress)
            taskProgress(self, allCompeleted, allExpected);
    } else {
        dispatch_async(queue, ^{
            if (tickCount != self->_tickCount) return;
            void (^taskProgress)(TaskRoute *task, NSUInteger compeleted, NSUInteger expected) = self.progressCallback;
            if (taskProgress)
                taskProgress(self, allCompeleted, allExpected);
        });
    }
}

// report daily, some task will need a long time, report part by part
-(void)reportDaily {
    int tickCount = 0;
    @synchronized(self) {
        if (self.executing == NO)
            return;
        tickCount = _tickCount;
    }
    
    [self notifyDidFinish:nil finished:YES tickCount:tickCount];
}

// To execute task, need to override method, should return which subtasks should be execute
// return nil-->No sub task should be start right now.
// return empty array-->TaskRoute should be finished.
// return non empty array-->subtasks which should be execute.
-(NSArray<SubTask*>*)selectSubTask {
    if (_subTasks.count == 1) { // if only single task just do it
        SubTask* item = _subTasks[0];
        if (item.finished)
            return @[];
        return _subTasks;
    } else {
        if (_subTaskDoing.count) {
            return nil;
        } else {
            for (SubTask* item in _subTasks) {
                if (item.canceled) return @[];
                if (item.error) return @[];
                if (item.executing) return nil;
                if (!item.finished) return @[item];
            }
        }
        return @[];
    }
}

// When a subTask finished, this method will be called, sub class should gether information from subtask
-(void)subSubTaskDidFinish:(SubTask*)item {
    if (_subTasks.count == 1) { // if only single task just do it
        self.result = item.result;
    }
}

@end
