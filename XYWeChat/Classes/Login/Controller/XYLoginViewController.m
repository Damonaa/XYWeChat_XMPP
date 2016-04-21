//
//  XYLoginViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYLoginViewController.h"
#import "XYAccount.h"
#import "XYXMPPTool.h"
#import "MBProgressHUD+CZ.h"
#import "UIStoryboard+XY.h"

@interface XYLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation XYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 点击登陆
- (IBAction)login:(id)sender {
    //1. 判断用户有没有输入用户名密码
    if (self.userNameField.text.length == 0 || self.pwdField.text.length == 0) {
        XYLog(@"please input user name and password");
        return;
    }
    
    [MBProgressHUD showMessage:@"正在登陆......"];
    //2. 登陆服务器
    //2.1 先把用户名密码存入XYAccount单例中
    [XYAccount shareAccount].loginUser = self.userNameField.text;
    [XYAccount shareAccount].loginPwd = self.pwdField.text;
    
    //2.2 调用工具类 登陆
    //处理回调结果
//    __weak typeof(self) weakSelf = self;
    [XYXMPPTool sharedXYXMPPTool].registerOperation = NO;
    [[XYXMPPTool sharedXYXMPPTool] xmppLogin:^(XMPPResultType reslutType) {
        [self handleXMPPResultType:reslutType];
    }];
}

- (IBAction)registerBtnClick:(id)sender {
}

#pragma mark - 处理回调结果
- (void)handleXMPPResultType:(XMPPResultType)resultType{
    //主线程中更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        
        if (resultType == XMPPResultTypeLoginSuccess) {
            //登陆成功，切换到主界面
            [UIStoryboard showInitialVCWithName:@"Main"];
            //设置当前的登陆状态
            [XYAccount shareAccount].login = YES;
            
            //保存登陆的信息到沙盒
            [[XYAccount shareAccount] saveToSandBox];
        }else{
            [MBProgressHUD showError:@"用户名或密码错误"];
        }
    });
    
}

- (void)dealloc{
    XYLog(@"销毁");
}
@end
