//
//  ChatViewController.m
//  chatTalking
//
//  Created by qianfeng on 16/3/26.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageModel.h"
#import "QCLMessageFrame.h"

@interface ChatViewController ()<XMPPStreamDelegate,UITableViewDataSource, UITableViewDelegate>{
    BOOL isediting;
}

@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic ,strong) NSMutableArray *messageArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    self.messageArray = [[NSMutableArray alloc] init];
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self createVIew];
    
    [self reloadMessage];
    [self createTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createTableView {
   
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
   
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    QCLMessageFrame *model = self.messageArray[indexPath.row];
    
    
    if (model.messageModel.type == QCLMessageTypeMe) {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    } else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    cell.textLabel.text = model.messageModel.text;
    cell.textLabel.numberOfLines = 0;
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messageArray[indexPath.row] cellHeight];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)keyBoardWillShow:(NSNotification *)sender {
    
    NSDictionary *dict = [sender userInfo];
    CGRect keyBoardRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.view.window.backgroundColor = self.tableView.backgroundColor;
    
    [UIView animateWithDuration:[[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{

            self.view.transform = CGAffineTransformMakeTranslation(0, keyBoardRect.origin.y - self.view.frame.size.height);

    } completion:^(BOOL finished) {}];
}

- (void)createVIew {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49)];
    [self.view addSubview:view];
    self.toolView = view;
    
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, self.view.frame.size.width-150, 39)];
    [view addSubview:textField];
    textField.placeholder = @"请输入.....";
    self.textFiled = textField;

    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(CGRectGetMaxX(textField.frame)+10, 10, 78, 39);
    [btn setTitle:@"发送" forState: UIControlStateNormal];
    [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [view addSubview:btn];
    
}

- (void)btn {
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_friendJID] ;
    [message addBody:self.textFiled.text];
    [[XMPPManager shareManager].xmppStream sendElement:message];
    
    self.textFiled.text = @"";
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    [self reloadMessage];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    [self reloadMessage];
}




- (void)reloadMessage {
    NSManagedObjectContext *context = [[XMPPManager shareManager] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [request setEntity:description];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[XMPPManager shareManager].xmppStream.myJID.bare, _friendJID.bare];
    request.predicate = pre;
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    NSError *error = nil;
    NSArray *array  = [context executeFetchRequest:request error:&error];
    if (_messageArray.count != 0) {
        [_messageArray removeAllObjects];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    for (XMPPMessageArchiving_Message_CoreDataObject *object in array) {
        
        MessageModel *model = [[MessageModel alloc] init];
        model.text = object.message.body;
        model.time = [formatter stringFromDate:object.timestamp];
        model.type = object.isOutgoing == YES?QCLMessageTypeMe:QCLMessageTypeOther;
        
        QCLMessageFrame *lastMessageFrame = [_messageArray lastObject];
        
        model.notShowTime = [lastMessageFrame.messageModel.time isEqualToString:model.time];
        QCLMessageFrame *mf = [[QCLMessageFrame alloc] init];
        mf.messageModel = model;
        
        [_messageArray addObject:mf];
        
    }
    
    [self.tableView reloadData];
    
    if (_messageArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
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
