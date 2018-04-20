//
//  BaseModel.m
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import "BaseModel.h"
#import <TaskEnginer/TaskRoute.h>
#import <RealReachability/RealReachability.h>

@interface BaseModel()
@property (nonatomic, readwrite) id model;
@property (nonatomic, readwrite) BaseModelStatus status;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite, getter=isRefreshing) BOOL refreshing;
@end

@implementation BaseModel {
    TaskRoute* _refreshTask;
    __weak TaskRoute* _saveCacheTask;
    __weak TaskRoute* _loadCacheTask;
}

-(instancetype)initWithContext:(id)context {
    self = [super init];
    if (self) {
        _context = context;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadFromCache];
        });
        
        __weak typeof(self) ws = self;
        [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
            switch (status)
            {
                case RealStatusNotReachable:
                {
                    break;
                }
                    
                case RealStatusViaWiFi:
                case RealStatusViaWWAN:
                {
                    if (ws.status == MODEL_ERROR) [ws refresh];
                    break;
                }
                default:
                    break;
            }
        }];
    }
    return self;
}

-(instancetype)init {
    if (self) {
        NSAssert(false, @"need to use initWithContext:");
    }
    return self;
}

-(void)refresh {
    if (_refreshTask == nil) {
        _refreshTask = [self refreshTask];
        if (_refreshTask) {
            __weak typeof(self) ws = self;
            [_refreshTask setDidFinished:^(TaskRoute *task, NSError *error, BOOL finished) {
                typeof(self) SELF = ws;
                if (SELF) {
                    if (!error) { // if refresh is very fast, so need to cancel load cache
                        [SELF->_loadCacheTask cancel];
                        SELF->_loadCacheTask = nil;
                    }
                    
                    if (finished) {
                        SELF->_refreshTask = nil;
                        SELF.refreshing = NO;
                    }
                    
                    [SELF parseResult:task.result error:(NSError*)error callback:^(id model, NSError* error) {
                        
                        BaseModelStatus status = MODEL_UNDEFINE;
                        if (error) {
                            status = MODEL_ERROR;
                            SELF.error = error;
                        } else {
                            status = MODEL_NORMAL;
                            SELF.error = nil;
                        }
                        
                        if (status != SELF.status) {
                            SELF.status = status;
                        }
                        
                        if (!error) {
                            SELF.model = model;
                            // save to cache
                            [SELF saveToCache];
                            
                            if (SELF.dataDidChanged)
                                SELF.dataDidChanged();
                            if (SELF.refreshDidSuccess && finished)
                                SELF.refreshDidSuccess();
                        }
                    }];
                }
            }];
            self.refreshing = YES;
            [_refreshTask start];
        }
    }
}

-(void)saveToCache {
    if (_status != MODEL_UNDEFINE) {
        TaskRoute* task = [self saveCacheTask:[self.model copy]];
        _saveCacheTask = task;
        task.autoRetain = YES;
        if (_saveCacheTask) {
            [_saveCacheTask start];
        }
    }
}

-(void)loadFromCache {
    __weak typeof(self) ws = self;
    TaskRoute* task = [self loadCacheTask];
    _loadCacheTask = task;
    task.autoRetain = YES;
    if (_loadCacheTask) {
        _loadCacheTask.didFinished = ^(TaskRoute *task, NSError *error, BOOL finished) {
            if (finished && error == nil) {
                typeof(self) SELF = ws;
                if (SELF) {
                    SELF->_loadCacheTask = nil;
                    [SELF parseResult:task.result error:nil callback:^(id model, NSError* error) {
                        int status = SELF.status;
                        
                        if (error) {
                            status = MODEL_ERROR;
                        } else {
                            status = MODEL_NORMAL;
                        }
                        
                        if (status != SELF.status) {
                            SELF.status = status;
                        }

                        if (model) {
                            
                            SELF.model = model;
                            
                            if (SELF.dataDidChanged)
                                SELF.dataDidChanged();
                            if (SELF.cacheDidLoaded)
                                SELF.cacheDidLoaded();
                        }
                    }];
                }
            }
        };
        [_loadCacheTask start];
    }
}

#pragma mark Sub class need to override
-(void)parseResult:(id)result error:(NSError*)error callback:(void (^)(id model, NSError* error))callback {
    callback(result, error);
}

-(TaskRoute*)refreshTask {
    return nil;
}
-(TaskRoute*)saveCacheTask:(id)value {
    return nil;
}
-(TaskRoute*)loadCacheTask {
    return nil;
}
-(void)dealloc{
    [_refreshTask cancel];
    [_loadCacheTask cancel];
}
@end
