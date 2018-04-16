//
//  LoadFileTaskItem.m
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/8/5.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "LoadFileSubTask.h"

@implementation LoadFileSubTask {
    NSString* _filePath;
}
-(instancetype)initWithPath:(NSString*)filePath {
    self = [super init];
    if (self) {
        _filePath =  [filePath copy];
        self.callbackQueue = self.executingQueue;
    }
    return self;
}

// 执行任务，需要重载入，此方法将在executingQueue队列中调用，结束的时候调用block，成功error是nil，失败是相应的错误
-(void)doExecute:(void (^)(NSError* error))block {
    NSData* data = [NSData dataWithContentsOfFile:_filePath];
    id obj = nil;
    if (self.parseData)
        obj = self.parseData(data);
    
    self.result = obj;
    block(nil);
}

// 取消任务，需要重载入，此方法有可能在任何方法中调用
-(void)doCancel {
    
}

@end
