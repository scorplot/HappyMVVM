//
//  BaseModel.h
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, BaseModelStatus) {
    UNDEFINE,
    ERROR,
    NORMAL,
};

@class TaskRoute;
@interface BaseModel : NSObject
@property (nonatomic, readonly) id context; // context
@property (nonatomic, readonly) id model;
@property (nonatomic, readonly) BaseModelStatus status;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, copy) void(^refreshDidSuccess)(void);
@property (nonatomic, copy) void(^dataDidChanged)(void);
@property (nonatomic, copy) void(^cacheDidLoaded)(void);

-(instancetype)initWithContext:(id)context;

-(void)refresh;

-(void)saveToCache;

#pragma mark Sub class need to override
-(void)parseResult:(id)result error:(NSError*)error callback:(void (^)(id model, NSError* error))callback;
-(TaskRoute*)refreshTask;

-(TaskRoute*)saveCacheTask:(id)value;
-(TaskRoute*)loadCacheTask;
@end
