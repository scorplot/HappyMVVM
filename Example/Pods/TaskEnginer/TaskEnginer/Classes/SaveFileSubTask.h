//
//  SaveFileTaskItem.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/8/5.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "SubTask.h"

@interface SaveFileSubTask : SubTask
-(instancetype)initWithPath:(NSString*)filePath value:(id)value;
@property (nonatomic, copy) NSData*(^serialization)(id);

#pragma mark sub class need to override
-(NSData*(^)(id))defaultSerialization;
@end
