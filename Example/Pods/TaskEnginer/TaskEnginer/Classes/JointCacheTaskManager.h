//
//  JointCacheTaskManager.h
//  TaskEnginer
//
//  Created by Aruisi on 2018/5/3.
//

#import "JointTaskManager.h"

@interface CacheObject : NSObject
@property (nonatomic, readonly) id value;
@end

@class TaskRoute;
@class JointSubTask;
@interface JointCacheTaskManager : JointTaskManager

-(CacheObject*)objectForKey:(id<NSCopying>)key;

// try to synchnonized key=value to web server. local cache changed in memory,
// when succ save to file, if not restore value
-(JointTaskItem*)doSync:(id<NSCopying>)key value:(id)value;

// try to sunchornized keys=values to web server. local cache changed in memory,
// when succ save to file, if not restore value
-(JointTaskItem*)doBatchSync:(NSDictionary<id<NSCopying>, id>*)keyValues;

// update key=value into cache with time
-(void)saveCache:(id<NSCopying>)key value:(id)value time:(NSTimeInterval)time;

// clean all cache
-(void)cleanCache;

#pragma mark 子类需要实现的方法
// 根据key和value持久化保存到文件中
// 举例，key是item_id，value是是否喜欢，把这个关系保存起来
-(void)doSaveCache:(id<NSCopying>)key value:(id)value;

// 从持久化的文件中读取内容
// 举例，key是item_id，把是否喜欢从缓存中读取出来
-(id)doLoadCache:(id<NSCopying>)key;

// 返回一个任务，是把key对应的值改成value的任务
// 举例，key是item_id，改成喜欢（value是true），或者改成不喜欢（value是false）
-(TaskRoute*)doTask:(id<NSCopying>)key value:(id)value;
@end
