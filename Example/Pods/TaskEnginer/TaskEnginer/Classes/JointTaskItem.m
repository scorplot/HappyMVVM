//
//  JointTaskItem.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/30.
//

#import "JointTaskItem.h"
#import "JointTaskManager.h"

@interface JointTaskItem()
@property (nonatomic, copy) id<NSCopying> key;
@property (atomic, weak) JointTaskManager* manager;

@property (nonatomic, assign) NSTimeInterval beginTime; // beginTime
@property (nonatomic, assign) NSTimeInterval endTime; // endTime

@property (nonatomic, assign) NSUInteger compeleted;
@property (nonatomic, assign) NSUInteger expected;
@property (nonatomic, assign) double progress;

@end

@implementation JointTaskItem {
    dispatch_queue_t _callbackQueue;
    dispatch_queue_t _progressQueue;
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

// cancel the taskRoute, If task started, the taskDidCancel will be called
-(void)cancel {
    [_manager cancelWithTask:self];
}
@end
