//
//  XYAddContactController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/29.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYAddContactController.h"

@interface XYAddContactController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation XYAddContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)addContact:(id)sender {
    
    NSString *user = self.nameField.text;
    
    //1, 不能添加自己为好友
    if ([user isEqualToString:[XYAccount shareAccount].loginUser]) {
        [self showMessage:@"干嘛要添加你自己呀， 傻呀！"];
        return;
    }
    
    //2, 已经存在的好友，不需要再添加
    XMPPJID *userJid = [XMPPJID jidWithUser:user domain:[XYAccount shareAccount].domain resource:nil];
    BOOL userExists = [[XYXMPPTool sharedXYXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[XYXMPPTool sharedXYXMPPTool].xmppStream];
    if (userExists) {
        [self showMessage:@"二货，都是你好友了，还加"];
        return;
    }
    
    //3, 添加好友， 订阅
    [[XYXMPPTool sharedXYXMPPTool].roster subscribePresenceToUser:userJid];
    /**
     *  添加服务器中不存在的好友，也会显示到通讯录中
     *解决办法 1， 服务器拦截，不存的的好友，不返回
     *2， 过来数据库的Subscription字段， 在通讯录控制器中过滤 
     none 对方没有同意添加好友
     to 发给对方的请求
     from 别人发来的请求
     both 双方互为好友
     */
    
}


/**
 *  显示提示框信息
 *
 *  @param msg 信息
 */
- (void)showMessage:(NSString *)msg{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
    [alertCtr addAction:action];
    
    [self.navigationController presentViewController:alertCtr animated:YES completion:nil];
    
}



@end
