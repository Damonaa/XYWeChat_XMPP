//
//  XYMeViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYMeViewController.h"
#import "XYXMPPTool.h"
#import "UIStoryboard+XY.h"
#import "XMPPvCardTemp.h"


@interface XYMeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;

@end

@implementation XYMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.   
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    XMPPvCardTemp *vCard = [XYXMPPTool sharedXYXMPPTool].vCard.myvCardTemp;
    
    if (vCard.photo) {
        self.avatarImage.image = [UIImage imageWithData:vCard.photo];
    }
    self.weChatNumLabel.text = [NSString stringWithFormat:@"微信号: %@", [XYAccount shareAccount].loginUser];
    
//    [self.tableView reloadData];
}
- (IBAction)logout:(id)sender {
    //注销
    [[XYXMPPTool sharedXYXMPPTool] xmppLogout];
    //沙盒中的登陆状态改为no
    [XYAccount shareAccount].login = NO;
    [[XYAccount shareAccount] saveToSandBox];
    //
    [UIStoryboard showInitialVCWithName:@"Login"];
}


@end
