//
//  JointSubTask.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/31.
//

#import "SubTask.h"

@class JointTaskManager;
@interface JointSubTask : SubTask
@property (nonatomic, readwrite) id<NSCopying> key;

-(instancetype)initWith:(JointTaskManager*)manager;
@end
