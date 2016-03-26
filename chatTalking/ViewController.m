//
//  ViewController.m
//  chatTalking
//
//  Created by qianfeng on 16/3/25.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"
#import "RosterViewController.h"

@interface ViewController ()<XMPPStreamDelegate>


@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *passWord;


- (IBAction)login:(id)sender;

- (IBAction)register1:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    self.userName.text = @"123";
    self.passWord.text = @"123";
 
    
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    
    if (self.userName.text && self.passWord.text) {
        [[XMPPManager shareManager] loginWithName:self.userName.text andPassword:self.passWord.text];
    }
    
    
}

- (IBAction)register1:(id)sender {
    if (self.userName.text && self.passWord.text) {
        [[XMPPManager shareManager] registerWithName:self.userName.text andPassword:self.passWord.text];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    RosterViewController *vc = [RosterViewController new];
    vc.title = @"好友列表";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

@end
