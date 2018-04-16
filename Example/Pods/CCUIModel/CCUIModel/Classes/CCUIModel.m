//
//  CCUIModel.m
//  Pods
//
//  Created by aruisi on 2017/7/26.
//
//

#import "CCUIModel.h"
#import <objc/runtime.h>
#import <pthread.h>
#import <CircleReferenceCheck/CircleReferenceCheck.h>

@class ObserverRelation;

static NSObject* __nilValue;

static NSMutableDictionary<NSString*, NSDictionary<NSString*, NSArray*>*>* __listenerSetterMethods;
static NSMutableDictionary<NSString*, NSDictionary<NSString*, NSArray*>*>* __notifierSetterMethods;
static NSMutableDictionary<NSNumber*, NSArray*>* __currentInformation;

static const void * __notifierDicKey;
static const void * __listenerObjKey;

//block structure
struct Block_layout {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *, ...);//block method
    struct Block_descriptor *descriptor;
    /* Imported variables. */
};

// block description
struct Block_descriptor {
    unsigned long int reserved;
    unsigned long int size;
    void (*copy)(void *dst, void *src);//block copy method
    void (*dispose)(void *);//block dispose method
};

@interface NotiferInformation : NSObject
@property (nonatomic, weak) NSObject* notifer;
@property (nonatomic, copy) NSString* prop;
@end

@implementation NotiferInformation

@end


@interface ObserverRelation : NSObject
@property (nonatomic, weak) NSObject* listener;
@property (nonatomic, copy) NSString* listenerProp;
    
@property (nonatomic, copy) void(^notiferBlock)(id value);
@property (nonatomic) SEL notiferSelector;

/**
 tansfer the value from notifer into listener format
 */
@property (nonatomic,copy) id transfer;

/**
 how many notifer values need to transfer
 */
@property(nonatomic) int transferParamNum;

/**
 store notifer information
 */
@property (nonatomic) NSMutableArray<NotiferInformation*>* notifierInfos;

-(id)makeTransfer:(NSArray*)values;

@end

@implementation ObserverRelation

-(instancetype)init{
    if (self = [super init]) {
        self.notifierInfos = [NSMutableArray array];
    }
    return self;
}

-(id)makeTransfer:(NSArray*)values {
    if (_transfer) {
        id value1 = nil;
        id value2 = nil;
        id value3 = nil;
        id value4 = nil;
        id value5 = nil;
        
        
        if (values.count > 0)
            value1 = values[0];
        if (values.count > 1)
            value2 = values[1];
        if (values.count > 2)
            value3 = values[2];
        if (values.count > 3)
            value4 = values[3];
        if (values.count > 4)
            value5 = values[4];
        
        if (value1 == __nilValue) value1 = nil;
        if (value2 == __nilValue) value2 = nil;
        if (value3 == __nilValue) value3 = nil;
        if (value4 == __nilValue) value4 = nil;
        if (value5 == __nilValue) value5 = nil;
        
        id result = nil;
        switch (_transferParamNum) {
            case 0:
                result = ((transferValue1)_transfer)(value1);
                break;
                
            case  1:
                result = ((transferValue2)_transfer)(value1,value2);
                break;
                
            case 2:
                result = ((transferValue3)_transfer)(value1,value2,value3);
                break;
                
            case 3:
                result = ((transferValue4)_transfer)(value1,value2,value3,value4);
                break;
                
            case 4:
                result = ((transferValue5)_transfer)(value1,value2,value3,value4,value5);
                break;
                
            default:
            {
            NSMutableArray* copy = [NSMutableArray array];
            for (id v in values) {
                if (v == __nilValue) [copy addObject:[NSNull null]];
                else [copy addObject:v];
            }
            result = ((transferValueN)_transfer)(copy);
            
            }
                break;
        }
        return result;
    }
    return  nil;
}

-(void)dealloc {
    NSArray * notifers = self.notifierInfos;
    for (NotiferInformation*  info in notifers) {
        id notifer = info.notifer;
        @synchronized (notifer) {
            NSMutableDictionary * modeContent = objc_getAssociatedObject(notifer, &__notifierDicKey);
            [modeContent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray*  _Nonnull relations, BOOL * _Nonnull stop) {
                [relations removeObjectIdenticalTo:self];
            }];
        }
    }
    [self.notifierInfos removeAllObjects];
}

@end


@interface CCUIModel ()
/**The relation between notifer and listener*/
@property (nonatomic, strong) ObserverRelation* relation;
@property (nonatomic, strong) NSMutableArray* notifers;
@property (nonatomic, strong) NSMutableArray* values;


@property (nonatomic, assign) BOOL dummy;
@property (nonatomic, assign) NSUInteger tickCount;
@property (nonatomic, weak) id listener;
@end

static void makeRelationWithProp(id listener, NSString * prop, CCUIModel * fromNotifer);
static id  makeRelationWithSel(id listener, SEL sel, CCUIModel * fromNotifer);
static void removeRelationWithProp(id object, NSString * prop);
static void removeRelationWithSel(id object, SEL sel);

static void notiferListener(NSArray* relations, NSObject* notifer, id value, NSString* prop) {
    // get all relation notifer values, key->notiferPoint, value->value
    NSMutableDictionary* allValue = [NSMutableDictionary dictionary];
    [allValue setObject:value?value:__nilValue forKey:[NSString stringWithFormat:@"%p%@", notifer, prop]];
    
    // gether all values which listeners needs
    for (ObserverRelation* relation in relations) {
        for (NotiferInformation* info in relation.notifierInfos) {
            NSString* key = [NSString stringWithFormat:@"%p%@", info.notifer, info.prop];
            if ([allValue objectForKey:key] == nil) {
                if (info.notifer == __nilValue)
                    value = __nilValue;
                else
                    value = [info.notifer valueForKey:info.prop];
                [allValue setObject:value?value:__nilValue forKey:key];
            }
        }
    }
    
    
    [relations enumerateObjectsUsingBlock:^(ObserverRelation * _Nonnull relation, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // values the listener need.
        NSMutableArray * values = [NSMutableArray array];

        // get all values which listener need.
        for (NotiferInformation * info in relation.notifierInfos) {
            [values addObject: [allValue objectForKey:[NSString stringWithFormat:@"%p%@", info.notifer, info.prop]]];
        }
        
        // transfer value if the transfer exist, the result is the final value will set to listener
        id result = nil;
        if (relation.transfer) {
            result = [relation makeTransfer:values];
        } else {
            if (values.count > 0) result = [values objectAtIndex:0];
        }
        if (result == __nilValue) result = nil;
        
        // set the obj to listener
        if (relation.listenerProp) {
            if ([relation.listener isKindOfClass:[UIView class]] && ![NSThread isMainThread]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [relation.listener setValue:result forKey:relation.listenerProp];
                });
            }else{
                [relation.listener setValue:result forKey:relation.listenerProp];
            }
        }else if (relation.notiferBlock){
            if ([relation.listener isKindOfClass:[UIView class]] && ![NSThread isMainThread]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    relation.notiferBlock(result);
                });
            }else{
                relation.notiferBlock(result);
            }
        }else{
            if ([relation.listener isKindOfClass:[UIView class]] && ![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [relation.listener performSelector:relation.notiferSelector withObject:result];
#pragma clang diagnostic pop
                });
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [relation.listener performSelector:relation.notiferSelector withObject:result];
#pragma clang diagnostic pop
            }
        }
    }];
}

static NSArray * getListenerSetter(id self, SEL _cmd){
    @synchronized (__listenerSetterMethods) {
        Class cls = [self class];
        NSString* className = NSStringFromClass(cls);
        NSString* methodName = NSStringFromSelector(_cmd);
        NSArray* temp = nil;
        if (methodName)
            while (className && temp == nil) {
                NSDictionary<NSString*, NSArray*>* dic = __listenerSetterMethods[className];
                temp = [dic valueForKey:methodName];
                cls = [cls superclass];
                className = NSStringFromClass(cls);
            }
        if (temp && [temp[0] pointerValue])
            return temp;
        return nil;
    }
}

static NSArray * getNotiferSetter(id self, SEL _cmd){
    @synchronized (__notifierSetterMethods) {
        Class cls = [self class];
        NSString* className = NSStringFromClass(cls);
        NSString* methodName = NSStringFromSelector(_cmd);
        NSArray* temp = nil;
        if (methodName)
            while (className && temp == nil) {
                NSDictionary<NSString*, NSArray*>* dic = __notifierSetterMethods[className];
                temp = [dic valueForKey:methodName];
                cls = [cls superclass];
                className = NSStringFromClass(cls);
            }
        if (temp && [temp[0] pointerValue])
            return temp;
        return nil;
    }
}


typedef void (*typeof_objc_notifer_setter_id)(id self, SEL _cmd, id value);
static void replaced_notifer_setter_id_IMP(__unsafe_unretained id self, SEL _cmd, id value) {
    NSArray* temp = getNotiferSetter(self, _cmd);
    if (temp) {
        typeof_objc_notifer_setter_id original = [temp[0] pointerValue];
        original(self, _cmd, value);
        NSString * prop = temp[1];
        NSMutableDictionary * dic = objc_getAssociatedObject(self, &__notifierDicKey);
        NSMutableArray * relations = [dic objectForKey:prop];
        notiferListener(relations, self, value, prop);
    }
}

#define IMP_NOTIFIER_SETTER_DEFINE(type, var, valuer) \
typedef void (*typeof_objc_notifer_setter_##var)(id self, SEL _cmd, type value); \
    static void replaced_notifer_setter_##var##_IMP(__unsafe_unretained id self, SEL _cmd, type value) { \
    NSArray* temp = getNotiferSetter(self, _cmd);\
    if (temp) {\
        typeof_objc_notifer_setter_##var original = [temp[0] pointerValue];\
        original(self, _cmd, value);\
        NSString * prop = temp[1]; \
        NSMutableDictionary * dic = objc_getAssociatedObject(self, &__notifierDicKey);\
        NSMutableArray * relations = [dic objectForKey:prop];\
        notiferListener(relations, self, valuer, prop);\
    }\
}\

IMP_NOTIFIER_SETTER_DEFINE(char, char, @(value))
IMP_NOTIFIER_SETTER_DEFINE(int, int, @(value))
IMP_NOTIFIER_SETTER_DEFINE(short, short, @(value))
IMP_NOTIFIER_SETTER_DEFINE(long, long, @(value))
IMP_NOTIFIER_SETTER_DEFINE(long long, longlong, @(value))
IMP_NOTIFIER_SETTER_DEFINE(unsigned char, uchar, @(value))
IMP_NOTIFIER_SETTER_DEFINE(unsigned int, uint, @(value))
IMP_NOTIFIER_SETTER_DEFINE(unsigned short, ushort, @(value))
IMP_NOTIFIER_SETTER_DEFINE(unsigned long, ulong, @(value))
IMP_NOTIFIER_SETTER_DEFINE(unsigned long long, ulonglong, @(value))
IMP_NOTIFIER_SETTER_DEFINE(float, float, @(value))
IMP_NOTIFIER_SETTER_DEFINE(double, double, @(value))
IMP_NOTIFIER_SETTER_DEFINE(bool, bool, @(value))
IMP_NOTIFIER_SETTER_DEFINE(char*, char_, @(value))
IMP_NOTIFIER_SETTER_DEFINE(CGSize, CGSize, [NSValue valueWithCGSize:value])
IMP_NOTIFIER_SETTER_DEFINE(CGPoint, CGPoint, [NSValue valueWithCGPoint:value])
IMP_NOTIFIER_SETTER_DEFINE(CGRect, CGRect, [NSValue valueWithCGRect:value])
IMP_NOTIFIER_SETTER_DEFINE(UIEdgeInsets, UIEdgeInsets, [NSValue valueWithUIEdgeInsets:value])

#define IMP_LISTENER_SETTER_DEFINE(type, var) \
typedef void (*objc_listener_setter_##var)(id self, SEL _cmd, type object);\
static void replaced_listener_setter_##var##_IMP(__unsafe_unretained id self, SEL _cmd, type object) {\
    NSArray* temp = getListenerSetter(self, _cmd);\
    CCUIModel* uimodel = nil;\
    if (temp) {\
        objc_listener_setter_##var original = [temp[0] pointerValue];\
        mach_port_t machTID = pthread_mach_thread_np(pthread_self());\
        @synchronized (__currentInformation) {\
            uimodel = [__currentInformation objectForKey:@(machTID)][0];\
            if(uimodel && uimodel.tickCount == 0) {\
                [__currentInformation setObject:@[uimodel, self, NSStringFromSelector(_cmd)] forKey:@(machTID)];\
                if (uimodel.dummy) {\
                    return;\
                }\
            }\
        }\
        uimodel.tickCount++;\
        original(self, _cmd, object);\
        uimodel.tickCount--;\
    }\
}\

IMP_LISTENER_SETTER_DEFINE(id, id)
IMP_LISTENER_SETTER_DEFINE(BOOL, BOOL)



static void removeRelationWithProp(id object, NSString * prop){
    NSMutableDictionary * listenerDic = objc_getAssociatedObject(object, &__listenerObjKey);
    NSArray * subContent = [listenerDic objectForKey:prop];
    if (subContent.count == 2) {
        ObserverRelation * relation = subContent[0];
        NSArray * notifers = subContent[1];
        for (id object in notifers) {
            @synchronized (object) {
                NSMutableDictionary * modeContent = objc_getAssociatedObject(object, &__notifierDicKey);
                [modeContent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray*  _Nonnull relations, BOOL * _Nonnull stop) {
                    [relations removeObjectIdenticalTo:relation];
                }];
            }
        }
    }
    @synchronized (listenerDic) {
        [listenerDic setValue:NULL forKey:prop];
    }
}

static void removeRelationWithSel(id object, SEL sel){
    NSMutableDictionary * listenerDic = objc_getAssociatedObject(object, &__listenerObjKey);
    NSArray * subContent = [listenerDic objectForKey:[NSValue valueWithPointer:sel]];
    if (subContent.count == 2) {
        ObserverRelation * relation = subContent[0];
        NSArray * notifers = subContent[1];
        for (id object in notifers) {
            @synchronized (object) {
                NSMutableDictionary * modeContent = objc_getAssociatedObject(object, &__notifierDicKey);
                [modeContent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray*  _Nonnull relations, BOOL * _Nonnull stop) {
                    [relations removeObjectIdenticalTo:relation];
                }];
            }
        }
    }
    @synchronized (listenerDic) {
        [listenerDic removeObjectForKey:[NSValue valueWithPointer:sel]];
    }
}

static void removeRelationWithBlock(id object, id block){
    struct Block_layout* layout = (__bridge struct Block_layout*)block;
    
    NSMutableDictionary * listenerDic = objc_getAssociatedObject(object, &__listenerObjKey);
    NSArray * subContent = [listenerDic objectForKey:[NSValue valueWithPointer:layout->invoke]];
    if (subContent.count == 2) {
        ObserverRelation * relation = subContent[0];
        NSArray * notifers = subContent[1];
        for (id object in notifers) {
            @synchronized (object) {
                NSMutableDictionary * modeContent = objc_getAssociatedObject(object, &__notifierDicKey);
                [modeContent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray*  _Nonnull relations, BOOL * _Nonnull stop) {
                    [relations removeObjectIdenticalTo:relation];
                }];
            }
        }
    }
    @synchronized (listenerDic) {
        [listenerDic removeObjectForKey:[NSValue valueWithPointer:layout->invoke]];
    }
}


static void addRelation(CCUIModel* uimodel){
    
    for (NotiferInformation * info in uimodel.relation.notifierInfos) {
        if (info.notifer) {
            @synchronized (info.notifer) {
                NSMutableDictionary * dic = objc_getAssociatedObject(info.notifer, &__notifierDicKey);
                if (!dic) {
                    dic = [NSMutableDictionary dictionary];
                    objc_setAssociatedObject(info.notifer, &__notifierDicKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
                NSMutableArray * relations = [dic objectForKey:info.prop];
                if (!relations) {
                    relations = [NSMutableArray array];
                    [dic setValue:relations forKey:info.prop];
                }
                [relations addObject:uimodel.relation];
            }
        }
    }
    
    @synchronized (uimodel.relation.listener) {
        NSMutableDictionary * listenerObjDic = objc_getAssociatedObject(uimodel.relation.listener, &__listenerObjKey);
        if (!listenerObjDic) {
            listenerObjDic = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(uimodel.relation.listener, &__listenerObjKey, listenerObjDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        if (uimodel.relation.listenerProp)
            [listenerObjDic setValue:@[uimodel.relation, uimodel.notifers] forKey:uimodel.relation.listenerProp];
        else if (uimodel.relation.notiferSelector)
            [listenerObjDic setObject:@[uimodel.relation, uimodel.notifers] forKey:[NSValue valueWithPointer:uimodel.relation.notiferSelector]];
        else {
            struct Block_layout* layout = (__bridge struct Block_layout*)uimodel.relation.notiferBlock;
            [listenerObjDic setObject:@[uimodel.relation, uimodel.notifers] forKey:[NSValue valueWithPointer:layout->invoke]];
        }
    }
}

static void makeRelationWithProp(id listener, NSString * prop, CCUIModel * fromNotifer){
    fromNotifer.relation.listener = listener;
    fromNotifer.relation.listenerProp = prop;
    
    removeRelationWithProp(fromNotifer.relation.listener, fromNotifer.relation.listenerProp);
    addRelation(fromNotifer);
}

static id  makeRelationWithSel(id listener, SEL sel, CCUIModel * fromNotifer){
    fromNotifer.relation.listener = listener;
    fromNotifer.relation.notiferSelector = sel;
    
    removeRelationWithSel(fromNotifer.relation.listener, fromNotifer.relation.notiferSelector);
    addRelation(fromNotifer);
    
    id value = nil;
    NSArray* values = fromNotifer.values;
    if (fromNotifer.relation.transfer) {
        value = [fromNotifer.relation makeTransfer:values];
    } else {
        if (values.count > 0) value = [values objectAtIndex:0];
        if (value == __nilValue) value = nil;
    }
    return value;
}

static id  makeRelationWithBlock(id listener, id block, CCUIModel * fromNotifer){
    fromNotifer.relation.listener = listener;
    fromNotifer.relation.notiferBlock = block;
    
    removeRelationWithBlock(fromNotifer.relation.listener, fromNotifer.relation.notiferBlock);
    addRelation(fromNotifer);
    
    id value = nil;
    NSArray* values = fromNotifer.values;
    if (fromNotifer.relation.transfer) {
        value = [fromNotifer.relation makeTransfer:values];
    } else {
        if (values.count > 0) value = [values objectAtIndex:0];
        if (value == __nilValue) value = nil;
    }
    return value;
}



@implementation CCUIModel

+(void)load{
    __nilValue = [[NSObject alloc] init];
    
    __listenerSetterMethods = [NSMutableDictionary dictionary];
    __notifierSetterMethods = [NSMutableDictionary dictionary];
    __currentInformation = [NSMutableDictionary dictionary];
    
    initListenerProperty([UIView class], @"hidden");
    initListenerProperty([UIView class], @"clipsToBounds");
    initListenerProperty([UIView class], @"backgroundColor");
    initListenerProperty([UIView class], @"alpha");
    initListenerProperty([UIView class], @"opaque");
    initListenerProperty([UIView class], @"tintColor");
    
    initListenerProperty([UILabel class], @"text");
    initListenerProperty([UILabel class], @"attributedText");
    initListenerProperty([UILabel class], @"font");
    initListenerProperty([UILabel class], @"enabled");
    initListenerProperty([UILabel class], @"textColor");
    initListenerProperty([UILabel class], @"shadowColor");

    initListenerProperty([UITextField class], @"text");
    initListenerProperty([UITextField class], @"attributedText");
    initListenerProperty([UITextField class], @"textColor");
    initListenerProperty([UITextField class], @"font");
    initListenerProperty([UITextField class], @"placeholder");
    initListenerProperty([UITextField class], @"attributedPlaceholder");
    initListenerProperty([UITextField class], @"background");
    initListenerProperty([UITextField class], @"disabledBackground");

    initListenerProperty([UITextView class], @"text");
    initListenerProperty([UITextView class], @"font");
    initListenerProperty([UITextView class], @"textColor");
    initListenerProperty([UITextView class], @"attributedText");

    initListenerProperty([UIImageView class], @"image");
    initListenerProperty([UIImageView class], @"highlightedImage");
}

-(instancetype)init{
    if (self = [super init]) {
        _notifers = [[NSMutableArray alloc] init];
        _values = [NSMutableArray array];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(CCUIModel * (^)(CCUIModel *))plus{
    CCUIModel* (^blocker)(CCUIModel* notifer) = ^(CCUIModel* uimodel){
        [_relation.notifierInfos addObjectsFromArray:uimodel.relation.notifierInfos];
        [_notifers addObjectsFromArray:uimodel.notifers];
        [_values addObjectsFromArray:uimodel.values];
        return self;
    };
    return blocker;
}


-(void)makeRelation:(NSObject *)object withBlock:(void (^)(id))block{
    self.relation.listener = object;
    self.relation.notiferBlock = block;
    
    id value  = makeRelationWithBlock(object, block, self);

    NSAssert(!checkCircleReference(block, object), @"raise a block circle reference");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    for (id a in self.notifers) {
        NSAssert(!checkCircleReference(a, object), @"raise a block circle reference");
    }
#pragma clang diagnostic pop
    block(value);
}

-(void)makeRelation:(NSObject *)object WithSelector:(SEL)selector{
    self.relation.listener = object;
    self.relation.notiferSelector = selector;
    
    id value = makeRelationWithSel(object, selector, self);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    for (id a in self.notifers) {
        NSAssert(!checkCircleReference(a, object), @"raise a block circle reference");
    }
#pragma clang diagnostic pop

    if (([object isKindOfClass:[UIView class]] || [object isKindOfClass:[UIViewController class]])&& ![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [object performSelector:selector withObject:value];
#pragma clang diagnostic pop
        });
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [object performSelector:selector withObject:value];
#pragma clang diagnostic pop
    }
}

-(CCUIModel*)setTransfer:(transferValue1)transfer {
    self.relation.transfer = transfer;
    self.relation.transferParamNum = 0;
    return self;
}

-(CCUIModel *)setTransfer2:(transferValue2)transfer{
    self.relation.transfer = transfer;
    self.relation.transferParamNum = 1;
    return self;
}

-(CCUIModel *)setTransfer3:(transferValue3)transfer{
    self.relation.transfer = transfer;
    self.relation.transferParamNum = 2;
    return self;
}

-(CCUIModel *)setTransfer4:(transferValue4)transfer{
    self.relation.transfer = transfer;
    self.relation.transferParamNum = 3;
    return self;
}

-(CCUIModel *)setTransfer5:(transferValue5)transfer{
    self.relation.transfer = transfer;
    self.relation.transferParamNum = 4;
    return self;
}

-(CCUIModel *)setTransferN:(transferValueN)transfer{
    self.relation.transfer = transfer;
    self.relation.transferParamNum = 5;
    return self;
}

-(id)idValue {
    id value = nil;
    NSArray* values = _values;
    if (_relation.transfer) {
        value = [_relation makeTransfer:values];
    } else {
        if (values.count > 0) value = [values objectAtIndex:0];
        if (value == __nilValue) value = nil;
    }
    
    @synchronized (__currentInformation) {
        mach_port_t machTID = pthread_mach_thread_np(pthread_self());
        if ([__currentInformation objectForKey:@(machTID)])
            [__currentInformation setObject:@[self] forKey:@(machTID)];
    }
    
    return value;
}

+(void)makeRelation:(void(^)(void))block {
    if (block) {
        // init thread value, mark we will make relation
        CCUIModel * placeholder = [[CCUIModel alloc] init];
        mach_port_t machTID = pthread_mach_thread_np(pthread_self());
        @synchronized (__currentInformation) {
            [__currentInformation setObject:@[placeholder] forKey:@(machTID)];
        }
        
        // get relation
        block();
        
        // make relation
        id listener = nil;
        SEL cmd = nil;
        CCUIModel* uimodel = nil;
        @synchronized (__currentInformation) {
            NSArray* content = [__currentInformation objectForKey:@(machTID)];
            if (content.count == 3) {
                uimodel = content[0];
                listener = content[1];
                cmd = NSSelectorFromString(content[2]);
            }
            [__currentInformation removeObjectForKey:@(machTID)];
        }
        if (uimodel != placeholder) {
            NSArray* temp = getListenerSetter(listener, cmd);
            if (temp) {
                NSString * prop = temp[1];
                if (uimodel) {
                    if (uimodel.dummy) {
                        removeRelationWithProp(listener, prop);
                    } else {
                        makeRelationWithProp(listener, prop, uimodel);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
                        for (id a in uimodel.notifers) {
                            NSAssert(!checkCircleReference(a, listener), @"raise a block circle reference");
                        }
#pragma clang diagnostic pop
                    }
                }
            }
        }
    }
}

@end

id createNotifer(id notifer, NSString * prop){
    CCUIModel * uimodel = [[CCUIModel alloc] init];
    
    uimodel.relation = [[ObserverRelation alloc] init];
    NotiferInformation * info = [[NotiferInformation alloc] init];
    info.notifer = notifer;
    info.prop = prop;
    [uimodel.relation.notifierInfos addObject:info];
    
    id value = [notifer valueForKey:prop];
    [uimodel.values addObject:value?value:__nilValue];
    [uimodel.notifers addObject:notifer?notifer:__nilValue];
    
    initNotifierProperty([notifer class], prop);
    
    return uimodel;
}

id createDummy(){
    CCUIModel * temp = [[CCUIModel alloc] init];
    temp.dummy = YES;
    @synchronized (__currentInformation) {
        mach_port_t machTID = pthread_mach_thread_np(pthread_self());
        if ([__currentInformation objectForKey:@(machTID)])
            [__currentInformation setObject:@[temp] forKey:@(machTID)];
    }
    return temp;
}

bool initListenerProperty(Class  cls, NSString* p){
    @synchronized (__listenerSetterMethods) {
        NSString* methodName = p.length > 0 ? [NSString stringWithFormat:@"set%@%@:",[[p substringToIndex:1] uppercaseString],[p substringFromIndex:1]] : nil;
        objc_property_t prop = class_getProperty(cls, [p UTF8String]);
        
        if (prop) {
            char* setter = property_copyAttributeValue(prop, "S");
            if (setter)
                methodName = [NSString stringWithUTF8String:setter];
        }
        
        Class _cls = cls;
        Method method = class_getInstanceMethod(_cls, NSSelectorFromString(methodName));
        IMP original = method?method_getImplementation(method):nil;
        
        if (methodName) {
            Class _nextCls = _cls;
            Method _nextMethod = method;
            IMP _nextOriginal = original;
            
            do {
                _cls = _nextCls;
                method = _nextMethod;
                original = _nextOriginal;
                
                
                _nextCls = class_getSuperclass(_cls);
                _nextMethod = _nextCls?class_getInstanceMethod(_nextCls, NSSelectorFromString(methodName)):nil;
                _nextOriginal = _nextMethod?method_getImplementation(_nextMethod):nil;
            //} while (_nextOriginal == original && _cls);
            } while (_nextOriginal && _cls);
        }

        
        if (original) {
            NSString* clsName = NSStringFromClass(_cls);
            NSDictionary<NSString*, NSArray*>* dic = __listenerSetterMethods[clsName];
            if (dic == nil) {
                dic = [[NSMutableDictionary alloc] init];
                [__listenerSetterMethods setValue:dic forKey:clsName];
            }
            
            char* returnType = method_copyArgumentType(method, 2);
            
            IMP replaced = nil;
            if (returnType) {
                if (strcmp(returnType, @encode(id)) == 0) {
                    replaced = (IMP)replaced_listener_setter_id_IMP;
                } else if (strcmp(returnType, @encode(BOOL)) == 0) {
                    replaced = (IMP)replaced_listener_setter_BOOL_IMP;
                }
            }
            
            if (original && replaced && replaced != original) {
                method_setImplementation(method, replaced);
                [dic setValue:@[[NSValue valueWithPointer:original], p] forKey:methodName];
            }
            
            if (replaced)
                return true;
        }
    }
    return false;
}

bool initNotifierProperty(Class cls, NSString* p) {
    @synchronized (__notifierSetterMethods) {
        NSString* methodName = p.length > 0 ? [NSString stringWithFormat:@"set%@%@:",[[p substringToIndex:1] uppercaseString],[p substringFromIndex:1]] : nil;
        objc_property_t prop = class_getProperty(cls, [p UTF8String]);
        
        if (prop) {
            char* setter = property_copyAttributeValue(prop, "S");
            if (setter)
                methodName = [NSString stringWithUTF8String:setter];
        }
        
        
        Class _cls = cls;
        Method method = class_getInstanceMethod(_cls, NSSelectorFromString(methodName));
        IMP original = method?method_getImplementation(method):nil;
        
        if (methodName) {
            Class _nextCls = _cls;
            Method _nextMethod = method;
            IMP _nextOriginal = original;
            
            do {
                _cls = _nextCls;
                method = _nextMethod;
                original = _nextOriginal;
                
                
                _nextCls = class_getSuperclass(_cls);
                _nextMethod = _nextCls?class_getInstanceMethod(_nextCls, NSSelectorFromString(methodName)):nil;
                _nextOriginal = _nextMethod?method_getImplementation(_nextMethod):nil;
            //} while (_nextOriginal == original && _cls);
            } while (_nextOriginal && _cls);
        }
        
        
        if (original) {
            NSString* clsName = NSStringFromClass(_cls);
            NSDictionary<NSString*, NSArray*>* dic = __notifierSetterMethods[clsName];
            if (dic == nil) {
                dic = [[NSMutableDictionary alloc] init];
                [__notifierSetterMethods setValue:dic forKey:clsName];
            }

            char* returnType = method_copyArgumentType(method, 2);
            
            IMP replaced = nil;
            if (returnType) {
                if (strcmp(returnType, @encode(char)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_char_IMP;
                } else if (strcmp(returnType, @encode(int)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_int_IMP;
                } else if (strcmp(returnType, @encode(short)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_short_IMP;
                } else if (strcmp(returnType, @encode(long)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_long_IMP;
                } else if (strcmp(returnType, @encode(long long)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_longlong_IMP;
                } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_uchar_IMP;
                } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_uint_IMP;
                } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_ushort_IMP;
                } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_ulong_IMP;
                } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_ulonglong_IMP;
                } else if (strcmp(returnType, @encode(float)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_float_IMP;
                } else if (strcmp(returnType, @encode(double)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_double_IMP;
                } else if (strcmp(returnType, @encode(bool)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_bool_IMP;
                } else if (strcmp(returnType, @encode(char*)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_char__IMP;
                } else if (strcmp(returnType, @encode(id)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_id_IMP;
                } else if (strcmp(returnType, @encode(CGSize)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_CGSize_IMP;
                } else if (strcmp(returnType, @encode(CGPoint)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_CGPoint_IMP;
                } else if (strcmp(returnType, @encode(CGRect)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_CGRect_IMP;
                } else if (strcmp(returnType, @encode(UIEdgeInsets)) == 0) {
                    replaced = (IMP)replaced_notifer_setter_UIEdgeInsets_IMP;
                }
            }
            
            if (original && replaced && replaced != original) {
                method_setImplementation(method, replaced);
                [dic setValue:@[[NSValue valueWithPointer:original], p] forKey:methodName];
            }
            
            if (replaced)
                return true;
        }
    }
    return false;
}


