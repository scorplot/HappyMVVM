//
//  JointTaskItem.h
//  Pods-TaskEnginer_Example
//
//  Created by Aruisi on 2017/7/30.
//

#import <Foundation/Foundation.h>

@interface JointTaskItem : NSObject
@property (nonatomic, readonly) id<NSCopying> key;

@property (nonatomic, readonly) NSTimeInterval beginTime; // beginTime
@property (nonatomic, readonly) NSTimeInterval endTime; // endTime

// progress
@property (nonatomic, readonly) NSUInteger compeleted;
@property (nonatomic, readonly) NSUInteger expected;
@property (nonatomic, readonly) double progress; // progress = compeleted/expected;


// callback Queue，the default value is dispatch_get_main_queue()
@property (atomic, readwrite) dispatch_queue_t callbackQueue;

// progress callback queue，default value is dispatch_get_main_queue()
@property (atomic, readwrite) dispatch_queue_t progressQueue;

//didStart callback
@property (nonatomic, copy) void (^didStart)(JointTaskItem *item);

//didCancel callback
@property (nonatomic, copy) void (^didCancel)(JointTaskItem *item);

//taskItem did finished block
//This block may be called many times, each call back mean a subTask finished.
//The finished value is YES in last call.
//If finished value is No the error always nil.
@property (nonatomic, copy) void (^didFinished)(JointTaskItem *item, NSError *error, BOOL finished);

//progress callback
@property (nonatomic, copy) void (^progressCallback)(JointTaskItem *item, NSUInteger compeleted, NSUInteger expected);

// cancel the taskRoute, If task started, the taskDidCancel will be called
-(void)cancel;

@end
