//
//  XYXMPPTool.h
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//出路用户注册登陆的工具类   单例模式

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

typedef enum{
    XMPPResultTypeLoginSuccess,
    XMPPResultTypeLoginFailure,
    XMPPResultTypeRegisterSuccess,
    XMPPResultTypeRegisterFailure
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void(^XMPPResultBlock)(XMPPResultType resultTye);

@interface XYXMPPTool : NSObject

singleton_interface(XYXMPPTool);

/**
 * 与服务器交互的核心
 */
@property (nonatomic, strong, readonly) XMPPStream *xmppStream; 

/**
 *  电子名片模块
 */
@property (nonatomic, strong, readonly) XMPPvCardTempModule *vCard;
/**
 *  电子名片数据存储
 */
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *vCardStorage;

/**
 *  花名册
 */
@property (nonatomic, strong, readonly) XMPPRoster *roster;
/**
 *  花名册数据存储
 */
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterStorage;

/**
 *  电子名片的头像
 */
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *avatar;


/**
 *  消息
 */
@property (nonatomic, strong, readonly) XMPPMessageArchiving *msgArchiving;

/**
 *  消息存储
 */
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *msgArchivingStroge;

/**
 *  标识， 用户是在注册还是在登陆， 默认NO 表示登陆操作
 */
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

/**
 *  用户登陆
 *
 *  @param resultType 登陆结果
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  用户注册
 *
 *  @param resultType 注册结果
 */
- (void)xmppRegister:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
- (void)xmppLogout;
@end
