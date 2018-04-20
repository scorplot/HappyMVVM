//
//  ListVM.m
//  HappyUI
//
//  Created by Aruisi on 2017/7/31.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "ListBaseModel.h"
#import "ListBaseResponse.h"
#import <TaskEnginer/TaskRoute.h>
#import <RealReachability/RealReachability.h>

@interface ListBaseModel()
@property (nonatomic, readwrite) ListModelStatus status;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readwrite, getter=isGettingMore) BOOL gettingMore;
@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, assign, readwrite) NSInteger count;
@property (nonatomic, readwrite) id extra;
@end

@implementation ListBaseModel {
    NSMutableArray *_array;
    TaskRoute* _refreshTask;
    TaskRoute* _getMoreTask;
    __weak TaskRoute* _saveCacheTask;
    __weak TaskRoute* _loadCacheTask;
}

-(instancetype)initWithContext:(id)context {
    self = [super init];
    if (self) {
        _context = context;
        _array = [[NSMutableArray alloc] init];
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
                    if (ws.status == ERROR) [ws refresh];
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
            // if getting more now, we need to cancel getting more
            if (_gettingMore) {
                [_getMoreTask cancel];
                _getMoreTask = nil;
                self.gettingMore = NO;
            }
            __weak typeof(self) ws = self;
            __block BOOL _first = YES; // if the first callback when refresh
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
                    
                    [SELF parseResult:task.result error:(NSError*)error callback:^(NSArray *items, NSError *error, NSObject* lastToken, id extra) {
                        
                        ListModelStatus status = UNDEFINE;
                        if (items.count > 0) {
                            status = NORMAL;
                            SELF.error = nil;
                        } else if (finished) {
                            if (error) {
                                SELF.error = error;
                                status = ERROR;
                            } else {
                                SELF.error = nil;
                                status = EMEPTY;
                            }
                        }
                        
                        if (status != SELF.status) {
                            SELF.status = status;
                        }

                        if (!error) {
                            SELF.extra = extra;
                            if (_first) {
                                _first = NO;
                                [(NSMutableArray*)SELF.array removeAllObjects];
                                SELF.hasMore = NO;
                            }
                            if (finished) {
                                SELF->_lastToken = lastToken;
                                SELF.hasMore = lastToken != nil;
                            }
                            NSMutableArray* temp = [[NSMutableArray alloc] init];
                            for (NSObject* obj in items) {
                                if ([SELF.array indexOfObjectIdenticalTo:obj] == NSNotFound)
                                    [temp addObject:obj];
                            }
                            [(NSMutableArray*)SELF.array addObjectsFromArray:temp];
                            SELF.count = SELF.array.count;
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
    if (_status != UNDEFINE) {
        TaskRoute* task = [self saveCacheTask:[self.array copy]];
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
                    [SELF parseResult:task.result error:nil callback:^(NSArray *items, NSError *error, id lastToken, id extra) {
                        if (items) {
                            int status = SELF.status;
                            if (status == UNDEFINE || status == ERROR) {
                                SELF->_lastToken = lastToken;
                                SELF.hasMore = lastToken != nil;
                                
                                [(NSMutableArray*)SELF.array addObjectsFromArray:items];
                                SELF.count = SELF.array.count;
                            }
                            
                            if (SELF.array.count > 0) {
                                status = NORMAL;
                            } else {
                                status = EMEPTY;
                            }
                            
                            if (status != SELF.status) {
                                SELF.status = status;
                            }
                            
                            if (SELF.dataDidChanged)
                                SELF.dataDidChanged();
                            if (SELF.cacheDidLoaded)
                                SELF.cacheDidLoaded();
                        }
                        
                        if (!error) {
                            SELF.extra = extra;
                        }
                    }];
                }
            }
        };
        [_loadCacheTask start];
    }
}

-(void)getMore {
    if (_getMoreTask == nil && _hasMore && _refreshing == NO && _gettingMore == NO) {
        _getMoreTask = [self getmoreTask];
        if (_getMoreTask) {
            __weak typeof(self) ws = self;
            [_getMoreTask setDidFinished:^(TaskRoute *task, NSError *error, BOOL finished) {
                typeof(self) SELF = ws;
                if (SELF) {
                    if (finished) {
                        SELF->_getMoreTask = nil;
                        SELF.gettingMore = NO;
                    }
                    [SELF parseResult:task.result error:(NSError*)error callback:^(NSArray *items, NSError *error, NSObject* lastToken, id extra) {
                        if (!error) {
                            NSMutableArray* temp = [[NSMutableArray alloc] init];
                            for (NSObject* obj in items) {
                                if ([SELF.array indexOfObjectIdenticalTo:obj] == NSNotFound)
                                    [temp addObject:obj];
                            }
                            [(NSMutableArray*)SELF.array addObjectsFromArray:temp];
                            SELF.count = SELF.array.count;

                            SELF.extra = extra;
                            
                            if (finished) {
                                SELF->_lastToken = lastToken;
                                SELF.hasMore = lastToken != nil;
                            }
                            
                            if (SELF.dataDidChanged)
                                SELF.dataDidChanged();
                            if (SELF.getmoreDidSucces)
                                SELF.getmoreDidSucces();
                        }
                    }];
                }
            }];
            self.gettingMore = YES;
            [_getMoreTask start];
        }
    }
}

-(void)removeItemAtIndex:(int)index {
    if (index >= 0 && index < _array.count) {
        [_array removeObjectAtIndex:index];
        self.count--;
        if (_array.count == 0) {
            self.status = EMEPTY;
        }
    }
}

-(void)addItem:(id)item index:(int)index {
    if (index >= 0 && index <= _array.count && item) {
        if (_array.count == 0) {
            self.status = NORMAL;
            [_array addObject:item];
        }else {
            [_array insertObject:item atIndex:index];
        }
        self.count++;
    }
}

#pragma mark Sub class need to override
-(void)parseResult:(ListBaseResponse*)result error:(NSError*)error callback:(void (^)(NSArray* items, NSError* error, id lastToken, id extra))callback {
    callback(result.list, error, result.list.count?[NSNull null]:nil, result.extra);
}

-(TaskRoute*)refreshTask {
    return nil;
}
-(TaskRoute*)getmoreTask {
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
    [_getMoreTask cancel];
    [_loadCacheTask cancel];
}
@end
