//
//  SimpleRefreshingView.h
//  CCUIModel
//
//  Created by Aruisi on 4/24/18.
//

#import <UIKit/UIKit.h>
#import "HappyBIProtocal.h"

@interface SimpleRefreshingView : UIView <ScrollRefreshHeaderProtocal>
@property(nonatomic, copy) BOOL (^shouldTrigger)(void);
@property(nonatomic, assign) BOOL refreshing;

@end
