//
//  SimpleBaseModel.h
//  CCUIModel
//
//  Created by Aruisi on 4/20/18.
//

#import "HappyModel.h"

@interface SimpleHappyModel : HappyModel
#pragma mark sub class need override
-(NSString*)cacheFilePath;
-(id(^)(id))serialize;
-(id(^)(id))deSerialize;
@end
