//
//  HappyVM.h
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, HappyViewModelStatus) {
    VIEW_MODEL_UNDEFINE,
    VIEW_MODEL_EMEPTY,
    VIEW_MODEL_ERROR,
    VIEW_MODEL_NORMAL,
};

@class TaskRoute;
@interface HappyVM : NSObject
@property (nonatomic, readonly) id context; // context
@property (nonatomic, readonly) id model;
@property (nonatomic, readonly) HappyViewModelStatus status;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, copy) void(^refreshDidSuccess)(void);
@property (nonatomic, copy) void(^dataDidChanged)(void);
@property (nonatomic, copy) void(^cacheDidLoaded)(void);

-(instancetype)initWithContext:(id)context;

-(void)refresh;
-(void)cancelRequest;

-(void)saveToCache;

#pragma mark Sub class need to override
-(void)parseResult:(id)result error:(NSError*)error callback:(void (^)(id model, NSError* error))callback;
-(TaskRoute*)refreshTask;

-(TaskRoute*)saveCacheTask:(id)value;
-(TaskRoute*)loadCacheTask;
@end
