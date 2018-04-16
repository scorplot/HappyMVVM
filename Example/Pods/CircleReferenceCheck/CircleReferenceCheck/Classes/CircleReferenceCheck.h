//
//  CircleReferenceCheck.h
//  block底层
//
//  Created by aruisi on 2017/6/26.
//  Copyright © 2017年 aruisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

    /**
     chek obj1 and obj2 have circle reference
     
     @param obj1 obj1
     @param obj2 obj2
     @return dose obj1 and obj2 have circle reference
     */
    bool checkCircleReference(id obj1, id obj2);
    
    
   
    /**
     check obj

     @param obj obj to check
     @param level check to which level. 1 for check level 1, -1 for check all level
     @param ... multi args
     @return dose circle reference exist
     */
    
    bool checkCircleReferenceWithObjs(id obj,int level, id objs,...) __attribute__((sentinel));
    
    NSSet* getAllReference(id obj);

#ifdef __cplusplus
}
#endif
