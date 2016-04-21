//
//  UIStoryboard+XY.h
//  XYWeChat
//
//  Created by 李小亚 on 16/3/26.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (XY)
/**
 *  切换UIStoryboard
 *
 *  @param name UIStoryboard的名称
 */
+ (void)showInitialVCWithName:(NSString *)name;
@end
