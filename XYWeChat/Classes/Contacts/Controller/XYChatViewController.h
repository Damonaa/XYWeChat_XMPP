//
//  XYChatViewController.h
//  XYWeChat
//
//  Created by 李小亚 on 16/3/29.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYChatViewController : UIViewController

/**
 *  从通讯录中传来的 聊天好友的JID
 */
@property (nonatomic, strong) XMPPJID *friendJid;

@end
