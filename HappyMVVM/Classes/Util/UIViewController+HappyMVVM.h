//
//  UIViewController+HappyMVVM.h
//  HappyMVVM
//
//  Created by Aruisi on 4/16/18.
//

#import <UIKit/UIKit.h>
#import "HappyContext.h"

@interface UIViewController (HappyMVVM)
@property (nonatomic, readonly, nullable) HappyContext* context;
-(instancetype)initWithContext:(nullable HappyContext*) context;

@end
