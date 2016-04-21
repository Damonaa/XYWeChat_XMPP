//
//  XYRegisterViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYRegisterViewController.h"
#import "MBProgressHUD+CZ.h"
#import "XYXMPPTool.h"

@interface XYRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation XYRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//注册
- (IBAction)registerBtnClick:(id)sender {
    //保存注册的用户名和密码
    [XYAccount shareAccount].registerUser = self.userNameField.text;
    [XYAccount shareAccount].registerPwd = self.pwdField.text;
    
    [MBProgressHUD showMessage:@"正在注册...."];
    
    //调用注册的方法，代理
//    __weak typeof(self) weadkSelf = self;
    [XYXMPPTool sharedXYXMPPTool].registerOperation = YES;
    [[XYXMPPTool sharedXYXMPPTool] xmppRegister:^(XMPPResultType resultTye) {
        //调用完block以后，就清空block，可以使用self
        [self handelXMPPResult:resultTye];
        
    }];
}

//c处理注册结果
- (void)handelXMPPResult:(XMPPResultType)resultType{
    //主线程处理
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        
        if (resultType == XMPPResultTypeRegisterSuccess) {
            [MBProgressHUD showSuccess:@"恭喜， 注册成功"];
        }else{
            [MBProgressHUD showError:@"用户名重复"];
        }
    });
}

- (void)dealloc{
    XYLog(@"销毁");
}
@end
