//
//  JointSubTask.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/31.
//

#import "JointSubTask.h"
#import "JointTaskManager.h"
#import "JointTaskItem.h"

@implementation JointSubTask {
    __weak JointTaskManager* _manager;
    JointTaskItem* _shared;
}
-(instancetype)initWith:(JointTaskManager*)manager {
    self = [super init];
    if (self) {
        _manager = manager;
    }
    return self;
}

// exuecte task, need override, this method will by called in executingQueue, success return nil, fail return error
-(void)doExecute:(void (^)(NSError* error))block {
    if (self.key == nil) {
        block([[NSError alloc] init]);
    } else {
        __weak typeof(self) ws = self;
        _shared = [_manager request:_key];
        _shared.callbackQueue = self.callbackQueue;
        _shared.progressQueue = self.progressQueue;
        _shared.didStart = ^(JointTaskItem *item) {
            typeof(self) SELF = ws;
            void (^disStart)(SubTask *item) = SELF.didStart;
            if (disStart)
                disStart(SELF);
        };
        _shared.didCancel = ^(JointTaskItem *item) {
            typeof(self) SELF = ws;
            void (^didCancel)(SubTask *item) = SELF.didCancel;
            if (didCancel)
                didCancel(SELF);
            if (SELF) SELF->_shared = nil;
        };
        _shared.didFinished = ^(JointTaskItem *item, NSError *error, BOOL finished) {
            typeof(self) SELF = ws;
            void (^didFinished)(SubTask *item, NSError *error, BOOL finished) = SELF.didFinished;
            if (didFinished)
                didFinished(SELF, error, finished);
            if (SELF) SELF->_shared = nil;
            block(error);
        };
        _shared.progressCallback = ^(JointTaskItem *item, NSUInteger compeleted, NSUInteger expected) {
            typeof(self) SELF = ws;
            void (^progressCallback)(SubTask *item, NSUInteger compeleted, NSUInteger expected) = SELF.progressCallback;
            if (progressCallback)
                progressCallback(SELF, compeleted, expected);
        };
    }
}

// cancel task, need override, this method could be called in any method
-(void)doCancel {
    self.key = nil;
    [_shared cancel];
    _shared = nil;
}

@end
