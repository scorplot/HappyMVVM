//
//  JointCacheTaskManager.m
//  TaskEnginer
//
//  Created by Aruisi on 2018/5/3.
//

#import "JointCacheTaskManager.h"
#import "TaskRoute.h"
#import <objc/runtime.h>

@interface CacheObject()
@property (nonatomic, readwrite) id value;
@property (nonatomic, readwrite) id old;

@property (nonatomic, readwrite) NSTimeInterval time;
@end

@implementation JointCacheTaskManager {
    NSMapTable *_mapTable;
    NSMutableDictionary *_dic;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        @synchronized (self) {
            _mapTable = [NSMapTable strongToWeakObjectsMapTable];
            _dic = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

-(void)cleanCache {
    @synchronized(self) {
        [_mapTable removeAllObjects];
        [_dic removeAllObjects];
    }
}

-(CacheObject*)objectForKey:(id<NSCopying>)key {
    @synchronized(self) {
        if (key) {
            CacheObject* obj = [_mapTable objectForKey:key];
            if (obj == nil) {
                obj = [self loadCache:key];
                if (obj)
                    [_mapTable setObject:obj forKey:key];
            }
            return obj;
        }
        return nil;
    }
}

-(JointTaskItem*)doSync:(id<NSCopying>)key value:(id)value {
    @synchronized(self) {
        if (key) {
            if (![[_dic objectForKey:key] isEqual:value]) { //if value changed, we need cancel all changed
                [self cancelWithKey:key];
                [_dic setObject:value forKey:key];
            }
            CacheObject* obj = [_mapTable objectForKey:key];
            obj.old = obj.value;
            obj.value = value;
            
            JointTaskItem* task = [super request:key];
            
            static void* key = 0;
            objc_setAssociatedObject(task, &key, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            return task;
        }
        return nil;
    }
}

-(JointTaskItem*)doBatchSync:(NSDictionary<id<NSCopying>, id>*)keyValues {
    @synchronized(self) {
        [keyValues enumerateKeysAndObjectsUsingBlock:^(id<NSCopying>  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            if (![[self->_dic objectForKey:key] isEqual:value]) { //if value changed, we need cancel all changed
                [self cancelWithKey:key];
                [self->_dic setObject:value forKey:key];
            }
            
            CacheObject* obj = [self->_mapTable objectForKey:key];
            obj.old = obj.value;
            obj.value = value;
        }];
        
        JointTaskItem* task = [super request:keyValues.allKeys];
        
        [keyValues enumerateKeysAndObjectsUsingBlock:^(id<NSCopying>  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            
            CacheObject* obj = [self->_mapTable objectForKey:key];
            
            static void* pkey = 0;
            objc_setAssociatedObject(task, &pkey, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
        
        return task;
    }
}


-(void)saveCache:(id<NSCopying>)key value:(id)value time:(NSTimeInterval)time {
    CacheObject* object = [self objectForKey:key];
    // 1. time changed
    // 2. value changed
    // 3. it's not changed for now
    // 3 conditions happens, we can change the value
    if (time > object.time && ![value isEqual:object.value] && ![self isExecuting:key]) {
        object.value = value;
        object.time = time;
        [self doSaveCache:key value:value];
    }
}

-(CacheObject*)loadCache:(id<NSCopying>)key {
    CacheObject* obj = [[CacheObject alloc] init];
    obj.value = [self doLoadCache:key];
    
    id value = [_dic objectForKey:key];
    if (value) {
        obj.old = obj.value;
        obj.value = value;
    }
    return obj;
}

// need to start task, some task is limited, such as big file downloaded, it's should be only one task need to download at a time. sub class need to override this method
-(id<NSCopying>)pickTask {
    NSArray<id<NSCopying>>* keys = [self waittingArray];
    if (keys.count)
        return keys[0];
    return nil;
}

// execute task, override from super
-(TaskRoute*)doExecute:(id<NSCopying>)key {
    if ([(NSObject*)key isKindOfClass:[NSArray class]]) {
        NSArray<id<NSCopying>>* keys = (NSArray<id<NSCopying>>*)key;
        
        NSMutableDictionary* dicValue = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* dicObject = [[NSMutableDictionary alloc] init];
        for (id<NSCopying> key in keys) {
            CacheObject* object = [self objectForKey:key];
            if (object) [dicObject setObject:object forKey:key];
            
            id value = [_dic objectForKey:key];
            if (value) [dicValue setObject:value forKey:key];
        }
        
        TaskRoute* task = [self doTask:keys value:dicValue];
        
        task.didFinished = ^(TaskRoute *task, NSError *error, BOOL finished) {
            if (finished) {
                if (error) {
                    [dicObject enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CacheObject* obj, BOOL * _Nonnull stop) {
                        obj.value = obj.old;
                    }];
                } else {
                    
                    // TODO:@chj
                    //if (![object.value isEqual:task.result])
                    //    object.value = task.result;
                    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                    
                    [dicObject enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CacheObject* object, BOOL * _Nonnull stop) {
                        object.time = time;
                        [self->_dic removeObjectForKey:key];
                        [self doSaveCache:key value:object.value];
                    }];
                }
            }
        };
        
        return task;
    } else {
        CacheObject* object = [self objectForKey:key];
        id value = [_dic objectForKey:key];
        TaskRoute* task = [self doTask:key value:value];
        task.didFinished = ^(TaskRoute *task, NSError *error, BOOL finished) {
            if (finished) {
                if (error) {
                    object.value = object.old;
                } else {
                    
                    if (![object.value isEqual:task.result])
                        object.value = task.result;
                    object.time = [[NSDate date] timeIntervalSince1970];
                    [self->_dic removeObjectForKey:key];
                    [self doSaveCache:key value:object.value];
                }
            }
        };
        return task;
    }
}

#pragma mark 子类需要实现的方法
// 根据key和value持久化保存到文件中
// 举例，key是item_id，value是是否喜欢，把这个关系保存起来
-(void)doSaveCache:(id<NSCopying>)key value:(id)value{
}

// 从持久化的文件中读取内容
// 举例，key是item_id，把是否喜欢从缓存中读取出来
-(id)doLoadCache:(id<NSCopying>)key {
    return nil;
}

// 返回一个任务，是把key对应的值改成value的任务
// 举例，key是item_id，改成喜欢（value是true），或者改成不喜欢（value是false）
-(TaskRoute*)doTask:(id<NSCopying>)key value:(id)value {
    return nil;
}

@end

@implementation CacheObject
@end
