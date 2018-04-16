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
 1. id type property
 [CCUIModel makeRelation:^(void) {
    label.text = createNotifer(person, @"name");
 }];
 
 2. notifer post messages to block or selector
     [createNotifer(person, @"name") makeRelation:self withBlock:^(id value) {
     
     }];
     
     [createNotifer(person, @"name") makeRelation:self WithSelector:@selector(hitTest:)];

 */


typedef id(^transferValue1)(id value);
typedef id(^transferValue2)(id value1, id value2);
typedef id(^transferValue3)(id value1, id value2, id value3);
typedef id(^transferValue4)(id value1, id value2, id value3, id value4);
typedef id(^transferValue5)(id value1, id value2, id value3, id value4, id value5);

typedef id(^transferValueN)(NSArray* values);

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
bool initListenerProperty(Class  cls, NSString* prop);

/**
 init relation which will be get message when other value changed

 @param cls the class of notifer
 @param prop the property of notifer
 @return successfull or not
*/
bool initNotifierProperty(Class  cls, NSString* prop);
