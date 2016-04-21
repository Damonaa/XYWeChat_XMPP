//
//  UIStoryboard+XY.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "UIStoryboard+XY.h"

@implementation UIStoryboard (XY)
+ (void)showInitialVCWithName:(NSString *)name{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = storyBoard.instantiateInitialViewController;
}
@end
