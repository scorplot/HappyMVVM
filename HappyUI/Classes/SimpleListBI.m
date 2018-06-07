//
//  SimpleListBI.m
//  CCUIModel
//
//  Created by Aruisi on 4/13/18.
//

#import "SimpleListBI.h"
#import "LoadFileSubTask.h"
#import "SaveFileSubTask.h"
#import "ListBaseResponse.h"
#import "TaskRoute.h"

@implementation SimpleListBI
-(TaskRoute*)saveCacheTask:(id)value {
    NSString* cacheFile = [self cacheFilePath];
    if (cacheFile) {
        ListBaseResponse* temp = [[ListBaseResponse alloc] init];
        temp.list = [self.array copy];
        temp.extra = self.extra;
        temp.lastToken = self.lastToken;

        // set save file task
        SaveFileSubTask* save = [[SaveFileSubTask alloc] initWithPath:cacheFile value:temp];
        id(^serializeCell)(id) = self.serializeCell;
        id(^serializeExtra)(id) = self.serializeExtra;
        save.serialization = ^NSData *(ListBaseResponse* list) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setValue:list.lastToken forKey:@"lastToken"];
            
            if (list.list && serializeCell) {
                NSMutableArray* array = [[NSMutableArray alloc] init];
                for (id item in list.list) {
                    [array addObject:serializeCell(item)];
                }
                dic[@"list"] = array;
            }
            
            if (serializeExtra) {
                [dic setValue:serializeExtra(list.extra) forKey:@"extra"];
            }

            return [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        };
        
        return [[TaskRoute alloc] initWithSingleTask:save context:self.context];
    }
    return nil;
}

-(TaskRoute*)loadCacheTask {
    NSString* cacheFile = [self cacheFilePath];
    if (cacheFile) {
        LoadFileSubTask* load = [[LoadFileSubTask alloc] initWithPath:cacheFile];
        id(^deSerializeCell)(id) = self.deSerializeCell;
        id(^deSerializeExtra)(id) = self.deSerializeExtra;
        load.parseData = ^id(NSData* data) {
            ListBaseResponse* response = [[ListBaseResponse alloc] init];
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dic) {
                NSArray* list = [dic valueForKey:@"list"];
                if (list) {
                    NSMutableArray* temp = [[NSMutableArray alloc] init];
                    if (deSerializeCell) {
                        for (id item in list) {
                            [temp addObject:deSerializeCell(item)];
                        }
                    }
                    response.list = temp;
                }
                
                if (deSerializeExtra && dic[@"extra"]) {
                    response.extra = deSerializeExtra(dic[@"extra"]);
                }
                
                response.lastToken = dic[@"lastToken"];
            }
            
            return response;
        };
        return [[TaskRoute alloc] initWithSingleTask:load context:self.context];
    }
    return nil;
}

-(NSString*)cacheFilePath {
    return nil;
}

-(id(^)(id))serializeCell {
    return nil;
}
-(id(^)(id))deSerializeCell {
    return nil;
}
-(id(^)(id))serializeExtra {
    return nil;
}
-(id(^)(id))deSerializeExtra {
    return nil;
}

@end
