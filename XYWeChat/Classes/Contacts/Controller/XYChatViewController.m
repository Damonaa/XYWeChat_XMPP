//
//  XYChatViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/29.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYChatViewController.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface XYChatViewController ()<UITableViewDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *textFiled;

@property (weak, nonatomic) IBOutlet UIView *inputView;

@property (nonatomic, strong) NSFetchedResultsController  *reslutCtr;
@end

@implementation XYChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    XYLog(@"%@", _friendJid);
    //加载数据库的聊天数据
    //1， 上下文
    NSManagedObjectContext *msgContext = [XYXMPPTool sharedXYXMPPTool].msgArchivingStroge.mainThreadManagedObjectContext;
    //2, 请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //过滤， 当前登陆用户，以及对话好友
    NSString *loginUser = [XYXMPPTool sharedXYXMPPTool].xmppStream.myJID.bare;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", loginUser, self.friendJid.bare];
    request.predicate = pre;
    
    //按时间排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //3, 执行请求
    _reslutCtr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _reslutCtr.delegate = self;
    NSError *error = nil;
    [_reslutCtr performFetch:&error];
    
    
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
//键盘弹出，移动输入框
- (void)keyboardWillChangeFrame:(NSNotification *)noti{
    XYLog(@"n%@", noti.userInfo);
    
    float duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect lastRect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float move = lastRect.origin.y - self.view.frame.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        self.inputView.transform = CGAffineTransformMakeTranslation(0, move);
    }];
    
    [self scrollTableViewToBottom];
}
#pragma mark - NSFetchedResultsControllerDelegate
//数据库发生变化的时候调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
    
    [self scrollTableViewToBottom];
  
}

- (void)scrollTableViewToBottom{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.reslutCtr.fetchedObjects.count - 1  inSection:0];
    
    //    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (IBAction)choosePhoto:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
    
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    XYLog(@"%@", info);
    UIImage *pickerImage = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //发送文件（图片）方案一
    [self sendAttachmentWithData:UIImagePNGRepresentation(pickerImage) bodyTypy:@"image"];
    /*************************发送文件（图片）方案二*****************/
    //需要文件服务器支持
//    [self sendImg:pickerImage];
    
}
#pragma mark - 发送图片

/*************************发送文件（图片）方案二*****************/
- (void)sendImg:(UIImage *)img{
    //1, 把需要发送的文件上传到服务器中
    //1.1, 定义文件名
    NSDateFormatter *dataFor = [[NSDateFormatter alloc] init];
    dataFor.dateFormat = @"yyyyMMddHHmmss";
    NSString *curTime =[dataFor stringFromDate:[NSDate date]];
    
    NSString *fileName = [[XYAccount shareAccount].loginUser stringByAppendingString:curTime];
    //1.2拼接上传路径
    NSString *uploadPath = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    HttpTool *httpTool = [[HttpTool alloc] init];
    [httpTool uploadData:UIImagePNGRepresentation(img) url:[NSURL URLWithString:uploadPath] progressBlock:nil completion:^(NSError *error) {
        if (!error) {
            XYLog(@"上传成功");
            
            XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
            [msg addAttributeWithName:@"bodyType" stringValue:@"image"];
            [msg addBody:uploadPath];
            
            [[XYXMPPTool sharedXYXMPPTool].xmppStream sendElement:msg];
        }else{
            XYLog(@"upload fail");
        }
    }];
}
/*************************发送文件（图片）方案二*****************/

/*************************发送文件（图片）方案一*****************/

- (void)sendAttachmentWithData:(NSData *)data bodyTypy:(NSString *)bodyType{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //为发送的字段 添加属性
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    //必须要有body， 否则xmpp不认
    [msg addBody:bodyType];
    
    //将附件转成字符串
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    //将附件字符串添加到xml中, 添加节点
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    [msg addChild:attachment];
    
    [[XYXMPPTool sharedXYXMPPTool].xmppStream sendElement:msg];
    XYLog(@"%@", msg);
}
/*************************发送文件（图片）方案一*****************/
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _reslutCtr.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
   
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _reslutCtr.fetchedObjects[indexPath.row];
    
    //获取XML 解析
    XMPPMessage *message = msgObj.message;
    
    NSString *bodyTyep = [message attributeStringValueForName:@"bodyType"];
    
//  /*************************发送文件（图片）方案一*****************/
    //获取聊天信息
    if ([bodyTyep isEqualToString:@"image"]) {//图片
        //遍历message子节点
        NSArray *children = message.children;
        for (XMPPElement *note in children) {
            //获取节点的名字
            if ([[note name] isEqualToString:@"attachment"]) {
                //字符串转图片
                NSString *imageStr = [note stringValue];
                NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imageStr options:0];
                UIImage *img = [UIImage imageWithData:imgData];
                cell.imageView.image = img;
                cell.textLabel.text = nil;
            }
        }
        
        
    }else if ([bodyTyep isEqualToString:@"sound"]){//文本
        
    }else{
        cell.textLabel.text = msgObj.body;
    }
    
    /*************************发送文件（图片）方案一*****************/
    
    /*************************发送文件（图片）方案二*****************/
    
//    if ([bodyTyep isEqualToString:@"image"]) {
//        NSString *url = msgObj.body;
//        
//        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ihead_007"]];
//        
//        cell.textLabel.text = nil;
//    }else{
//        cell.textLabel.text = msgObj.body;
//        cell.imageView.image = nil;
//    }
    /*************************发送文件（图片）方案二*****************/
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.textFiled resignFirstResponder];
}
#pragma mark - UITextFieldDelegate
//发送消息
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *text = textField.text;
    
    //发消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:text];
    [[XYXMPPTool sharedXYXMPPTool].xmppStream sendElement:msg];
    
    textField.text = nil;
    
    return YES;
}
@end
