//
//  QCLMessageFrame.h
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface QCLMessageFrame : NSObject

@property (nonatomic, assign, readonly)CGRect chatTimeFrame;
@property (nonatomic, assign, readonly)CGRect chatIconFrame;
@property (nonatomic, assign, readonly) CGRect chatTextViewFrame;
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong) MessageModel *messageModel;

@end
