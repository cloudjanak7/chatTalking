//
//  QCLMessageFrame.m
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "QCLMessageFrame.h"
#define QCLMessageFont [UIFont systemFontOfSize:13]
#define screenWidth() [[UIScreen mainScreen] bounds].size.width
#define WFTextPadding 20
@implementation QCLMessageFrame


- (void)setMessageModel:(MessageModel *)messageModel {
    _messageModel = messageModel;
    
    if (!_messageModel.notShowTime) {
        _chatTimeFrame = CGRectMake(0, 0, screenWidth(), 20);
    }
    
    CGFloat chatPadding = 10;
    
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    CGFloat iconY = CGRectGetMaxY(_chatTimeFrame);
    
    if (_messageModel.type == QCLMessageTypeOther) {
        _chatIconFrame = CGRectMake(chatPadding, iconY, iconW, iconH);
    }else {
        _chatIconFrame = CGRectMake(screenWidth() - iconW - chatPadding, iconY, iconW, iconH);
    }
    
    CGFloat chatTextW = 150;
    CGFloat chatTextX;
    CGFloat chattextY = iconY;
    
     NSDictionary *attrs = @{NSFontAttributeName : QCLMessageFont};
    CGSize chatTextSize = [messageModel.text boundingRectWithSize:CGSizeMake(chatTextW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    CGFloat chatTextH = chatTextSize.height ;
    if (messageModel.type == QCLMessageTypeOther) {
        chatTextX = CGRectGetMaxX(_chatIconFrame) + chatPadding;
        
    }else {
        chatTextX = screenWidth() - chatPadding - iconW - chatTextSize.width - chatPadding - WFTextPadding*2;
    }
    _chatTextViewFrame = CGRectMake(chatTextX, chattextY, chatTextSize.width + WFTextPadding*2, chatTextH + WFTextPadding*2);
    _cellHeight = MAX(CGRectGetMaxY(_chatIconFrame), CGRectGetMaxY(_chatTextViewFrame)) + chatPadding;
}




@end
