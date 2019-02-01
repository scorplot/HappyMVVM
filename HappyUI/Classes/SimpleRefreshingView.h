//
//  SimpleRefreshingView.h
//  HappyMVVM
//
//  Created by Aruisi on 4/24/18.
//

#import <UIKit/UIKit.h>
#import "HappyBIProtocal.h"

@interface SimpleRefreshingView : UIView <ScrollRefreshHeaderProtocal>
@property(nonatomic, copy) BOOL (^shouldTrigger)(void);
@property(nonatomic, assign) BOOL refreshing;
@property(nonatomic, assign) CGFloat offsetTrigger; // the offest which should trigger the refresh operation
-(void)scrollOffset:(CGFloat)offset; // each scroll called

@end
