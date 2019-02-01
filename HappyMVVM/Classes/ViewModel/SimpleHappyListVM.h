//
//  SimpleHappyListVM.h
//  HappyMVVM
//
//  Created by Aruisi on 4/13/18.
//

#import "HappyListVM.h"

@interface SimpleHappyListVM : HappyListVM

#pragma mark sub class need override
-(NSString*)cacheFilePath;
-(id(^)(id))serializeCell;
-(id(^)(id))deSerializeCell;
-(id(^)(id))serializeExtra;
-(id(^)(id))deSerializeExtra;
@end
