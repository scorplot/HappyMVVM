//
//  HappyBIProtocal.h
//  Pods
//
//  Created by Aruisi on 4/23/18.
//

#import <Foundation/Foundation.h>

#ifndef HappyBIProtocal_h
#define HappyBIProtocal_h

@protocol ScrollRefreshHeaderProtocal <NSObject>
@required
@property(nonatomic, copy) BOOL (^shouldTrigger)(void);
@property(nonatomic, assign) BOOL refreshing;

@end

@protocol ScrollGetMoreFooterProtocal <NSObject>
@required
@property(nonatomic, copy) BOOL (^shouldTrigger)(void);
@property(nonatomic, assign) BOOL gettingMore;

@end

#endif /* HappyBIProtocal_h */
