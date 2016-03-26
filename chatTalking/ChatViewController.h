//
//  ChatViewController.h
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoster.h"
#import "XMPPManager.h"

@interface ChatViewController : UIViewController

@property (nonatomic, strong) XMPPJID *friendJID;

@end
