//
//  UINavigationController+HappyMVVM.h
//  HappyMVVM
//
//  Created by Aruisi on 4/16/18.
//

#import <UIKit/UIKit.h>
#import "HappyContext.h"

@interface UINavigationController (HappyMVVM)
@property (nonatomic, strong, nullable) HappyContext* context;

@end
