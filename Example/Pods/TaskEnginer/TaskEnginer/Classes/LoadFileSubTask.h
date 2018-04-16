//
//  LoadFileTaskItem.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/8/5.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import "SubTask.h"

@interface LoadFileSubTask : SubTask
-(instancetype)initWithPath:(NSString*)filePath;
@property (nonatomic, copy) id (^parseData)(NSData* data);

@end
