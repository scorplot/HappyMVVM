//
//  NSMutableArray+Listener.m
//  Pods
//
//  Created by aruisi on 2017/7/7.
//
//

#import "NSMutableArray+Listener.h"
#import <objc/runtime.h>
#import "CircleReferenceCheck.h"


static NSMutableDictionary<NSValue*,NSNumber*>* __tickCount;

static NSInteger increaseCount(){
    @synchronized (__tickCount) {
        if(!__tickCount){
            __tickCount =[NSMutableDictionary dictionary];
        }
        NSInteger number = [[__tickCount objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])] ]integerValue];
        number+=1;
        [__tickCount setObject:@(number) forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])]];
        return number;
    }
}
static void decreaseCount(){
    @synchronized (__tickCount) {
        NSInteger number = [[__tickCount objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])] ]integerValue];
        [__tickCount setObject:@(number-1) forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])]];
    }
}

@interface NSMutableArray (Private)
@property (nonatomic,strong) NSMutableArray * listeners;
@end

@implementation NSMutableArray (Private)
static void* __keyListeners;
-(void)setListeners:(NSMutableArray *)listeners{
    objc_setAssociatedObject(self, &__keyListeners, listeners, OBJC_ASSOCIATION_RETAIN);
}
-(NSMutableArray *)listeners{
    id obj = objc_getAssociatedObject(self, &__keyListeners);
    if (!obj) {
        obj =[NSMutableArray array];
        objc_setAssociatedObject(self, &__keyListeners, obj, OBJC_ASSOCIATION_RETAIN);
    }
    return obj;
}
@end

#pragma mark  - remove

typedef void (*removeObjectAtIndex_IMP)(id self,SEL _cmd, NSUInteger index);
static removeObjectAtIndex_IMP origin_removeObjectAtIndex_IMP = nil;
static void replace_removeObjectAtIndex_IMP(id self, SEL _cmd ,NSUInteger index){
    
        NSMutableArray* array = self;

    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count>0) {
        NSInteger number = increaseCount();
        
        NSObject * object ;
        if (array.count > 0 && index<array.count) {
           object = [self objectAtIndex:index];
        }
        origin_removeObjectAtIndex_IMP(self,_cmd,index);
        if (number==1) {
            [array.delegate mutableArray:self didDeleteObjects:@[object] atIndexes:[NSIndexSet indexSetWithIndex:index]];
            for (MutableArrayListener* server in array.listeners) {
                if (server.didDeleteObjects) {
                    server.didDeleteObjects(self, @[object], [NSIndexSet indexSetWithIndex:index]);
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeObjectAtIndex_IMP(self,_cmd,index);
    }
}
#pragma mark - bath remove
typedef void (*removeObject_IMP)(id self,SEL _cmd,id anObject );
static removeObject_IMP origin_removeObject_IMP = nil;
static void replace_removeObject_IMP(id self,SEL _cmd ,id anObject){
    NSMutableArray * array  = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate) ]&& [array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count>0 ) {
        NSInteger number = increaseCount();
        NSIndexSet * indexset = [self indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([anObject isEqual:obj]) {
                return YES;
            }else{
                return NO;
            }
        }];
        origin_removeObject_IMP(self,_cmd,anObject);
        
        if (number==1) {
            [array.delegate mutableArray:self didDeleteObjects:anObject?@[anObject]:nil atIndexes:indexset];
            for (MutableArrayListener * server in array.listeners) {
                if (server.didDeleteObjects) {
                    server.didDeleteObjects(self, anObject?@[anObject]:nil, indexset);
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeObject_IMP(self,_cmd,anObject);
    }
}

typedef void (*removeAllObjects_IMP)(id self,SEL _cmd );
static removeAllObjects_IMP origin_removeAllObjects_IMP = nil;
static void replace_removeAllObjects_IMP(id self,SEL _cmd){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count>0) {
        NSInteger number = increaseCount();
        origin_removeAllObjects_IMP(self,_cmd);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            NSArray *tempArray = [array.listeners copy];
            for (MutableArrayListener * server in tempArray) {
                if (server.didChanged) {
                    server.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeAllObjects_IMP(self,_cmd);
    }
}

typedef void (*removeObject_inRange_IMP)(id self,SEL _cmd ,id anObject,NSRange range);
static removeObject_inRange_IMP origin_removeObject_inRange_IMP = nil;
static void replace_removeObject_inRange_IMP(id self,SEL _cmd,id anObject,NSRange range){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count>0) {
        NSInteger number = increaseCount();
        NSIndexSet * indexset = [self indexesOfObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([anObject isEqual:obj]) {
                return YES;
            }else{
                return NO;
            }
        }];
        origin_removeObject_inRange_IMP(self,_cmd,anObject,range);
        if (number==1) {
             [array.delegate mutableArray:self didDeleteObjects:@[anObject] atIndexes:indexset];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didDeleteObjects) {
                    observer.didDeleteObjects(self, @[anObject], indexset);
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeObject_inRange_IMP(self,_cmd,anObject,range);
    }
    
}

typedef void (*removeObjectIdenticalTo_inRange_IMP)(id self,SEL _cmd ,id anObject, NSRange range);
static removeObjectIdenticalTo_inRange_IMP origin_removeObjectIdenticalTo_inRange_IMP = nil;
static void replace_removeObjectIdenticalTo_inRange_IMP(id self,SEL _cmd,id anObject,NSRange range){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count>0 ) {
        NSInteger number = increaseCount();
        NSIndexSet * indexset = [self indexesOfObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([anObject isEqual:obj]) {
                return YES;
            }else{
                return NO;
            }
        }];
        origin_removeObjectIdenticalTo_inRange_IMP(self,_cmd,anObject,range);
        if (number==1) {
            [array.delegate mutableArray:self didDeleteObjects:@[anObject] atIndexes:indexset];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didDeleteObjects) {
                    observer.didDeleteObjects(self, @[anObject], indexset);
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeObjectIdenticalTo_inRange_IMP(self,_cmd,anObject,range);
    }
    
}

typedef void (*removeObjectIdenticalTo_IMP)(id self,SEL _cmd ,id anObject);
static removeObjectIdenticalTo_IMP origin_removeObjectIdenticalTo_IMP = nil;
static void replace_removeObjectIdenticalTo_IMP(id self,SEL _cmd,id anObject){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count>0) {
        NSInteger number = increaseCount();
        NSIndexSet * indexset = [self indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([anObject isEqual:obj]) {
                return YES;
            }else{
                return NO;
            }
        }];
        origin_removeObjectIdenticalTo_IMP(self,_cmd,anObject);
        if (number==1) {
            if (indexset.count) {
                [array.delegate mutableArray:self didDeleteObjects:@[anObject] atIndexes:indexset];
                for (MutableArrayListener * observer in array.listeners) {
                    if (observer.didDeleteObjects) {
                        observer.didDeleteObjects(self, @[anObject], indexset);
                    }
                }
            }
       
        }
        decreaseCount();
    }else{
        origin_removeObjectIdenticalTo_IMP(self,_cmd,anObject);
    }
    
}

typedef void (*removeObjectsInArray_IMP)(id self,SEL _cmd ,NSArray * otherArray);
static removeObjectsInArray_IMP origin_removeObjectsInArray_IMP = nil;
static void replace_removeObjectsInArray_IMP(id self,SEL _cmd,NSArray * otherArray){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count>0 ) {
        NSInteger number = increaseCount();
        NSIndexSet * indexset = [self indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([otherArray containsObject:obj]) {
                return YES;
            }else{
                return NO;
            }
        }];
        NSArray * deleteArray = [self objectsAtIndexes:indexset];
        origin_removeObjectsInArray_IMP(self,_cmd,otherArray);
        if (number==1) {
            if (indexset.count) {
                [array.delegate mutableArray:self didDeleteObjects:deleteArray atIndexes:indexset];
                for (MutableArrayListener * observer in array.listeners) {
                    if (observer.didDeleteObjects) {
                        observer.didDeleteObjects(self, deleteArray, indexset);
                    }
                }
            }
           
        }
        decreaseCount();
    }else{
        origin_removeObjectsInArray_IMP(self,_cmd,otherArray);
    }
    
}

typedef void (*removeObjectsInRange_IMP)(id self,SEL _cmd ,NSRange range);
static removeObjectsInRange_IMP origin_removeObjectsInRange_IMP = nil;
static void replace_removeObjectsInRange_IMP(id self,SEL _cmd,NSRange range){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        NSIndexSet * indexset = [NSIndexSet indexSetWithIndexesInRange:range ];
        NSIndexSet * arrayIndexSet = [array indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return YES;
        }];
        NSArray * deleteArray;
        if ([arrayIndexSet containsIndexesInRange:range]) {
            deleteArray= [self objectsAtIndexes:indexset];
        }
        origin_removeObjectsInRange_IMP(self,_cmd,range);
        if (number==1) {
            if (indexset.count) {
                [array.delegate mutableArray:self didDeleteObjects:deleteArray atIndexes:indexset];
                for (MutableArrayListener * observer in array.listeners) {
                    if (observer.didDeleteObjects) {
                        observer.didDeleteObjects(self, deleteArray, indexset);
                    }
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeObjectsInRange_IMP(self,_cmd,range);
    }
    
}

typedef void (*removeObjectsAtIndexes_IMP)(id self,SEL _cmd ,NSIndexSet* indexes );
static removeObjectsAtIndexes_IMP origin_removeObjectsAtIndexes_IMP = nil;
static void replace_removeObjectsAtIndexes_IMP(id self,SEL _cmd,NSIndexSet * indexes){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didDeleteObjects:atIndexes:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        NSIndexSet * arrayIndexSet = [array indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return YES;
        }];
        NSArray * deleteArray;
        if ([arrayIndexSet containsIndexes:indexes ]) {
            deleteArray= [self objectsAtIndexes:arrayIndexSet];
        }
        origin_removeObjectsAtIndexes_IMP(self,_cmd,indexes);
        if (number==1) {
            [array.delegate mutableArray:self didDeleteObjects:deleteArray atIndexes:indexes];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didDeleteObjects) {
                    observer.didDeleteObjects(self, deleteArray , indexes);
                }
            }
        }
        decreaseCount();
    }else{
        origin_removeObjectsAtIndexes_IMP(self,_cmd,indexes);
    }
    
}


#pragma mark  - replace

typedef void (*replaceObjectAtIndex_withObject_IMP)(id self,SEL _cmd ,NSUInteger index ,id anObject);
static replaceObjectAtIndex_withObject_IMP origin_replaceObjectAtIndex_withObject_IMP = nil;
static void replace_replaceObjectAtIndex_withObject_IMP(id self,SEL _cmd,NSUInteger index ,id anObject){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:replaceObject:withObject:atIndex:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        id object;
        if (array.count>0 && index< array.count) {
            object= [self objectAtIndex:index];
        }
        origin_replaceObjectAtIndex_withObject_IMP(self,_cmd,index,anObject);
        if (number==1) {
        [array.delegate mutableArray:self replaceObject:object withObject:anObject atIndex:index];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didReplaceObject) {
                    observer.didReplaceObject(self, object, anObject, index);
                }
            }
        }
        decreaseCount();
    }else{
        origin_replaceObjectAtIndex_withObject_IMP(self,_cmd,index,anObject);
    }
    
}

typedef void (*setObject_atIndexedSubscript_IMP)(id self,SEL _cmd ,id obj,NSUInteger index);
static setObject_atIndexedSubscript_IMP origin_setObject_atIndexedSubscript_IMP = nil;
static void replace_setObject_atIndexedSubscript_IMP(id self,SEL _cmd,id obj,NSUInteger index){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:replaceObject:withObject:atIndex:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        id object;
        if (array.count>0 && index< array.count) {
            object= [self objectAtIndex:index];
        }

        origin_setObject_atIndexedSubscript_IMP(self,_cmd,obj,index);
        if (number==1) {
            
            if (!object&& index==0) {
                [array.delegate mutableArray:self didAddObjects:@[[array firstObject]] atIndexes:[NSIndexSet indexSetWithIndex:index]];
                for (MutableArrayListener * observer in array.listeners) {
                    if (observer.didAddObjects) {
                        observer.didAddObjects(self, @[[array firstObject]], [NSIndexSet indexSetWithIndex:index]);
                    }
                }
            }else{
                [array.delegate mutableArray:self replaceObject:object withObject:obj atIndex:index];
                for (MutableArrayListener * observer in array.listeners) {
                    if (observer.didReplaceObject) {
                        observer.didReplaceObject(self, object, obj, index);
                    }
                }
            }
            }
            
        decreaseCount();
    }else{
        origin_setObject_atIndexedSubscript_IMP(self,_cmd,obj,index);
    }
    
}

typedef void (*replaceObjectsAtIndexes_withObjects_IMP)(id self,SEL _cmd ,NSIndexSet * indexes ,NSArray * objects);
static replaceObjectsAtIndexes_withObjects_IMP origin_replaceObjectsAtIndexes_withObjects_IMP = nil;
static void replace_replaceObjectsAtIndexes_withObjects_IMP(id self,SEL _cmd,NSIndexSet * indexes,NSArray * objects){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_replaceObjectsAtIndexes_withObjects_IMP(self,_cmd,indexes,objects);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_replaceObjectsAtIndexes_withObjects_IMP(self,_cmd,indexes,objects);
    }
    
    
}

typedef void (*replaceObjectsInRange_withObjectsFromArray_IMP)(id self,SEL _cmd ,NSRange range ,NSArray * array);
static replaceObjectsInRange_withObjectsFromArray_IMP origin_replaceObjectsInRange_withObjectsFromArray_IMP = nil;
static void replace_replaceObjectsInRange_withObjectsFromArray_IMP(id self,SEL _cmd,NSRange range,NSArray * array){
    NSMutableArray * arrayself = self;
    if (([arrayself.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[arrayself.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||arrayself.listeners.count) {
        NSInteger number = increaseCount();
        origin_replaceObjectsInRange_withObjectsFromArray_IMP(self,_cmd,range,array);
        if (number==1) {
            [arrayself.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in arrayself.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_replaceObjectsInRange_withObjectsFromArray_IMP(self,_cmd,range,array);
    }

}

typedef void (*replaceObjectsInRange_withObjectsFromArray_range_IMP)(id self,SEL _cmd ,NSRange range,NSArray * otherArray,NSRange  otherRange);
static replaceObjectsInRange_withObjectsFromArray_range_IMP origin_replaceObjectsInRange_withObjectsFromArray_range_IMP = nil;
static void replace_replaceObjectsInRange_withObjectsFromArray_range_IMP(id self,SEL _cmd,NSRange range,NSArray * otherArray,NSRange otherRange){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_replaceObjectsInRange_withObjectsFromArray_range_IMP(self,_cmd,range,otherArray,otherRange);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_replaceObjectsInRange_withObjectsFromArray_range_IMP(self,_cmd,range,otherArray,otherRange);
    }
    
}


#pragma mark  - sort

typedef void (*sortUsingComparator_IMP)(id self,SEL _cmd ,NSComparator cmptr);
static sortUsingComparator_IMP origin_sortUsingComparator_IMP = nil;
static void replace_sortUsingComparator_IMP(id self,SEL _cmd,NSComparator cmptr){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_sortUsingComparator_IMP(self,_cmd,cmptr);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_sortUsingComparator_IMP(self,_cmd,cmptr);
    }
    
}

typedef void (*sortUsingSelector_IMP)(id self,SEL _cmd ,SEL comparator);
static sortUsingSelector_IMP origin_sortUsingSelector_IMP = nil;
static void replace_sortUsingSelector_IMP(id self,SEL _cmd,SEL comparator){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_sortUsingSelector_IMP(self,_cmd,comparator);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_sortUsingSelector_IMP(self,_cmd,comparator);
    }
    
}

typedef void (*sortUsingDescriptors_IMP)(id self,SEL _cmd ,NSArray * sortDescriptors);
static sortUsingDescriptors_IMP origin_sortUsingDescriptors_IMP = nil;
static void replace_sortUsingDescriptors_IMP(id self,SEL _cmd,NSArray * sortDescriptors){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_sortUsingDescriptors_IMP(self,_cmd,sortDescriptors);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_sortUsingDescriptors_IMP(self,_cmd,sortDescriptors);
    }
    
}

typedef void (*sortUsingFunction_context_IMP)(id self,SEL _cmd, NSInteger(*compare)(id  _Nonnull __strong, id  _Nonnull __strong , void * _Nullable),void(*context));
static sortUsingFunction_context_IMP origin_sortUsingFunction_context_IMP = nil;
static void replace_sortUsingFunction_context_IMP(id self,SEL _cmd, NSInteger(*compare)(id  _Nonnull __strong, id  _Nonnull __strong , void * _Nullable),void(*context)){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_sortUsingFunction_context_IMP(self,_cmd, compare,context);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_sortUsingFunction_context_IMP(self,_cmd, compare,context);
    }
}


typedef void (*sortWithOptions_usingComparator_IMP)(id self,SEL _cmd ,NSSortOptions opts,NSComparator cmptr);
static sortWithOptions_usingComparator_IMP origin_sortWithOptions_usingComparator_IMP = nil;
static void replace_sortWithOptions_usingComparator_IMP(id self,SEL _cmd,NSSortOptions opts,NSComparator cmptr){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_sortWithOptions_usingComparator_IMP(self,_cmd,opts,cmptr);
        if (number==1) {
            [array.delegate mutableArrayhasChanged: self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_sortWithOptions_usingComparator_IMP(self,_cmd,opts,cmptr);
    }
    
}

#pragma mark  - reset

typedef void (*setArray_IMP)(id self,SEL _cmd ,NSArray * array);
static setArray_IMP origin_setArray_IMP = nil;
static void replace_setArray_IMP(id self,SEL _cmd,NSArray * array){
    NSMutableArray * arrayself= self;
    if (([arrayself.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[arrayself.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||arrayself.listeners.count) {
        NSInteger number = increaseCount();
        origin_setArray_IMP(self,_cmd,array);
        if (number==1) {
            [arrayself.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in arrayself.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_setArray_IMP(self,_cmd,array);
    }
    
}

#pragma mark  - exchange

typedef void (*exchangeObjectAtIndex_withObjectAtIndex_IMP)(id self,SEL _cmd ,NSUInteger index1,NSUInteger index2);
static exchangeObjectAtIndex_withObjectAtIndex_IMP origin_exchangeObjectAtIndex_withObjectAtIndex_IMP = nil;
static void replace_exchangeObjectAtIndex_withObjectAtIndex_IMP(id self,SEL _cmd,NSUInteger index1,NSUInteger index2){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:exchangeObjectAtIndex:withObjectAtIndex:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_exchangeObjectAtIndex_withObjectAtIndex_IMP(self,_cmd,index1,index2);
        if (number==1) {
            [array.delegate mutableArray:self exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didExchangeIndex) {
                    observer.didExchangeIndex(self, index1, index2);
                }
            }
        }
        decreaseCount();
    }else{
        origin_exchangeObjectAtIndex_withObjectAtIndex_IMP(self,_cmd,index1,index2);
    }
    
}


#pragma mark - filter

typedef void (*filterUsingPredicate_IMP)(id self,SEL _cmd ,NSPredicate * predicate);
static filterUsingPredicate_IMP origin_filterUsingPredicate_IMP = nil;
static void replace_filterUsingPredicate_IMP(id self,SEL _cmd,NSPredicate * predicate){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArrayhasChanged:)])||array.listeners.count) {
        NSInteger number = increaseCount();
        origin_filterUsingPredicate_IMP(self,_cmd,predicate);
        if (number==1) {
            [array.delegate mutableArrayhasChanged:self];
            for (MutableArrayListener * observer in array.listeners) {
                if (observer.didChanged) {
                    observer.didChanged(self);
                }
            }
        }
        decreaseCount();
    }else{
        origin_filterUsingPredicate_IMP(self,_cmd,predicate);
    }
}


#pragma mark  - insert
typedef void (*insertObject_atIndex_IMP)(id self, SEL _cmd ,id anObject ,NSUInteger index);
static insertObject_atIndex_IMP origin_insertObject_atIndex = nil;
static void replace_insertObject_atIndex(id self, SEL _cmd ,id anObject ,NSUInteger index){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate) ]&& [array.delegate respondsToSelector:@selector(mutableArray:didAddObjects:atIndexes:)])||array.listeners.count>0) {
        
        NSInteger number = increaseCount();
        origin_insertObject_atIndex(self,_cmd,anObject,index);
        if (number==1) {
            [array.delegate mutableArray:self didAddObjects:@[anObject] atIndexes:[NSIndexSet indexSetWithIndex:index]];
            for (MutableArrayListener  * server in array.listeners) {
                if (server.didAddObjects) {
                    server.didAddObjects(self, @[anObject], [NSIndexSet indexSetWithIndex:index]);
                }
            }
        }
        decreaseCount();
        
    }else{
        origin_insertObject_atIndex(self,_cmd,anObject,index);
    }
    
}

typedef void (*addObjectsFromArray_IMP)(id self,SEL _cmd,NSArray * otherArray );
static addObjectsFromArray_IMP  origin_addObjectsFromArray =nil;
static void replace_addObjectsFromArray (id self,SEL _cmd ,NSArray * otherArray){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didAddObjects:atIndexes:)])||array.listeners.count>0) {
        NSInteger number = increaseCount();
        origin_addObjectsFromArray(self,_cmd,otherArray);
        
        NSIndexSet * indexSet = [array indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([otherArray containsObject:obj]) {
                return YES;
            }else{
                return NO;
            }
        }];
        
        if (number==1) {
            [array.delegate mutableArray:self didAddObjects:otherArray atIndexes:indexSet];
            for (MutableArrayListener  * server in array.listeners) {
                if (server.didAddObjects) {
                    server.didAddObjects(self, otherArray, indexSet);
                }
            }
        }
        decreaseCount();
    }else{
        origin_addObjectsFromArray(self,_cmd,otherArray);
    }
}

typedef void (*insertObjects_atIndexes_IMP)(id self,SEL _cmd,NSArray * objects,NSIndexSet* indexes);
static insertObjects_atIndexes_IMP origin_insertObjects_atIndexes_IMP =nil;
static void replace_insertObjects_atIndexes_IMP(id self,SEL _cmd,NSArray * objects,NSIndexSet* indexes){
    NSMutableArray * array = self;
    if (([array.delegate conformsToProtocol:@protocol(NSMutableArrayListenerDelegate)]&&[array.delegate respondsToSelector:@selector(mutableArray:didAddObjects:atIndexes:)])||array.listeners.count>0) {
        NSInteger number = increaseCount();
        origin_insertObjects_atIndexes_IMP(self,_cmd,objects,indexes);
        
        if (number==1) {
            [array.delegate mutableArray:self didAddObjects:objects atIndexes:indexes];
            for (MutableArrayListener * server in array.listeners) {
                if (server.didAddObjects) {
                    server.didAddObjects(self, objects, indexes);
                }
            }
        }
        decreaseCount();
        
    }else{
        origin_insertObjects_atIndexes_IMP(self,_cmd,objects,indexes);
    }
}

@implementation NSMutableArray (Listener)

@dynamic delegate;
-(void)addListener:(MutableArrayListener *)observer{
    if (observer) {
        [self.listeners addObject:observer];
        
        NSAssert(observer.didChanged, @"can not be nil");
        NSAssert(observer.didAddObjects, @"can not be nil");
        NSAssert(observer.didDeleteObjects, @"can not be nil");
        NSAssert(observer.didExchangeIndex, @"can not be nil");
        NSAssert(observer.didReplaceObject, @"can not be nil");

        NSAssert(!checkCircleReference(observer.didAddObjects, self), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didDeleteObjects, self), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didChanged, self), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didExchangeIndex, self), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didReplaceObject, self), @"raise a block circle reference");
        
        
        NSAssert(!checkCircleReference(observer.didAddObjects, observer), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didDeleteObjects, observer), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didChanged, observer), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didExchangeIndex, observer), @"raise a block circle reference");
        NSAssert(!checkCircleReference(observer.didReplaceObject, observer), @"raise a block circle reference");
    }
}
-(void)removeListener:(MutableArrayListener *)observer{
    if ([self.listeners containsObject:observer]) {
        [self.listeners removeObject:observer];
    }
}
-(BOOL)hasListener{
    if (self.listeners.count>0) {
        return YES;
    }else{
        return NO;
    }
}
+(void)load{
    Method method;
    Class  class = NSClassFromString(@"__NSArrayM");
#pragma mark - insert
    method = class_getInstanceMethod(class, @selector(insertObject:atIndex:));
    origin_insertObject_atIndex = (insertObject_atIndex_IMP)method_setImplementation(method, (IMP)replace_insertObject_atIndex);
        
    method = class_getInstanceMethod(class, @selector(addObjectsFromArray:));
    origin_addObjectsFromArray = (addObjectsFromArray_IMP)method_setImplementation(method, (IMP)replace_addObjectsFromArray);
    
    method  = class_getInstanceMethod(class, @selector(insertObjects:atIndexes:));
    origin_insertObjects_atIndexes_IMP =(insertObjects_atIndexes_IMP)method_setImplementation(method, (IMP)replace_insertObjects_atIndexes_IMP);
    
#pragma mark - remove
    method  = class_getInstanceMethod(class, @selector(removeObjectAtIndex:));
    origin_removeObjectAtIndex_IMP = (removeObjectAtIndex_IMP)method_setImplementation(method, (IMP)replace_removeObjectAtIndex_IMP);
    
#pragma mark  - bath remove
    method = class_getInstanceMethod(class, @selector(removeObject:));
    origin_removeObject_IMP = (removeObject_IMP)method_setImplementation(method, (IMP)replace_removeObject_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeAllObjects));
    origin_removeAllObjects_IMP =(removeAllObjects_IMP)method_setImplementation(method, (IMP)replace_removeAllObjects_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeObject:inRange:));
    origin_removeObject_inRange_IMP =(removeObject_inRange_IMP)method_setImplementation(method, (IMP)replace_removeObject_inRange_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeObjectIdenticalTo:inRange:));
    origin_removeObjectIdenticalTo_inRange_IMP =(removeObjectIdenticalTo_inRange_IMP)method_setImplementation(method, (IMP)replace_removeObjectIdenticalTo_inRange_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeObjectIdenticalTo:));
    origin_removeObjectIdenticalTo_IMP =(removeObjectIdenticalTo_IMP)method_setImplementation(method, (IMP)replace_removeObjectIdenticalTo_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeObjectsInArray:));
    origin_removeObjectsInArray_IMP =(removeObjectsInArray_IMP)method_setImplementation(method, (IMP)replace_removeObjectsInArray_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeObjectsInRange:));
    origin_removeObjectsInRange_IMP =(removeObjectsInRange_IMP)method_setImplementation(method, (IMP)replace_removeObjectsInRange_IMP);
    
    method = class_getInstanceMethod(class, @selector(removeObjectsAtIndexes:));
    origin_removeObjectsAtIndexes_IMP =(removeObjectsAtIndexes_IMP)method_setImplementation(method, (IMP)replace_removeObjectsAtIndexes_IMP);
    
#pragma mark - replace
    method = class_getInstanceMethod(class, @selector(replaceObjectAtIndex:withObject:));
    origin_replaceObjectAtIndex_withObject_IMP =(replaceObjectAtIndex_withObject_IMP)method_setImplementation(method, (IMP)replace_replaceObjectAtIndex_withObject_IMP);
    
    method = class_getInstanceMethod(class, @selector(setObject:atIndexedSubscript:));
    origin_setObject_atIndexedSubscript_IMP =(setObject_atIndexedSubscript_IMP)method_setImplementation(method, (IMP)replace_setObject_atIndexedSubscript_IMP);

#pragma mark  - bath replace
    method = class_getInstanceMethod(class, @selector(replaceObjectsAtIndexes:withObjects:));
    origin_replaceObjectsAtIndexes_withObjects_IMP =(replaceObjectsAtIndexes_withObjects_IMP)method_setImplementation(method, (IMP)replace_replaceObjectsAtIndexes_withObjects_IMP);
    
    method = class_getInstanceMethod(class, @selector(replaceObjectsInRange:withObjectsFromArray:));
    origin_replaceObjectsInRange_withObjectsFromArray_IMP =(replaceObjectsInRange_withObjectsFromArray_IMP)method_setImplementation(method, (IMP)replace_replaceObjectsInRange_withObjectsFromArray_IMP);
    
    method = class_getInstanceMethod(class, @selector(replaceObjectsInRange:withObjectsFromArray:range:));
    origin_replaceObjectsInRange_withObjectsFromArray_range_IMP =(replaceObjectsInRange_withObjectsFromArray_range_IMP)method_setImplementation(method, (IMP)replace_replaceObjectsInRange_withObjectsFromArray_range_IMP);
    
#pragma mark - sort
    method = class_getInstanceMethod(class, @selector(sortUsingComparator:));
    origin_sortUsingComparator_IMP =(sortUsingComparator_IMP)method_setImplementation(method, (IMP)replace_sortUsingComparator_IMP);
    
    method = class_getInstanceMethod(class, @selector(sortUsingSelector:));
    origin_sortUsingSelector_IMP =(sortUsingSelector_IMP)method_setImplementation(method, (IMP)replace_sortUsingSelector_IMP);
    
    method = class_getInstanceMethod(class, @selector(sortUsingDescriptors:));
    origin_sortUsingDescriptors_IMP =(sortUsingDescriptors_IMP)method_setImplementation(method, (IMP)replace_sortUsingDescriptors_IMP);
    
    method = class_getInstanceMethod(class, @selector(sortUsingFunction:context:));
    origin_sortUsingFunction_context_IMP =(sortUsingFunction_context_IMP)method_setImplementation(method, (IMP)replace_sortUsingFunction_context_IMP);
    
    method = class_getInstanceMethod(class, @selector(sortWithOptions:usingComparator:));
    origin_sortWithOptions_usingComparator_IMP =(sortWithOptions_usingComparator_IMP)method_setImplementation(method, (IMP)replace_sortWithOptions_usingComparator_IMP);
    
    method = class_getInstanceMethod(class, @selector(setArray:));
    origin_setArray_IMP =(setArray_IMP)method_setImplementation(method, (IMP)replace_setArray_IMP);
#pragma mark  -  exchange
    method = class_getInstanceMethod(class, @selector(exchangeObjectAtIndex:withObjectAtIndex:));
    origin_exchangeObjectAtIndex_withObjectAtIndex_IMP =(exchangeObjectAtIndex_withObjectAtIndex_IMP)method_setImplementation(method, (IMP)replace_exchangeObjectAtIndex_withObjectAtIndex_IMP);
    
#pragma mark - filter   
    method = class_getInstanceMethod(class, @selector(filterUsingPredicate:));
    origin_filterUsingPredicate_IMP =(filterUsingPredicate_IMP)method_setImplementation(method, (IMP)replace_filterUsingPredicate_IMP);
}

#pragma mark - property

-(void)setDelegate:(id)delegate{
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

-(id)delegate{
    return objc_getAssociatedObject(self, @selector(delegate));
}

@end
