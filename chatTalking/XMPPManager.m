//
//  XMPPManager.m
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "XMPPManager.h"

@interface XMPPManager ()<UIAlertViewDelegate>
{
    ConnectServerPurposeType _connectServerPurposeType;
}

@property (nonatomic, strong) NSString *passWord;
@property (nonatomic, strong) XMPPJID *fromJid;


@end


@implementation XMPPManager

+ (instancetype)shareManager {
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
       
        manager = [[self alloc] init];
        
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _xmppStream = [[XMPPStream alloc] init];
        _xmppStream.hostName = @"qianfeng.local";
        _xmppStream.hostPort = 5222;
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        XMPPRosterCoreDataStorage *dataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        _xmppRoster  =[[XMPPRoster alloc] initWithRosterStorage:dataStorage dispatchQueue:dispatch_get_main_queue()];
        [_xmppRoster activate:_xmppStream];
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        XMPPMessageArchivingCoreDataStorage *archivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:archivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];

        [_xmppMessageArchiving activate:_xmppStream];
       
        _managedObjectContext = archivingCoreDataStorage.mainThreadManagedObjectContext;
        
        
    }
    return self;
}

- (void)loginWithName:(NSString *)userName andPassword:(NSString *)passWord {
    _connectServerPurposeType = ConnectServerPurposeTypeLogin;
    
    self.passWord = passWord;
    
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:@"qianfeng.local" resource:[UIDevice currentDevice].model];
    self.xmppStream.myJID = jid;
    
    [self connectToServer];
    
}

- (void)registerWithName:(NSString *)userName andPassword:(NSString *)passWord {
    
    _connectServerPurposeType = ConnectServerPurposeTypeRegister;
    self.passWord = passWord;
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:@"qianfeng.local" resource:[UIDevice currentDevice].model];
    self.xmppStream.myJID = jid;
    [self connectToServer];
    
    
}

// 收到好友请求执行的方法
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    self.fromJid = presence.from;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示:有人添加你" message:presence.from.user  delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"OK", nil];
    [alert show];
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [_xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJid andAddToRoster:YES];
    }
}

- (void)connectToServer {
    if ([self.xmppStream isConnected]) {
        [self logout];
    }
    
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:60.0f error:&error];
    
    if (error) {
        NSLog(@"连接错误信息%@",error);
    }
    
}

- (void)logout {
    // 离线不可用
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
   
    [self.xmppStream sendElement:presence];
    [self.xmppStream disconnect];
}


- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"连接服务器失败的方法,请检查网络");
}

// 连接服务器成功的方法
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    if (_connectServerPurposeType == ConnectServerPurposeTypeRegister) {
        
        [sender registerWithPassword:self.passWord error:nil];
        
        NSLog(@"开始注册");
        
    } else {
        [sender authenticateWithPassword:self.passWord error:nil];
        NSLog(@"登录成功");
    }
}

// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"注册成功的%@",sender);
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    
    NSLog(@"注册失败:%@",error);
}


// 验证成功

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPPresence *pressence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:pressence];
}
// 验证失败

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"验证失败的方法,请检查你的用户名或者密码是否正确%@",error);
}

@end
