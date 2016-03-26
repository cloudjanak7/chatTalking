//
//  RosterViewController.m
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "RosterViewController.h"
#import "XMPPManager.h"
#import "ChatViewController.h"


@interface RosterViewController ()<XMPPRosterDelegate,UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic ,strong) NSMutableArray *rosterArray;
@property (nonatomic ,strong) UITableView *tableView;


@end

@implementation RosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _rosterArray = [NSMutableArray array];
    [self createTableView];
    [[XMPPManager shareManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加好友" style: UIBarButtonItemStylePlain target:self action:@selector(doAdd:)];
    
}

- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatViewController *vc = [[ChatViewController alloc] init]
    ;
    
    XMPPJID *jid = self.rosterArray[indexPath.row];
    
    vc.title = jid.user;
    
    vc.friendJID = self.rosterArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        
    }
    
    XMPPJID *jid = self.rosterArray[indexPath.row];
    
    cell.textLabel.text = jid.user;
    
    
    
    return cell;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rosterArray.count;
}


- (void)doAdd:(UIBarButtonItem *)sender {
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"添加好游" message:@"" delegate: self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;
    [view show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    
        UITextField *tf = [alertView textFieldAtIndex:0];
        
        
        XMPPJID *jid = [XMPPJID jidWithUser:tf.text domain:@"qianfeng.local" resource:[UIDevice currentDevice].model];
        [[XMPPManager shareManager].xmppRoster subscribePresenceToUser:jid];
        
  
    
}


- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    
    NSString *jid = [[item attributeForName:@"jid"] stringValue];
    XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
    if ([_rosterArray containsObject:jid]) {
        return;
    }
    [_rosterArray addObject:xmppJID];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_rosterArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version {
    NSLog(@"开始检索好友列表");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
