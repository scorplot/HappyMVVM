//
//  UIView+HappyUI.m
//  CCUIModel
//
//  Created by Aruisi on 4/16/18.
//

#import "UIView+HappyUI.h"
#import "UINavigationController+HappyUI.h"
#import <objc/runtime.h>

@implementation UITableViewCell(Context)
static void* pKeyTableView = nil;
-(void)setTableView:(UITableView *)tableView {
    objc_setAssociatedObject(self, &pKeyTableView, tableView, OBJC_ASSOCIATION_ASSIGN);
}
-(UITableView*)tableView {
    return objc_getAssociatedObject(self, &pKeyTableView);
}
@end


@implementation UIView (HappyUI)
typedef id (*UITableView_dequeueReusableCellWithIdentifier_IMP)(id self, SEL _cmd, NSString* identifier);
static UITableView_dequeueReusableCellWithIdentifier_IMP original_UITableView_dequeueReusableCellWithIdentifier = nil;
static id replaced_UITableView_dequeueReusableCellWithIdentifier(id self, SEL _cmd, NSString* identifier) {
    UITableViewCell* cell = original_UITableView_dequeueReusableCellWithIdentifier(self, _cmd, identifier);
    cell.tableView = self;
    return cell;
}

typedef id (*UITableView_dequeueReusableCellWithIdentifierForIndex_IMP)(id self, SEL _cmd, NSString* identifier, NSIndexPath* indexPath);
static UITableView_dequeueReusableCellWithIdentifierForIndex_IMP original_UITableView_dequeueReusableCellWithIdentifierForIndex = nil;
static id replaced_UITableView_dequeueReusableCellWithIdentifierForIndex(id self, SEL _cmd, NSString* identifier, NSIndexPath* indexPath) {
    UITableViewCell* cell =  original_UITableView_dequeueReusableCellWithIdentifierForIndex(self, _cmd, identifier, indexPath);
    cell.tableView = self;
    return cell;
}

+(void)load {
    Method method;
    
    method = class_getInstanceMethod([UITableView class], @selector(dequeueReusableCellWithIdentifier:));
    original_UITableView_dequeueReusableCellWithIdentifier = (UITableView_dequeueReusableCellWithIdentifier_IMP)method_setImplementation(method, (IMP)replaced_UITableView_dequeueReusableCellWithIdentifier);
    
    method = class_getInstanceMethod([UITableView class], @selector(dequeueReusableCellWithIdentifier:forIndexPath:));
    original_UITableView_dequeueReusableCellWithIdentifierForIndex = (UITableView_dequeueReusableCellWithIdentifierForIndex_IMP)method_setImplementation(method, (IMP)replaced_UITableView_dequeueReusableCellWithIdentifierForIndex);
}

static HappyContext* __context;
+(id)loadNibWithBundle:(NSBundle*)bundle nibName:(NSString*)nibName owner:(id)owner context:(HappyContext*)context {
    __context = context;
    id view = [[bundle loadNibNamed:nibName owner:owner options:nil] objectAtIndex:0];
    __context = nil;
    return view;
}
+(id)loadNibWithMainBundle:(NSString*)nibName owner:(id)owner context:(HappyContext*)context {
    return [self loadNibWithBundle:[NSBundle mainBundle] nibName:nibName owner:owner context:context];
}

-(HappyContext*)context {
    UINavigationController* navi = self.viewController.navigationController;
    if (navi) {
        return navi.context;
    }
    
    if ([self isKindOfClass:[UITableViewCell class]]) {
        UIView* tableView = [(UITableViewCell*)self tableView];
        if (tableView)
            return tableView.context;
    }
    return __context;
}

- (UIViewController *)viewController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (UINavigationController *)navigationController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)responder;
        }
    }
    return nil;
}
@end
