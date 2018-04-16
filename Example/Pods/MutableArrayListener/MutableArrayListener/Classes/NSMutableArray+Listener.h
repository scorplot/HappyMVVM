//
//  NSMutableArray+Listener.h
//  Pods
//
//  Created by aruisi on 2017/7/7.
//
//

#import <Foundation/Foundation.h>
#import "NSMutableArrayListenerDelegate.h"
#import "MutableArrayListener.h"
@interface NSMutableArray (Listener)

@property(nonatomic,weak)id<NSMutableArrayListenerDelegate> delegate;

-(BOOL)hasListener;
/**
 add Listener

 @param listener listener
 */
-(void)addListener:(MutableArrayListener* )listener;

/**
 remove listener

 @param listener listener
 */
-(void)removeListener:(MutableArrayListener * )listener;
@end
