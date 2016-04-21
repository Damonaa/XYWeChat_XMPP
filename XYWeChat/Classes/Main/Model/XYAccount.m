//
//  XYAccount.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//


#define kUser_Name  @"userName"
#define kPassword   @"password"
#define kLogin      @"login"

#import "XYAccount.h"

@implementation XYAccount

static NSString *domain = @"lixiaoya.local";
static NSString *host = @"127.0.0.1";
static int port = 5222;


+ (instancetype)shareAccount{
    return [[self alloc] init];
}

// 分配内存空间的时候创建对象
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static XYAccount *account;
    //仅仅执行一次，分配一次内存空间
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        account = [super allocWithZone:zone];
        
        //从沙盒中读取上一次用户的登陆信息
        NSUserDefaults *defaults = [ NSUserDefaults standardUserDefaults];
        account.loginUser = [defaults objectForKey:kUser_Name];
        account.loginPwd = [defaults objectForKey:kPassword];
        account.login = [defaults boolForKey:kLogin];
    });
    
    return account;
}

/**
 *  保存最新的登陆用户数据到沙盒
 */
- (void)saveToSandBox{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:kUser_Name];
    [defaults setObject:self.loginPwd forKey:kPassword];
    [defaults setBool:self.login forKey:kLogin];
    [defaults synchronize];
    
//    NSLog(@"");
}

- (NSString *)domain{
    return domain;
}
- (NSString *)host{
    return host;
}
- (int)port{
    return port;
}
@end
