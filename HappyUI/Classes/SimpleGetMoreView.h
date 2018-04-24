//
//  SimpleGetMoreView.h
//  CCUIModel
//
//  Created by Aruisi on 4/24/18.
//

#import <UIKit/UIKit.h>
#import "HappyBIProtocal.h"

@interface SimpleGetMoreView : UIView<ScrollGetMoreFooterProtocal>
@property(nonatomic, copy) BOOL (^shouldTrigger)(void);
@property(nonatomic, assign) BOOL gettingMore;

@end
