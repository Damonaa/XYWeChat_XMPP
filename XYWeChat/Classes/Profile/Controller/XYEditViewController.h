//
//  XYEditViewController.h
//  XYWeChat
//
//  Created by 李小亚 on 16/3/27.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYEditViewController;

@protocol XYEditViewControllerDelegate <NSObject>

- (void)editViewController:(XYEditViewController *)editVC didFinishSave:(id)sender;

@end

@interface XYEditViewController : UITableViewController


@property (nonatomic, weak) id<XYEditViewControllerDelegate> delegate;

/**
 *  个人信息中选中的cell
 */
@property (nonatomic, strong) UITableViewCell *selectedCell;

@end
