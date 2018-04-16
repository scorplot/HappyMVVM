//
//  UIView+HappyUI.h
//  CCUIModel
//
//  Created by Aruisi on 4/16/18.
//

#import <UIKit/UIKit.h>
#import "HappyContext.h"

@interface UIView (HappyUI)
@property (nonatomic, readonly, nullable) HappyContext* context;
+(id)loadNibWithBundle:(NSBundle*)bundle nibName:(NSString*)nibName owner:(id)owner context:(HappyContext*)context;
+(id)loadNibWithMainBundle:(NSString*)nibName owner:(id)owner context:(HappyContext*)context;

- (UIViewController *)viewController;
- (UINavigationController *)navigationController;

@end

@interface UITableViewCell(HappyUI)
@property (nonatomic, weak) UITableView* tableView;
@end
