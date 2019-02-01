//
//  HappyMVVMProtocal.h
//  Pods
//
//  Created by Aruisi on 4/23/18.
//

#import <Foundation/Foundation.h>

#ifndef HappyMVVMProtocal_h
#define HappyMVVMProtocal_h

@protocol ScrollRefreshHeaderProtocal <NSObject>
@required
@property(nonatomic, copy) BOOL (^shouldTrigger)(void); // should trigger refresh operation
@property(nonatomic, assign) BOOL refreshing; // change the view refesh status
-(void)scrollOffset:(CGFloat)offset; // each scroll called

@end

@protocol ScrollGetMoreFooterProtocal <NSObject>
@required
@property(nonatomic, copy) BOOL (^shouldTrigger)(void); // should trigger get more operation
@property(nonatomic, assign) BOOL gettingMore; // change the view get more status
-(void)scrollOffset:(CGFloat)offset; // each scroll called

@end

#endif /* HappyMVVMProtocal_h */
