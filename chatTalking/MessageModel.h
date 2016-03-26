//
//  MessageModel.h
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QCLMessageType) {
    QCLMessageTypeOther,
    QCLMessageTypeMe
};


@interface MessageModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) QCLMessageType type;
@property (nonatomic, assign) BOOL notShowTime;


+ (instancetype)messageWithDict:(NSDictionary *)dict;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
