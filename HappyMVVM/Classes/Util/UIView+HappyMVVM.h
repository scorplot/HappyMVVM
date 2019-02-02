//
//  UIView+HappyMVVM.h
//  HappyMVVM
//
//  Created by Aruisi on 4/16/18.
//

#import <UIKit/UIKit.h>
#import "HappyContext.h"

@interface UIView (HappyMVVM)
@property (nonatomic, readonly) HappyContext* context;
+(id)loadNibWithBundle:(NSBundle*)bundle nibName:(NSString*)nibName owner:(id)owner context:(HappyContext*)context;
+(id)loadNibWithMainBundle:(NSString*)nibName owner:(id)owner context:(HappyContext*)context;

- (UIViewController *)viewController;
- (UINavigationController *)navigationController;

@end

@interface UITableViewCell(HappyMVVM)
@property (nonatomic, weak) UITableView* tableView;
@end
