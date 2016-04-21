//
//  XYXMPPTool.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYXMPPTool.h"

#import "XYAccount.h"

@interface XYXMPPTool ()<XMPPStreamDelegate>{

    XMPPResultBlock _resultBlock; //回调的结果
    
    XMPPReconnect *_reconnect;//重新连接
}

@end

@implementation XYXMPPTool

singleton_implementation(XYXMPPTool)


/**
 *  登陆流程
 *  1，初始化 XMPPStream
 *  2，连接到服务器 传一个jid
 *  3，连接成功，发送密码
 *  4， 发送一个“在线”的消息给服务器， 默认是不在线的
 */
#pragma mark - 用户登陆
- (void)xmppLogin:(XMPPResultBlock)resultBlock{
    //1,登陆前，先断开连接
    [_xmppStream disconnect];
    //保存resultType
    _resultBlock = resultBlock;
    
    //连接服务器开始登陆的操作
    [self connectToHost];
    
}

/**
 *  注册步骤
 * 1， 发送 “注册jid” 给服务器， 请求一个长连接
 * 2， 连接成功，发送注册的密码
 */
#pragma mark - 用户注册
- (void)xmppRegister:(XMPPResultBlock)resultBlock{
    //保存block
    _resultBlock = resultBlock;
    //去除之前的连接
    [_xmppStream disconnect];
    
    [self connectToHost];
}


#pragma mark - 用户注销
- (void)xmppLogout{
    //发送下线通知
    [self sendOffline];
    
    [_xmppStream disconnect];
}

#pragma mark - private method
/**
 *  初始化_xmppStream
 */
- (void)setupStream{
    //
    _xmppStream = [[XMPPStream alloc] init];
    
    //添加XMPP模块
    //1，添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //激活
    [_vCard activate:_xmppStream];
    
    //2， 添加头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    //3， 添加 花名册 模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    //4， 添加消息模块
    _msgArchivingStroge = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchivingStroge];
    [_msgArchiving activate:_xmppStream];
    
    //5, 自动连接
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    
    //设置代理。在子线程中执行
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

/**
 *  清空所有任务
 */
- (void)teardownStream{
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    [_reconnect deactivate];
    
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _reconnect = nil;
    _msgArchiving = nil;
    _msgArchivingStroge = nil;
    _xmppStream = nil;
    _avatar = nil;
    _vCard = nil;
    _roster = nil;
    _vCardStorage = nil;
    _rosterStorage = nil;
}
/**
 *  连接服务器
 */
- (void)connectToHost{
    if (!_xmppStream) {
        //初始化
        [self setupStream];
    }
    //1, 设置登陆用户的jid
    XMPPJID *myJid = nil;
    NSString *domain = [XYAccount shareAccount].domain;
    //判读是请求注册的还是请求登陆的
    if (self.isRegisterOperation) {//注册
        NSString *registerUser = [XYAccount shareAccount].registerUser;
        myJid = [XMPPJID jidWithUser:registerUser domain:domain resource:nil];
    }else{//登陆
        NSString *loginUser = [XYAccount shareAccount].loginUser;
        myJid = [XMPPJID jidWithUser:loginUser domain:domain resource:nil];
    }
    _xmppStream.myJID = myJid;
    
    //2, 设置主机地址
    _xmppStream.hostName = [XYAccount shareAccount].host;
    //3, 主机端口号 默认 为5222，
    _xmppStream.hostPort = [XYAccount shareAccount].port;
    
    //4, 发起连接
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        XYLog(@" %@", error);
    }else{
        XYLog(@"connec success");
    }
    
}
/**
 *  发送密码
 */
- (void)sendPwdToHost{
    NSError *error = nil;
    NSString *pwd = [XYAccount shareAccount].loginPwd;
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        XYLog(@"authenticateWithPassword error:%@", error);
    }
}
/**
 *  发送在线消息
 */
- (void)sendOnline{
    XMPPPresence *presence = [XMPPPresence presence];
    XYLog(@"%@", presence);
    [_xmppStream sendElement:presence];
    
}
/**
 *  发送离线消息
 */
- (void)sendOffline{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}
#pragma mark - XMPPStreamDelegate
//连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    XYLog(@"连接成功");
    //判断是登陆 还是注册, 发送密码
    if (self.registerOperation) {//注册
        NSError *error = nil;;
        NSString *registerPwd = [XYAccount shareAccount].registerPwd;
        [_xmppStream registerWithPassword:registerPwd error:&error];
    }else{//登陆
        [self sendPwdToHost];
    }
    
}
//断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    XYLog(@"%@", error);
}
//授权登陆成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    XYLog(@"授权登陆成功");
    //发送在线消息
    [self sendOnline];
    //回调reslutBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
        
        //清空block， 避免循环引用问题
        _resultBlock = nil;
    }
    
}
//授权登陆失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    XYLog(@"授权登陆失败");
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
        _resultBlock = nil;
    }
    
}
//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    XYLog(@"注册成功");
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
        _resultBlock = nil;
    }
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    XYLog(@" %@", error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
        _resultBlock = nil;
    }
    
}

/**
 *  消毁
 */
- (void)dealloc{
    [self teardownStream];
}

@end
