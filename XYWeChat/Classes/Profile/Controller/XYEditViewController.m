//
//  XYEditViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/27.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYEditViewController.h"

@interface XYEditViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFiled;

@end

@implementation XYEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.selectedCell.textLabel.text;
    self.textFiled.text = self.selectedCell.detailTextLabel.text;
}

- (IBAction)savebtnClick:(id)sender {
    //更改cell的内容
    self.selectedCell.detailTextLabel.text = self.textFiled.text;
    [self.selectedCell layoutSubviews];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(editViewController:didFinishSave:)]) {
        [self.delegate editViewController:self didFinishSave:sender];
    }
    
}

@end
