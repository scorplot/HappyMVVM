//
//  MutableArrayOberver.h
//  Pods
//
//  Created by aruisi on 2017/7/10.
//
//

#import <Foundation/Foundation.h>
typedef void(^didAddObjects)(NSMutableArray * array ,NSArray* objects ,NSIndexSet* indexes);
typedef void(^didDeleteObjects)(NSMutableArray * array ,NSArray* objects ,NSIndexSet* indexes);
typedef void(^didReplaceAnObject)(NSMutableArray * array ,id anObject , id withObject , NSUInteger index);
typedef void(^didExchangeIndex)(NSMutableArray * array ,NSUInteger index1 ,NSUInteger index2);
typedef void(^didChanged)(NSMutableArray * array);

@interface MutableArrayListener : NSObject

@property(nonatomic,copy) didAddObjects  didAddObjects;

@property(nonatomic,copy) didDeleteObjects didDeleteObjects;

@property(nonatomic,copy) didExchangeIndex didExchangeIndex;

@property(nonatomic,copy) didReplaceAnObject didReplaceObject;

@property(nonatomic,copy) didChanged didChanged;
@end
