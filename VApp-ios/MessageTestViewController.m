//
//  MessageTestViewController.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/22.
//

#import "MessageTestViewController.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
@interface MessageTestViewController () <AgoraRtmChannelDelegate, AgoraRtmDelegate>

@property (nonatomic, strong) UITextField *loginInput;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *logoutButton;

@property (nonatomic, strong) UITextField *channelInput;
@property (nonatomic, strong) UIButton *joinChannel;
@property (nonatomic, strong) UIButton *leaveChannel;

@property (nonatomic, strong) UITextField *groupMessage;
@property (nonatomic, strong) UIButton *sendGroupMessage;

@property (nonatomic, strong) UITextField *peerMessage;
@property (nonatomic, strong) UIButton *sendPeerMessage;

@property NSString *appId;
@property NSString *loginUser;
@property NSString *channelId;

@property(nonatomic, strong)AgoraRtmKit* kit;
@property(nonatomic, strong)AgoraRtmChannel* channel;
@property(nonatomic, strong)AgoraRtmSendMessageOptions* options;

@end

@implementation MessageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    
    [self initAgroa];
}

#pragma mark - action

- (void) initViews {
    [self.view addSubview:self.loginInput];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.logoutButton];
    [self.view addSubview:self.channelInput];
    [self.view addSubview:self.joinChannel];
    [self.view addSubview:self.leaveChannel];
    [self.view addSubview:self.groupMessage];
    [self.view addSubview:self.sendGroupMessage];
    [self.view addSubview:self.peerMessage];
    [self.view addSubview:self.sendPeerMessage];
}

- (void)login {
    [self loginAgro];
}

- (void)logout {
    [self logoutAgroa];
}

- (void)joinChannelAction {
    [self joinAgroaChannel];
}

- (void)leaveChannelAction {
    [self leaveAgroaChannel];
}


- (void)sendMessageToGroup {
    [self sendAgroaGroupMessage];
}

- (void)sendMessageToPeer {
    [self sendAgroaPeerMessage];
}

#pragma mark - AgoraRtmDelegate

-(void)channel:(AgoraRtmChannel *)channel memberLeft:(AgoraRtmMember *)member
{
    NSString *info = [NSString stringWithFormat:@"%@ left channel %@", member.channelId, member.userId];
    NSLog(@"member left %@", info);
}

-(void)channel:(AgoraRtmChannel *)channel memberJoined:(AgoraRtmMember *)member
{
    NSString *info = [NSString stringWithFormat:@"%@ joined channel %@", member.channelId, member.userId];
    NSLog(@"member join %@", info);
}

// 显示收到的频道消息
- (void)channel:(AgoraRtmChannel *)channel messageReceived:(AgoraRtmMessage *)message fromMember:(AgoraRtmMember *)member
{
    NSString *info = [NSString stringWithFormat:@"Message received in channel: %@ from user: %@ content: %@",member.channelId, member.userId, message.text];
    NSLog(@"chennel message %@", info);
}

// 显示收到的点对点消息
- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString*)peerId
{
    NSString *info = [NSString stringWithFormat:@"Message received from user: %@ content: %@", peerId, message.text];
    NSLog(@"message received %@", info);
}
// 显示当前用户的连接状态
- (void)rtmKit:(AgoraRtmKit *)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason
{
    NSString *info = [NSString stringWithFormat:@"Connection status changed to: %ld Reason: %ld", (long)state, (long)reason];
    NSLog(@"connection changed %@", info);
}

#pragma mark - action Agora

- (void) initAgroa {
    self.appId = @"511767b5f6974accbae15e9022518589";
    
    // 创建 AgoraRtmKit 实例
    self.kit = [[AgoraRtmKit alloc] initWithAppId:self.appId delegate:self];
}

- (void)loginAgro {
    NSString *user = self.loginInput.text;
    self.loginUser = user;
    NSLog(@"LOGIN USER %@", user);
    [self.kit loginByToken:NULL user:user completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode != AgoraRtmLoginErrorOk){
            NSString *info = [NSString stringWithFormat:@"Login failed for user %@. Code: %ld",self.loginUser, (long)errorCode];
            NSLog(@"%@", info);
        } else {
            NSString *info = [NSString stringWithFormat:@"Login successful for user %@. Code: %ld",self.loginUser, (long)errorCode];
            NSLog(@"%@", info);
        }
    }];
}

- (void)logoutAgroa {
    [self.kit logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
        NSLog(@"logout");
    }];
}

- (void)joinAgroaChannel {
    self.channelId = self.channelInput.text;
    // 创建 RTM 频道
    self.channel = [self.kit createChannelWithId:self.channelId delegate:self];
    [self.channel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(errorCode == AgoraRtmJoinChannelErrorOk){
            NSString *info = [NSString stringWithFormat:@"Successfully joined channel %@ Code: %ld",self.channelId,(long)errorCode];
            NSLog(@"%@", info);
        } else {
            NSString *info = [NSString stringWithFormat:@"Failed to join channel %@ Code: %ld",self.channelId, (long)errorCode];
            NSLog(@"%@", info);
        }
    }];
}

- (void)leaveAgroaChannel {
    [self.channel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
        NSLog(@"leave channel");
    }];
}

- (void)sendAgroaGroupMessage {
    NSString *groupMessage = self.groupMessage.text;
    self.options.enableOfflineMessaging = true;
    
    [self.channel sendMessage:[[AgoraRtmMessage alloc] initWithText:groupMessage] sendMessageOptions:self.options completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        NSLog(@"message send to group %@", errorCode);
        if (errorCode == AgoraRtmSendChannelMessageErrorOk){}else{}
    }];
}

- (void)sendAgroaPeerMessage {
    NSString *peerMessage = self.peerMessage.text;
    
    NSString *peerId = @"userA";
    [self.kit sendMessage:[[AgoraRtmMessage alloc] initWithText:peerMessage] toPeer:peerId  completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        NSLog(@"message send to peer");
    }];
}



#pragma mark - init

- (UITextField *)loginInput {
    if (!_loginInput) {
        _loginInput = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 120, 40)];
        _loginInput.borderStyle = UITextBorderStyleLine;
        _loginInput.placeholder = @"请输入用户id";
    }
    
    return _loginInput;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setFrame:CGRectMake(10, 150, 80, 40)];
        [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loginButton;
}

- (UIButton *)logoutButton {
    if(!_logoutButton) {
        _logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logoutButton setTitle:@"登出" forState:UIControlStateNormal];
        [_logoutButton setFrame:CGRectMake(120, 150, 80, 40)];
        [_logoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _logoutButton;
}

- (UITextField *)channelInput {
    if (!_channelInput) {
        _channelInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 120, 40)];
        _channelInput.borderStyle = UITextBorderStyleLine;
        _channelInput.placeholder = @"请输入chennel ID";
    }
    
    return _channelInput;
}

- (UIButton *)joinChannel {
    if (!_joinChannel) {
        _joinChannel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinChannel setTitle:@"加入频道" forState:UIControlStateNormal];
        [_joinChannel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_joinChannel setFrame:CGRectMake(10, 250, 80, 40)];
        [_joinChannel addTarget:self action:@selector(joinChannelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _joinChannel;
}

- (UIButton *)leaveChannel {
    if (!_leaveChannel) {
        _leaveChannel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leaveChannel setTitle:@"离开频道" forState:UIControlStateNormal];
        [_leaveChannel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_leaveChannel setFrame:CGRectMake(120, 250, 80, 40)];
        [_leaveChannel addTarget:self action:@selector(leaveChannelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _leaveChannel;
}

- (UITextField *)groupMessage {
    if (!_groupMessage) {
        _groupMessage = [[UITextField alloc] initWithFrame:CGRectMake(10, 300, 120, 40)];
        _groupMessage.borderStyle = UITextBorderStyleLine;
        _groupMessage.placeholder = @"群发消息";
    }
    return _groupMessage;
}

- (UIButton *)sendGroupMessage {
    if (!_sendGroupMessage) {
        _sendGroupMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendGroupMessage setTitle:@"群发消息" forState:UIControlStateNormal];
        [_sendGroupMessage setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_sendGroupMessage setFrame:CGRectMake(10, 350, 80, 40)];
        [_sendGroupMessage addTarget:self action:@selector(sendMessageToGroup) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendGroupMessage;
}

- (UITextField *)peerMessage {
    if (!_peerMessage) {
        _peerMessage = [[UITextField alloc] initWithFrame:CGRectMake(10, 400, 120, 40)];
        _peerMessage.borderStyle = UITextBorderStyleLine;
        _peerMessage.placeholder = @"一对一消息";
    }
    
    return _peerMessage;
}

- (UIButton *)sendPeerMessage {
    if (!_sendPeerMessage) {
        _sendPeerMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendPeerMessage setTitle:@"发送" forState:UIControlStateNormal];
        [_sendPeerMessage setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_sendPeerMessage setFrame:CGRectMake(10, 450, 80, 40)];
        [_sendPeerMessage addTarget:self action:@selector(sendMessageToPeer) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendPeerMessage;
}


@end
