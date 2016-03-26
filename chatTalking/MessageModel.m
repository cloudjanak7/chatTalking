//
//  MessageModel.m
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

+ (instancetype)messageWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}


- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
    
        [self setValuesForKeysWithDictionary:dict];
        
    }
    return self;
}

@end
