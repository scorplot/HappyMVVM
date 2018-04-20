//
//  SimpleBaseModel.m
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import "SimpleBaseModel.h"
#import "LoadFileSubTask.h"
#import "SaveFileSubTask.h"
#import "TaskRoute.h"

@implementation SimpleBaseModel
-(TaskRoute*)saveCacheTask:(id)value {
    NSString* cacheFile = [self cacheFilePath];
    if (cacheFile) {
        // set save file task
        SaveFileSubTask* save = [[SaveFileSubTask alloc] initWithPath:cacheFile value:value];
        id(^serialize)(id) = self.serialize;
        save.serialization = ^NSData *(id value) {
            return [NSJSONSerialization dataWithJSONObject:serialize(value) options:0 error:nil];
        };
        
        return [[TaskRoute alloc] initWithSingleTask:save context:self.context];
    }
    return nil;
}

-(TaskRoute*)loadCacheTask {
    NSString* cacheFile = [self cacheFilePath];
    if (cacheFile) {
        LoadFileSubTask* load = [[LoadFileSubTask alloc] initWithPath:cacheFile];
        id(^deSerialize)(id) = self.deSerialize;
        load.parseData = ^id(NSData* data) {
            id value = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json) {
                value = deSerialize(json);
            }
            return value;
        };
        return [[TaskRoute alloc] initWithSingleTask:load context:self.context];
    }
    return nil;
}

-(NSString*)cacheFilePath {
    return nil;
}
-(id(^)(id))serialize {
    return nil;
}
-(id(^)(id))deSerialize {
    return nil;
}
@end
