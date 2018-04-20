//
//  ListVM.h
//  HappyUI
//
//  Created by Aruisi on 2017/7/31.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ListModelStatus) {
    LIST_UNDEFINE,
    LIST_EMEPTY,
    LIST_ERROR,
    LIST_NORMAL,
};

@class TaskRoute;
@interface ListBaseModel : NSObject
@property (nonatomic, readonly) id context; // context
@property (nonatomic, readonly) NSArray *array;
@property (nonatomic, readonly, assign) NSInteger count; // how many items in model, it's equlas array.count
@property (nonatomic, readonly) ListModelStatus status;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readonly, getter=isGettingMore) BOOL gettingMore;
@property (nonatomic, readonly) id extra;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) id lastToken;

@property (nonatomic, copy) void(^refreshDidSuccess)(void);
@property (nonatomic, copy) void(^dataDidChanged)(void);
@property (nonatomic, copy) void(^getmoreDidSucces)(void);
@property (nonatomic, copy) void(^cacheDidLoaded)(void);

-(instancetype)initWithContext:(id)context;

-(void)refresh;
-(void)getMore;

-(void)removeItemAtIndex:(int)index;
-(void)addItem:(id)item index:(int)index;

-(void)saveToCache;

#pragma mark Sub class need to override
-(void)parseResult:(id)result error:(NSError*)error callback:(void (^)(NSArray* items, NSError* error, id lastToken, id extra))callback;
-(TaskRoute*)refreshTask;
-(TaskRoute*)getmoreTask;

-(TaskRoute*)saveCacheTask:(id)value;
-(TaskRoute*)loadCacheTask;

@end
