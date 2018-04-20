//
//  SubTask.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/29.
//

#import "SubTask.h"
#import "TaskRoute.h"
#import "CircleReferenceCheck.h"

@interface SubTask()
@property (nonatomic, strong) NSError* error; // error

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
-(void)subTaskDidFinish:(SubTask*)subTask error:(NSError*)error finished:(BOOL)finished;
-(void)subTaskDidCancel:(SubTask*)subTask;
-(void)subTaskProgress:(SubTask*)subTask compeleted:(NSUInteger)compeleted expected:(NSUInteger)expected;
@end

@implementation SubTask {
    dispatch_queue_t _callbackQueue;
    dispatch_queue_t _progressQueue;
    dispatch_queue_t _executingQueue;
    
    float _weight;
}

-(id)context {
    return self.task.context;
}

-(void)setSubTaskDidStart:(void (^)(SubTask *))taskItemDidStart {
    _didStart = taskItemDidStart;
    NSAssert(!checkCircleReference(taskItemDidStart, self), @"raise a block circle reference");
}

-(void)setSubTaskDidCancel:(void (^)(SubTask *))taskItemDidCancel {
    _didCancel = taskItemDidCancel;
    NSAssert(!checkCircleReference(taskItemDidCancel, self), @"raise a block circle reference");
}

-(void)setSubTaskDidFinished:(void (^)(SubTask *, NSError *, BOOL))taskItemDidFinished {
    _didFinished = taskItemDidFinished;
    NSAssert(!checkCircleReference(taskItemDidFinished, self), @"raise a block circle reference");
}

-(void)setSubTaskProgress:(void (^)(SubTask *, NSUInteger, NSUInteger))taskItemProgress {
    _progressCallback = taskItemProgress;
    NSAssert(!checkCircleReference(taskItemProgress, self), @"raise a block circle reference");
}

-(void)dealloc {
    
}
-(float)weight {
    return _weight + 1;
}
-(void)setWeight:(float)weight {
    _weight = weight - 1;
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

// start task
-(void)start {
    @synchronized(self) {
        int tickCount = _tickCount;
        self.executing = YES;
        self.finished = NO;
        self.error = nil;
        self.beginTime = [[NSDate date] timeIntervalSince1970];
        dispatch_async(self.executingQueue, ^{
            @autoreleasepool {
                if (tickCount != _tickCount) return;
                
                if (self.willStart)
                    self.willStart(self);
                
                if (tickCount != _tickCount) return;
                // did start
                [self notifyDidStart:tickCount];
                
                if (tickCount != _tickCount) return;
                // do execute
                [self doExecute:^(NSError *error) {
                    // task over
                    @synchronized(self) {
                        if (tickCount != _tickCount) return;
                        self.executing = NO;
                        self.finished = YES;
                        self.endTime = [[NSDate date] timeIntervalSince1970];
                        _tickCount++;
                    }
                    [self notifyDidFinish:error finished:YES tickCount:tickCount];
                }];
            }
        });
    }
}

//callback did start
-(void)notifyDidStart:(int)tickCount {
    dispatch_queue_t queue = self.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (tickCount != _tickCount) return;
        void (^didStart)(SubTask *item) = self.didStart;
        if (didStart)
            didStart(self);
    } else {
        dispatch_async(queue, ^{
            if (tickCount != _tickCount) return;
            void (^didStart)(SubTask *item) = self.didStart;
            if (didStart)
                didStart(self);
        });
    }
}

//callback did cancel
-(void)notifyDidCancel:(int)tickCount {
    dispatch_queue_t queue = self.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (tickCount + 1 != _tickCount) return;
        void (^didCancel)(SubTask *item) = self.didCancel;
        if (didCancel)
            didCancel(self);
        [_task subTaskDidCancel:self];
    } else {
        dispatch_async(queue, ^{
            if (tickCount + 1 != _tickCount) return;
            void (^didCancel)(SubTask *item) = self.didCancel;
            if (didCancel)
                didCancel(self);
            [_task subTaskDidCancel:self];
        });
    }
}

//callback did finish, if error is not nil, the error occues
-(void)notifyDidFinish:(NSError*)error finished:(BOOL)finished tickCount:(int)tickCount {
    dispatch_queue_t queue = self.callbackQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (!finished && tickCount != _tickCount) return;
        if (finished && tickCount + 1 != _tickCount) return;
        self.error = error;
        void (^didFinished)(SubTask *subTask, NSError *error, BOOL finished) = self.didFinished;
        if (didFinished)
            didFinished(self, error, finished);
        [_task subTaskDidFinish:self error:error finished:finished];
    } else {
        dispatch_async(queue, ^{
            if (!finished && tickCount != _tickCount) return;
            if (finished && tickCount + 1 != _tickCount) return;
            self.error = error;
            void (^didFinished)(SubTask *subTask, NSError *error, BOOL finished) = self.didFinished;
            if (didFinished)
                didFinished(self, error, finished);
            [_task subTaskDidFinish:self error:error finished:finished];
        });
    }
}

//report progress
-(void)notifyProgress:(NSInteger)compeleted expected:(NSInteger)expected{
    int tickCount = 0;
    @synchronized(self) {
        if (self.executing == NO)
            return;
        tickCount = _tickCount;
    }
    [self notifyProgress:compeleted expected:expected tickCount:tickCount];
}

//report progress
-(void)notifyProgress:(NSInteger)compeleted expected:(NSInteger)expected tickCount:(int)tickCount{
    @synchronized(self) {
        self.compeleted = compeleted;
        self.expected = expected;
        if (expected != 0)
            self.progress = compeleted*1.0/expected;
    }
    dispatch_queue_t queue = self.progressQueue;
    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        if (tickCount != _tickCount) return;
        void (^progressCallback)(SubTask *subTask, NSUInteger compeleted, NSUInteger expected) = self.progressCallback;
        if (progressCallback)
            progressCallback(self, compeleted, expected);
        [_task subTaskProgress:self compeleted:compeleted expected:expected];
    } else {
        dispatch_async(queue, ^{
            if (tickCount != _tickCount) return;
            void (^progressCallback)(SubTask *subTask, NSUInteger compeleted, NSUInteger expected) = self.progressCallback;
            if (progressCallback)
                progressCallback(self, compeleted, expected);
        });
        [_task subTaskProgress:self compeleted:compeleted expected:expected];
    }
}
// For a long time taskRoute, we can report result part by part.
// Call this method to report result partly.
-(void)reportDaily {
    int tickCount = 0;
    @synchronized(self) {
        if (self.executing == NO)
            return;
        tickCount = _tickCount;
    }
    [self notifyDidFinish:nil finished:NO tickCount:tickCount];
}

// cancel the taskRoute, If task started, the taskDidCancel will be called
-(void)cancel {
    int tickCount = 0;
    BOOL needCancel = NO;
    @synchronized(self) {
        if (self.executing) {
            [self doCancel];
            self.executing = NO;
            tickCount = _tickCount;
            needCancel = YES;
        }
        _tickCount++;
    }
    if (needCancel) {
        [self notifyDidCancel:tickCount];
    }
}

// exuecte task, need override, this method will by called in executingQueue, success return nil, fail return error
-(void)doExecute:(void (^)(NSError* error))block {
}

// cancel task, need override, this method could be called in any method
-(void)doCancel {
    
}

@end
