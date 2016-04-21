//
//  XYAccount.h
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//  用户账户模型 单例模式

#import <Foundation/Foundation.h>

@interface XYAccount : NSObject

/**
 *  登陆的用户名
 */
@property (nonatomic, copy) NSString *loginUser;

/**
 *  登陆的密码
 */
@property (nonatomic, copy) NSString *loginPwd;
/**
 *  判断用户是否登陆
 */
@property (nonatomic, assign, getter=isLogin) BOOL login;
/**
 *  注册的用户名
 */
@property (nonatomic, copy) NSString *registerUser;
/**
 *  注册的密码
 */
@property (nonatomic, copy) NSString *registerPwd;

/**
 *  服务器域名
 */
@property (nonatomic, copy) NSString *domain;
/**
 *  服务器IP
 */
@property (nonatomic, copy) NSString *host;
/**
 *  端口
 */
@property (nonatomic, assign) int port;

/**
 *  生成单例
 */
+ (instancetype)shareAccount;

/**
 *  保存最新的登陆用户数据到沙盒
 */
- (void)saveToSandBox;

@end
