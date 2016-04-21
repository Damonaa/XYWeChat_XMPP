//
//  XYPrifileViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/27.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYPrifileViewController.h"
#import "XYAccount.h"
#import "XYXMPPTool.h"
#import "XMPPvCardTemp.h"
#import "XYEditViewController.h"

@interface XYPrifileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, XYEditViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *weChatNum;
@property (weak, nonatomic) IBOutlet UILabel *orgName;
@property (weak, nonatomic) IBOutlet UILabel *departmentName;
@property (weak, nonatomic) IBOutlet UILabel *positionName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;
@property (weak, nonatomic) IBOutlet UILabel *emailAddress;

@end

@implementation XYPrifileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置子标题信息
    [self setupDetailLabe];
}

/**
 *  设置子标题信息
 */
- (void)setupDetailLabe{
    //获取名片
    XMPPvCardTemp *vCard = [XYXMPPTool sharedXYXMPPTool].vCard.myvCardTemp;
    //头像
    if (vCard.photo) {
        self.avatarImage.image = [UIImage imageWithData:vCard.photo];
    }
    //昵称
    self.nickName.text = vCard.nickname;
    //微信号
    self.weChatNum.text = [XYAccount shareAccount].loginUser;
    //公司
    self.orgName.text = vCard.orgName;
    //部门
    if (vCard.orgUnits.count > 0) {
        self.departmentName.text = vCard.orgUnits[0];
    }
    //职位
    self.positionName.text = vCard.title;
    //电话
    NSArray *phoneNums = vCard.telecomsAddresses;
    if (phoneNums.count > 0) {
       self.phoneNum.text = vCard.telecomsAddresses[0];
    }
    
//    self.phoneNum.text = vCard.note;
    
    
    //邮箱
    NSArray *emails = vCard.emailAddresses;
    if (emails.count > 0) {
        self.emailAddress.text = vCard.emailAddresses[0];
    }
    
//    self.emailAddress.text = vCard.mailer;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 0:
            XYLog(@"选择图片");
            [self choosePhoto];
            break;
            
        case 1:
            XYLog(@"跳转");
            [self performSegueWithIdentifier:@"toEditVCSegue" sender:cell];
            break;
            
        case 2:
            XYLog(@"nothing");
            break;
    }
}

/**
 *  选择图片
 */
- (void)choosePhoto{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"选中照片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *librAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        XYLog(@"相册");
        [self pickerImageWithIndex:0];
    }];
    UIAlertAction *camareAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        XYLog(@"相机");
        [self pickerImageWithIndex:1];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertCtr addAction:librAction];
    [alertCtr addAction:camareAction];
    [alertCtr addAction:cancelAction];
    
    [self presentViewController:alertCtr animated:YES completion:nil];
}

//选照片
- (void)pickerImageWithIndex:(NSInteger)index{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.sourceType = index == 0 ? UIImagePickerControllerSourceTypeSavedPhotosAlbum : UIImagePickerControllerSourceTypeCamera;
    pickerImage.allowsEditing = YES;
    pickerImage.delegate = self;
    
    [self presentViewController:pickerImage animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    XYLog(@"%@", info);
    self.avatarImage.image = info[UIImagePickerControllerEditedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //保存到服务器中
    [self editViewController:nil didFinishSave:nil];
    
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[XYEditViewController class]]) {
        XYEditViewController *editVC = destVC;
        editVC.selectedCell = sender;
        editVC.delegate = self;
    }
    
}

#pragma mark - XYEditViewControllerDelegate
//更新名片，上传到服务器
- (void)editViewController:(XYEditViewController *)editVC didFinishSave:(id)sender{
    
    XMPPvCardTemp *vCard = [XYXMPPTool sharedXYXMPPTool].vCard.myvCardTemp;
    
    vCard.photo = UIImageJPEGRepresentation(self.avatarImage.image, 0.75);
    vCard.nickname = self.nickName.text;
    vCard.orgName = self.orgName.text;
    
    if (self.departmentName.text != nil) {
        vCard.orgUnits = @[self.departmentName.text];
    }
    vCard.title = self.positionName.text;
    vCard.telecomsAddresses = @[self.phoneNum.text];
    
    vCard.emailAddresses = @[self.emailAddress.text];
    
    //更新上传
    [[XYXMPPTool sharedXYXMPPTool].vCard updateMyvCardTemp:vCard];
}
@end
