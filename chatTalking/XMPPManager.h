//
//  XMPPManager.h
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

typedef NS_ENUM(NSInteger, ConnectServerPurposeType) {
    ConnectServerPurposeTypeLogin,
    ConnectServerPurposeTypeRegister
};



@interface XMPPManager : NSObject<XMPPStreamDelegate>

// 输入输出流
@property (nonatomic, strong) XMPPStream *xmppStream;


// 好友管理
@property (nonatomic, strong) XMPPRoster *xmppRoster;


// 聊天信息
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype)shareManager;


- (void)loginWithName:(NSString *)userName andPassword:(NSString *)passWord;
- (void)registerWithName:(NSString *)userName andPassword:(NSString *)passWord;

@end
