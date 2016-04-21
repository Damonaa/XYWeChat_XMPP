//
//  XYContactsViewController.m
//  XYWeChat
//
//  Created by 李小亚 on 16/3/27.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYContactsViewController.h"
#import "XYXMPPTool.h"
#import "XYChatViewController.h"

@interface XYContactsViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsCtr;

@end

@implementation XYContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载用户通讯录
    [self loadUser];
}

//加载用户通讯录
- (void)loadUser{
    //好友资料已经被下载到了本地的沙盒中，查询 获取
    
    //1, 上下文, 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [XYXMPPTool sharedXYXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2. request, 请求查询的是那张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@", @"none"];
    request.predicate = pre;
    
    //3, 执行请求

    _resultsCtr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultsCtr.delegate = self;
    NSError *error = nil;
    //
    [_resultsCtr performFetch:&error];
    
    XYLog(@"%@", _resultsCtr.fetchedObjects);
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.resultsCtr.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    
    XMPPUserCoreDataStorageObject *contcat = self.resultsCtr.fetchedObjects[indexPath.row];
    

    cell.textLabel.text = contcat.displayName;
    
    /**
     *  contcat.sectionNum
        0: 空闲 在线
        1: 离开，电话中， 正忙
        2: 隐身，下线
     */
    
    XYLog(@"%@: %@", contcat.displayName, contcat.sectionNum);
  
    switch ([contcat.sectionNum integerValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"没空";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            cell.detailTextLabel.text = @"nope";
            break;
    }
    
    //设置头像
    if (contcat.photo) {
        cell.imageView.image = contcat.photo;
    }else{
        NSData *avatarData = [[XYXMPPTool sharedXYXMPPTool].avatar photoDataForJID:contcat.jid];
        cell.imageView.image = [UIImage imageWithData:avatarData];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPPUserCoreDataStorageObject *contact = self.resultsCtr.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[XYXMPPTool sharedXYXMPPTool].roster removeUser:contact.jid];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPJID *friendJid = [self.resultsCtr.fetchedObjects[indexPath.row] jid];
    [self performSegueWithIdentifier:@"toChatVC" sender:friendJid];
}
//将点击的好友的jid传到下一个控制器
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[XYChatViewController class]]) {
        XYChatViewController *chatVC = destVC;
        chatVC.friendJid = sender;
    }
}
@end
