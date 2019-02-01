//
//  ListBaseResponse.h
//  HappyMVVM
//
//  Created by Aruisi on 2017/8/1.
//  Copyright © 2017年 Scorplot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListBaseResponse : NSObject
@property (nonatomic, strong) NSArray * _Nullable list;
@property (nonatomic, strong) id _Nullable extra;
@property (nonatomic, strong) id _Nullable lastToken;


@end
