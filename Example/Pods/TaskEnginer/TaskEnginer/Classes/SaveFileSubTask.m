//
//  SaveFileTaskItem.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/8/5.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "SaveFileSubTask.h"

@implementation SaveFileSubTask {
    NSString* _filePath;
    id _value;
    BOOL _first;
}
-(instancetype)initWithPath:(NSString*)filePath value:(id)value {
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        _value = value;
    }
    return self;
}

// 执行任务，需要重载入，此方法将在executingQueue队列中调用，结束的时候调用block，成功error是nil，失败是相应的错误
-(void)doExecute:(void (^)(NSError* error))block {
    NSData* data = nil;
    if (_serialization) {
        data = _serialization(_value);
    }
    
    if (data) {
        [data writeToFile:_filePath atomically:YES];
    } else {
        [[[NSFileManager alloc] init] removeItemAtPath:_filePath error:nil];
    }
    block(nil);
}

// 取消任务，需要重载入，此方法有可能在任何方法中调用
-(void)doCancel {
    
}

-(NSData*(^)(id))serialization {
    if (_first == NO) {
        _first = YES;
        
        if (_serialization == nil) {
            _serialization = [self defaultSerialization];
        }
    }
    return _serialization;
}

-(NSData*(^)(id))defaultSerialization {
    return nil;
}

@end
