//
//  CCUIModel.h
//  Pods
//
//  Created by aruisi on 2017/7/26.
//
//

#import <Foundation/Foundation.h>

/**
 How to use，
 0. CCM CCMNotifier
 CCM(label, text) = CCMNotifier(person, name);
 
 1. id type property
 [CCUIModel makeRelation:^(void) {
    label.text = createNotifer(person, @"name").idValue;
 }];
 
 2. notifer post messages to block or selector
     [createNotifer(person, @"name") makeRelation:self withBlock:^(id value) {
     
     }];
     
     [createNotifer(person, @"name") makeRelation:self WithSelector:@selector(hitTest:)];

 */

/**
 report error:
 
 [CCUIModel reportError:^(const char* fileName, int line) {
 NSLog(@"%s ----- %d\n %@\n\n\n\n", fileName, line, [NSThread callStackSymbols]);
 }];
 
 */


typedef id(^transferValue1)(id value);
typedef id(^transferValue2)(id value1, id value2);
typedef id(^transferValue3)(id value1, id value2, id value3);
typedef id(^transferValue4)(id value1, id value2, id value3, id value4);
typedef id(^transferValue5)(id value1, id value2, id value3, id value4, id value5);

typedef id(^transferValueN)(NSArray* values);

typedef void (^errorBlock)(const char* fileName, int line);

@interface CCUIModel : NSObject

-(CCUIModel*)setTransfer:(transferValue1)transfer;
-(CCUIModel*)setTransfer2:(transferValue2)transfer;
-(CCUIModel*)setTransfer3:(transferValue3)transfer;
-(CCUIModel*)setTransfer4:(transferValue4)transfer;
-(CCUIModel*)setTransfer5:(transferValue5)transfer;
-(CCUIModel*)setTransferN:(transferValueN)transfer;


/**
 when model changed, the selector from target will be called.
 The model value will be passed by the parameter from selector

 @param target target which response model changed.
 @param selector the selector need to execute from target
 */
-(void)makeRelation:(NSObject*)target WithSelector:(SEL)selector;


/**
 when model changed, the blocker will be called.

 @param target target which response model changed.
 @param block the blocker which need to call when model changed
 */
-(void)makeRelation:(NSObject*)target withBlock:(void(^)(id value))block;


/**
 A UI value may be combined with multi model value
 */
-(CCUIModel* (^)(CCUIModel* hooker))plus;

-(id)idValue;

+(void)makeRelation:(void(^)(void))block;

+ (void)reportError:(errorBlock)error;
    
@end


#define metamacro_concat(A, B) metamacro_concat_(A, B)
#define metamacro_at(N, ...) metamacro_concat(metamacro_at, N)(__VA_ARGS__)
#define metamacro_head(...) metamacro_head_(__VA_ARGS__, 0)
#define metamacro_if_eq(A, B) metamacro_concat(metamacro_if_eq, A)(B)

#define metamacro_argcount(...) \
metamacro_at(2, __VA_ARGS__, 2, 1)

#define metamacro_dec(VAL) \
metamacro_at(VAL, -1, 0, 1, 2)

#define metamacro_concat_(A, B) A ## B
#define metamacro_head_(FIRST, ...) FIRST
#define metamacro_consume_(...)
#define metamacro_expand_(...) __VA_ARGS__

#define metamacro_at0(...) metamacro_head(__VA_ARGS__)
#define metamacro_at1(_0, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at2(_0, _1, ...) metamacro_head(__VA_ARGS__)

#define metamacro_if_eq0(VALUE) metamacro_concat(metamacro_if_eq0_, VALUE)
#define metamacro_if_eq0_0(...) __VA_ARGS__ metamacro_consume_
#define metamacro_if_eq0_1(...) metamacro_expand_
#define metamacro_if_eq1(VALUE) metamacro_if_eq0(metamacro_dec(VALUE))

#define keypath(...) \
metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__))

#define keypath1(PATH) \
(((void)(NO && ((void)PATH, NO)), strchr(# PATH, '.') + 1))

#define keypath2(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

#define CCM(TARGET, ...) \
    [CCMCombine debugTrace:__FILE__ line:__LINE__]; \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__)) \
    (CCM_(TARGET, __VA_ARGS__, nil)) \
    (CCM_(TARGET, __VA_ARGS__))

/// Do not use this directly. Use the CCM macro above.
#define CCM_(TARGET, KEYPATH, NILVALUE) \
([CCMCombine modelWithTarget:TARGET nilValue:NILVALUE][@keypath(TARGET, KEYPATH)])

#define CCMNotifier(TARGET, ...) \
    (CCUIModel*)createNotifer(TARGET, @keypath(TARGET, __VA_ARGS__))

@interface CCMCombine : NSObject

+ (void)debugTrace:(const char*)file line:(int)line;

+ (id)modelWithTarget:(id)target nilValue:(id)nilValue;

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)keyPath;

@end


/**
 create a CCUIModel with object and property name

 @param notifier notifer object
 @param propName notifer property
 @return CCUIModel with object and property name
*/
CCUIModel* createNotifer(id notifier, NSString* propName);

/**
 create a CCUIModel with none relation
 
 @return CCUIModel with none relation
*/
CCUIModel* createDummy(void);


/**
 init relation which should post message when value changed

 @param cls the class of listener
 @param prop the property of listener
 @return successfull or not
*/
bool initListenerProperty(Class  cls, NSString* prop, Class valueClass);

/**
 init relation which will be get message when other value changed

 @param cls the class of notifer
 @param prop the property of notifer
 @return successfull or not
*/
bool initNotifierProperty(Class  cls, NSString* prop);

