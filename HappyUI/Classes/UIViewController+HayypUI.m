//
//  UIViewController+HayypUI.m
//  CCUIModel
//
//  Created by Aruisi on 4/16/18.
//

#import "UIViewController+HayypUI.h"
#import <objc/runtime.h>

@implementation UIViewController (HayypUI)
static void* keyContext;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(instancetype)initWithContext:(nullable HappyContext*)context {
    self = [super init];
    if (self) {
        objc_setAssociatedObject(self, &keyContext, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}
#pragma clang diagnostic pop

-(HappyContext*)context {
    UINavigationController* navi = self.navigationController;
    if (navi) {
        return navi.context;
    }
    return objc_getAssociatedObject(self, &keyContext);
}

@end
