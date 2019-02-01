//
//  UINavigationController+HappyUI.m
//  HappyMVVM
//
//  Created by Aruisi on 4/16/18.
//

#import "UINavigationController+HappyUI.h"
#import <objc/runtime.h>

@implementation UINavigationController (HappyUI)
static void* keyContext;
-(HappyContext*)context {
    return objc_getAssociatedObject(self, &keyContext);
}

-(void)setContext:(HappyContext *)context {
    objc_setAssociatedObject(self, &keyContext, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
