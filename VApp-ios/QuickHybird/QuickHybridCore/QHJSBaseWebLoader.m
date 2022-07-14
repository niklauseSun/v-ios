//
//  QHJSBaseWebLoader.m
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSBaseWebLoader.h"
#import "WKWebViewJavascriptBridge.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "JSONKit.h"
#import "AFNetworking.h"
#import <SDWebImage/SDWebImage.h>

#define ssRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


static NSString *KVOContext;

@interface QHJSBaseWebLoader () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, AgoraRtmChannelDelegate, AgoraRtmDelegate, AgoraRtcEngineDelegate>
/** JSBridge */
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
/** 页面加载进度条 */
@property (nonatomic, weak) UIProgressView *progressView;
/** 加载进度条的高度约束 */
@property (nonatomic, strong) NSLayoutConstraint *progressH;

/** 导航栏左上角页面返回按钮 */
@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;

/** 导航栏右上角按钮，1在右，2在左 */
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem1;
/** 导航栏右上角按钮，1在右，2在左 */
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem2;

/** 导航栏左上角按钮 */
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;


@property (nonatomic, strong) UIImageView *splashImageView;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, weak) NSTimer *timer;

@property int count;


// 声网代码

@property (nonatomic, strong) AgoraRtmKit *kit;
@property (nonatomic, strong) AgoraRtmChannel* channel;
@property (nonatomic, strong) AgoraRtmSendMessageOptions* options;
@property NSString* appID;
@property NSString* token;

@property NSString* uid;
@property NSString* peerID;
@property NSString* channelID;
@property NSString* peerMsg;
@property NSString* channelMsg;

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;

@property NSString *agoraAudioAppId;
@property NSString *agoraAudioToken;
@property NSString *videoChannelName;

@property NSString* text;

/**
 声网客户声明
 */

@property NSString* bussinessHeadImage;
@property NSString* bussinessIdentity;
@property NSString* bussinessNickname;
@property NSString* bussinessUid;
@property NSString* bussinessAccid;

@property NSString* modleUrl;
@property NSString* modelId;

@property NSString* customerHeadImage;
@property NSString* customerIdentity;
@property NSString* customerNickname;
@property NSString* customerUid;
@property NSString* customerAccid;

@property NSString* businessType;

@end

@implementation QHJSBaseWebLoader

#pragma mark --- 生命周期

+ (void)initialize {
    //改变User-Agent
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获取默认UA
        NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 15_0_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";
        NSString *version = [QHJSInfo getQHJSVersion];
        NSString *customerUA = [userAgent stringByAppendingString:[NSString stringWithFormat:@" QuickHybridJs/%@", version]];

        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customerUA}];
        [[NSUserDefaults standardUserDefaults] synchronize];

        WKWebView *_webview = [[WKWebView alloc] init];

        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [_webview loadRequest:request];

        [_webview evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {

            if ([result isKindOfClass:[NSString class]]) {
                NSString *userAgent = result;
                NSString *version = [QHJSInfo getQHJSVersion];
                NSString *customerUA = [userAgent stringByAppendingString:[NSString stringWithFormat:@" QuickHybridJs/%@", version]];

                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customerUA}];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 15_0_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";
                NSString *version = [QHJSInfo getQHJSVersion];
                NSString *customerUA = [userAgent stringByAppendingString:[NSString stringWithFormat:@" QuickHybridJs/%@", version]];

                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customerUA}];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.modleUrl = @"https://beyond.3dnest.biz/silversea_dev/takelook/?m=7051c064_o0fM_b6f9";
    self.modelId = @"7051c064_o0fM_b6f9";
    // 创建WKWebView
    [self createWKWebView];
    
    [self.view addSubview:self.splashImageView];
    [self.view addSubview:self.closeButton];
    self.count = 5;
    
//    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
    
    // 注册KVO
    [self.wv addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:&KVOContext];
    [self.wv addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:&KVOContext];
    
    // 注册框架API
    [self.bridge registerFrameAPI];
    
    // 加载H5页面
    
    self.appID = @"3dc9b22d18a8405ea10efc0fcc2054d7"; // appId;
    self.agoraAudioAppId = @"3dc9b22d18a8405ea10efc0fcc2054d7";
    self.agoraAudioToken = @"0063dc9b22d18a8405ea10efc0fcc2054d7IADnBF5ZR63DTgvhR0S+tKqlRJqJH9LmVbFp4Qf+T8x0pz37XygAAAAAEABgsZT+f7o+YQEAAQB+uj5h";

    // rtm 初始化
    self.kit = [[AgoraRtmKit alloc] initWithAppId:self.appID delegate:self];
    
    [self requestBaseUrl];
    [self performSelector:@selector(delayJump) withObject:nil afterDelay:5.0];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateTimer)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //导航栏参数
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([[[self.params valueForKey:@"pageStyle"] stringValue] isEqualToString:@"-1"]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }

    [self setStatusBarBackgroundColor:ssRGBHex(0xCAC0BB)];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    if (@available(iOS 13.0, *)) {
        static UIView *statusBar = nil;
        if (!statusBar) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                statusBar = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
                
                statusBar.backgroundColor = color;
                [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
            });
        } else {
            statusBar.backgroundColor = color;
        }
    } else {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
    }
}

- (void)updateTimer {
    self.count = self.count - 1;
    
    NSString *label = [NSString stringWithFormat:@"%ds", self.count];
    
    [self.closeButton setTitle:label forState:UIControlStateNormal];
}

- (void)delayJump {
    [self.splashImageView setHidden:YES];
    [self.closeButton setHidden:YES];
    [self.timer invalidate];
}

#pragma mark --- 语音初始化
- (void)initializeAgoraEngine {
    // 初始化 AgoraRtcEngineKit 对象
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:self.agoraAudioAppId delegate:self];
}

- (void)leavelAudioChannel {
    [self.agoraKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
        NSLog(@"退出语音频道成功");
    }];
}

- (void)adjustAudioVolume: (int) num {
    [self.agoraKit adjustRecordingSignalVolume: num];
}
#pragma mark --- 语音监听

- (void)rtmKit:(AgoraRtmKit *)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    NSLog(@"connection state changed %d reason = %d", (int)state, (int)reason);
}


#pragma mark --- 声网云信令初始化

- (void)loginWithUserId:(NSString *)userId andToken:(NSString *)token {
    self.uid = userId;
    self.token = token;
    
    [self.kit loginByToken:token user:userId completion:^(AgoraRtmLoginErrorCode errorCode) {
        switch (errorCode) {
            case AgoraRtmLoginErrorOk:
                NSLog(@"Login rtm success");
                // 用户成功登录！
                [self updateUserStatus:self.uid withStatus:101];
                break;
            case AgoraRtmLoginErrorUnknown:
                NSLog(@"Login Error Unknown");
                break;
            default:
                break;
        }
        if (errorCode != AgoraRtmLoginErrorOk){
            self.text = [NSString stringWithFormat:@"Login failed for user %@. Code: %ld",self.uid, (long)errorCode];
            NSLog(@"%@", self.text);
        }
    }];
}

- (void)logout {
    [self.kit logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
        if (errorCode == AgoraRtmLogoutErrorOk){
            self.text = [NSString stringWithFormat:@"Logout successful. Code: %ld",(long)errorCode];
            NSLog(@"%@", self.text);
        } else {
            self.text = [NSString stringWithFormat:@"Logout failed. Code: %ld",(long)errorCode];
            NSLog(@"%@", self.text);
        }
    }];
}

- (void)joinChannel: (NSString *)channelName {
    self.channelID = channelName;
    self.channel = [self.kit createChannelWithId:self.channelID delegate:self];
    [self.channel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(errorCode == AgoraRtmJoinChannelErrorOk){
            self.text = [NSString stringWithFormat:@"Successfully joined channel %@ Code: %ld",self.channelID,(long)errorCode];
            NSLog(@"%@", self.text);
        } else {
            self.text = [NSString stringWithFormat:@"Failed to join channel %@ Code: %ld",self.channelID, (long)errorCode];
            NSLog(@"%@", self.text);
        }
    }];
}

- (void)leaveChannel: (NSString *)channelName {
    [self.channel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
        if (errorCode == AgoraRtmLeaveChannelErrorOk){
            self.text = [NSString stringWithFormat:@"Leave channel successful Code: %ld", (long)errorCode];
        } else {
            self.text = [NSString stringWithFormat:@"Failed to leave channel Code: %ld", (long)errorCode];
        }
        NSLog(@"%@", self.text);
    }];
}

- (void)sendGroupMessage: (NSString *)message {
    AgoraRtmMessage *rtMessage = [[AgoraRtmMessage alloc] initWithText:message];
    self.options.enableOfflineMessaging = true;
    [self.channel sendMessage:rtMessage sendMessageOptions:self.options completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            self.text = [NSString stringWithFormat:@"Message sent to channel %@ : %@", self.channelID, self.channelMsg];
        } else {
            self.text = [NSString stringWithFormat:@"Message failed to send to channel %@ : %@ ErrorCode: %ld", self.channelID, self.channelMsg, (long)errorCode];
        }
        NSLog(@"%@", self.text);
    }];
}

- (void)sendPeerMessage:(NSString *)message toPeerId:(NSString *)peerId {
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:message];
    self.peerMsg = message;
    self.peerID = peerId;
    [self.kit sendMessage:rtmMessage toPeer:peerId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            self.text = [NSString stringWithFormat:@"Message sent from user: %@ to user: %@ content: %@", self.uid, self.peerID, self.peerMsg];
        } else {
            self.text = [NSString stringWithFormat:@"Message failed to send from user: %@ to user: %@ content: %@ Error: %ld", self.uid, self.peerID, self.peerMsg, (long)errorCode];
        }
        NSLog(@"%@", self.text);
    }];
}

#pragma mark --- 声网云信令监听
- (void)channel:(AgoraRtmChannel *)channel memberLeft:(AgoraRtmMember *)member {
    self.text = [NSString stringWithFormat:@"%@ left channel %@", member.channelId, member.userId];
    NSLog(@"member left %@", self.text);
}

- (void)channel:(AgoraRtmChannel *)channel memberJoined:(AgoraRtmMember *)member
{
    self.text = [NSString stringWithFormat:@"%@ joined channel %@", member.channelId, member.userId];
    NSLog(@"member joined %@", self.text);
}

// 从群组中收到信息
- (void)channel:(AgoraRtmChannel *)channel messageReceived:(AgoraRtmMessage *)message fromMember:(AgoraRtmMember *)member {
    self.text = [NSString stringWithFormat:@"Message received in channel: %@ from user: %@ content: %@",member.channelId, member.userId, message.text];
    NSLog(@"%@", self.text);
}

// 从某个人中收到信息
- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    self.text = [NSString stringWithFormat:@"Message received from user: %@ content: %@", peerId, message.text];
    
    if ([message.text isKindOfClass:[NSString class]]) {
        NSDictionary *receiveData = [self parseJSON:message.text];
        
        NSDictionary *data = [receiveData valueForKey:@"data"];
        
        if (data && [[data valueForKey:@"state"] isEqualToString:@"initdone"]) {
            NSLog(@"receive message --- initdone");
            
            if ([self.peerID isEqual:@""] && ![self.peerID isEqualToString:peerId]) {
                
            } else {
                if (![self.businessType isEqualToString:@"bussiness"]) {
                    [self onChatUpdate:@"3"];
                }
                [self onData:message.text];
            }
        } else if ([receiveData valueForKey:@"type"]) {
            NSString *type = [receiveData valueForKey:@"type"];
            
            if ([type isEqualToString:@"mini-hangup"]) {
                // 挂断
                [self onChatUpdate:@"8"];
                [self leavelAudioChannel];
                [self updateUserStatus:self.bussinessUid withStatus:101];
            } else if ([type isEqualToString:@"app-hangup"]) {
                if ([[receiveData valueForKey:@"hangupType"] isEqualToString:@"7"]) {
                    [self onChatUpdate:@"7"];
                } else {
                    [self onChatUpdate:@"5"];
                }
            } else if ([type isEqualToString:@"app-call"]) {
                NSString *houseUrl = [receiveData valueForKey:@"houseurl"];
                
                NSDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
                [dict setValue:houseUrl forKey:@"houseurl"];
                NSString *res = [self dictToStr: dict];
                [self onData:res];
                
                NSString *bid = [data valueForKey:@"bussinessUid"];
                
                if (![[data valueForKey:@"bussinessUid"] isEqualToString:@""]) {
                    self.bussinessHeadImage = [data valueForKey:@"bussinessUid"];
                }
                
                if (![[data valueForKey:@"bussinessIdentity"] isEqualToString:@""]) {
                    self.bussinessIdentity = [data valueForKey:@"bussinessIdentity"];
                }
                if (![[data valueForKey:@"bussinessNickName"] isEqualToString:@""]) {
                    self.bussinessNickname = [data valueForKey:@"bussinessNickName"];
                }
                if (![[data valueForKey:@"bussinessUid"] isEqualToString:@""]) {
                    self.bussinessUid = [data valueForKey:@"bussinessUid"];
                }
                if (![[data valueForKey:@"bussinessAccid"] isEqualToString:@"0"]) {
                    self.bussinessAccid = [data valueForKey:@"bussinessAccid"];
                }
                if (![[data valueForKey:@"customerHeadImage"] isEqualToString:@""]) {
                    self.customerHeadImage = [data valueForKey:@"customerHeadImage"];
                }
                if (![[data valueForKey:@"customerIdentity"] isEqualToString:@""]) {
                    self.customerIdentity = [data valueForKey:@"customerIdentity"];
                }
                if (![[data valueForKey:@"customerUid"] isEqualToString:@"0"]) {
                    self.customerUid = [data valueForKey:@"customerUid"];
                }
                if ([data valueForKey:@"customerNickName"]) {
                    if (![[data valueForKey:@"customerNickName"] isEqualToString:@""]) {
                        self.customerNickname = [data valueForKey:@"customerNickName"];
                    }
                    
                }
                self.bussinessUid = bid;
                
                [self updateCustomerAndBussinessId:message.text];
            } else if ([type isEqualToString:@"accept"]) {
                NSString *bid = [data valueForKey:@"bussinessUid"];
                [self joinChannelWithId:self.uid andChanneName:bid];
                [self updateCustomerAndBussinessId:message.text];
                [self onChatUpdate:@"3"];
            } else {
                [self onData:message.text];
            }
        }
        
        
        
    }
    
    NSLog(@"%@", self.text);
}

- (void)updateCustomerAndBussinessId:(NSString *)message {
    NSDictionary *receiveData = [self parseJSON:message];
    
    NSDictionary *data = [receiveData valueForKey:@"data"];
    
    if ([data valueForKey:@"customerUid"]) {
        NSString *customerUid = [data valueForKey:@"customerUid"];
        if ([self.businessType isEqualToString:@"bussiness"]) {
            self.peerID = customerUid;
        } else {
            self.uid = customerUid;
        }
    }
    
    if ([data valueForKey:@"bussinessUid"]) {
        NSString *bussinessUid = [data valueForKey:@"bussinessUid"];
        if ([self.businessType isEqualToString:@"bussiness"]) {
            self.uid = bussinessUid;
        } else {
            self.peerID = bussinessUid;
        }
    }
}



/**
 创建WKWebView
 */
- (void)createWKWebView {
    // 创建进度条
    UIProgressView *progressView = [[UIProgressView alloc] init];
    progressView.progressTintColor = [UIColor lightGrayColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]
                                ]];
    NSLayoutConstraint *progressH = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:1.5];
    self.progressH = progressH;
    [progressView addConstraint:self.progressH];
    
    // 创建webView容器
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentVC = [[WKUserContentController alloc] init];
    
//    let preferences = WKPreferences()
//    preferences.javaScriptEnabled = true
//    let configuration = WKWebViewConfiguration()
//    configuration.preferences = preferences
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = YES;
    
    webConfig.preferences = preferences;
    
    [self addScripts: userContentVC];
    
    webConfig.userContentController = userContentVC;
    
    WKWebView *wk = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
    [self.view addSubview:wk];
    self.wv = wk;
    self.wv.navigationDelegate = self;
    self.wv.UIDelegate = self;
    self.wv.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置约束
    [self.view addConstraints:@[// left
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                // bottom
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                // right
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                // top
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:progressView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                ]];
    
    //jsBridge
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.wv];
    [self.bridge setWebViewDelegate:self];
    
    [self.wv.configuration.userContentController addScriptMessageHandler:self.bridge name:@"WKWebViewJavascriptBridge"];
//    [self.wv.configuration.userContentController addScriptMessageHandler:self.bridge name:@"WebBridge"];

}

- (void)addScripts:(WKUserContentController *)userConfig {
    [userConfig addScriptMessageHandler:self name:@"sendVRCard"];
    [userConfig addScriptMessageHandler:self name:@"sendUserInfo"];
    [userConfig addScriptMessageHandler:self name:@"getUserInfo"];
    [userConfig addScriptMessageHandler:self name:@"call"];
    [userConfig addScriptMessageHandler:self name:@"hangup"];
    [userConfig addScriptMessageHandler:self name:@"refuse"];
    [userConfig addScriptMessageHandler:self name:@"accept"];
    [userConfig addScriptMessageHandler:self name:@"getLog"];
    [userConfig addScriptMessageHandler:self name:@"mute"];
    [userConfig addScriptMessageHandler:self name:@"unmute"];
    [userConfig addScriptMessageHandler:self name:@"initMessageAction"];
    [userConfig addScriptMessageHandler:self name:@"login"];
    [userConfig addScriptMessageHandler:self name:@"jumpToWebView"];
    [userConfig addScriptMessageHandler:self name:@"sendData"];
    [userConfig addScriptMessageHandler:self name:@"logout"];
    [userConfig addScriptMessageHandler:self name:@"isRealOnLine"];
}

/**
 加载地址
 */
- (void)loadHTML {
    NSString *url = [[self.params valueForKey:@"pageUrl"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if ([url hasPrefix:@"http"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.wv loadRequest:request];
    } else {
        // 加载本地页面，iOS 8不支持
        if (@available(iOS 9.0, *)) {
            //本地路径的html页面路径
            NSURL *pathUrl = [NSURL URLWithString:url];
            NSURL *bundleUrl = [[NSBundle mainBundle] bundleURL];
            [self.wv loadFileURL:pathUrl allowingReadAccessToURL:bundleUrl];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发生错误" message:@"本地页面的方式不支持iOS9以下" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)loadHtml:(NSString *) url {
    if ([url hasPrefix:@"http"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.wv loadRequest:request];
    } else {
        // 加载本地页面，iOS 8不支持
        if (@available(iOS 9.0, *)) {
            //本地路径的html页面路径
            NSURL *pathUrl = [NSURL URLWithString:url];
            NSURL *bundleUrl = [[NSBundle mainBundle] bundleURL];
            [self.wv loadFileURL:pathUrl allowingReadAccessToURL:bundleUrl];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发生错误" message:@"本地页面的方式不支持iOS9以下" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark --- KVO

/**
 KVO监听的相应方法
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // 判断是否是本类注册的KVO
    if (context == &KVOContext) {
        // 设置title
        if ([keyPath isEqualToString:@"title"]) {
            NSString *title = change[@"new"];
            self.navigationItem.title = title;
        }
        // 设置进度
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            NSNumber *progress = change[@"new"];
            self.progressView.progress = progress.floatValue;
            if (progress.floatValue == 1.0) {
                self.progressH.constant = 0;
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.25 animations:^{
                    [weakSelf.view layoutIfNeeded];
                }];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark --- WKNavigationDelegate

//这个代理方法不实现也能正常跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        //支持 a 标签 target = ‘_blank’ ;
        if (navigationAction.targetFrame == nil) {
            [self openWindow:navigationAction];
        } else if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            [self setCloseBarBtn];
        }
        
        NSURL *url = navigationAction.request.URL;
        if ([url.absoluteString hasPrefix:@"https://itunes.apple.com/cn/app"]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

/**
 特殊跳转
 */
- (void)openWindow:(WKNavigationAction *)navigationAction {
    self.progressView.progress = 0;
    self.progressH.constant = 1;
    [self.wv loadRequest:navigationAction.request];
}

- (void)setCloseBarBtn {
    //初始化返回按钮
    self.closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeBtnAction:)];
    
    if (self.leftBarButtonItem) {
        return;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[];
    if (self.backBarButton) {
        self.navigationItem.leftBarButtonItems = @[self.backBarButton, self.closeButtonItem];
    }
}

- (void)closeBtnAction:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"]) {
        WVJBResponseCallback backCallback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"Native pop Action"};
        backCallback(dic);
    } else {
        NSString *jsStr = [NSString stringWithFormat:@"closeAction()"];
        [self.wv evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                [self backAction];
            }
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

//重定向
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self setCloseBarBtn];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    // ErroeCode
    // -1001 请求超时   -1009 似乎已断开与互联网的连接
    if (error.code == -1009) {
        NSLog(@"似乎已断开与互联网的连接");
        return;
    }
    if (error.code == -1001) {
        NSLog(@"请求超时");
        return;
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    //页面加载异常
    NSString *url = [self.params objectForKey:@"pageUrl"];
    //反馈页面加载错误
    [self.bridge handleErrorWithCode:0 errorUrl:url errorDescription:error.localizedDescription];
}

// https校验
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

#pragma mark --- WKUIDelegate
//WebVeiw关闭
- (void)webViewDidClose:(WKWebView *)webView {
    
}

//显示一个JavaScript警告面板
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

//显示一个JavaScript确认面板
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [alertController addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

//显示一个JavaScript文本输入面板
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- QHJSPageApi

//刷新方法
- (void)reloadWKWebview {
    [self.wv reload];
}

#pragma mark --- QHJSNavigatorApi

//重写拦截系统侧滑返回的方法
- (BOOL)hookInteractivePopGestureRecognizerEnabled {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookSysBack"]) {
        WVJBResponseCallback sysBackCallback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookSysBack"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"Native pop Action"};
        sysBackCallback(dic);
    }
    return self.interactivePopGestureRecognizerEnabled;
}

//重写导航栏左侧返回按钮方法
- (void)backAction {
    if (self.shouldPop) {
        [super backAction];
    } else {
        if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"]) {
            WVJBResponseCallback backCallback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"];
            NSDictionary *dic = @{@"code":@1, @"msg":@"Native pop Action"};
            backCallback(dic);
        }
    }
}

/**
 设置导航栏按钮的方法
 */
- (void)setRightNaviItemAtIndex:(NSInteger)index andTitle:(NSString *)title OrImageUrl:(NSString *)imageUrl {
    if (index == 1) {
        if (title) {
            self.rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem1:)];
        } else {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (imageData) {
                self.rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:imageData] style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem1:)];
            } else {
                self.rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem1:)];
            }
        }
    } else {
        if (title) {
            self.rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem2:)];
        } else {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (imageData) {
                self.rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:imageData] style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem2:)];
            } else {
                self.rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem2:)];
            }
        }
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = @[];
    
    if (self.rightBarButtonItem1) {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItems = @[self.rightBarButtonItem1, self.rightBarButtonItem2];
        } else {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem1;
        }
    } else {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem2;
        }
    }
}

- (void)clickRightNaviItem1:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn1"]) {
        WVJBResponseCallback callback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn1"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"rightBtn1Action"};
        callback(dic);
    }
}

- (void)clickRightNaviItem2:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn2"]) {
        WVJBResponseCallback callback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn2"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"rightBtn2Action"};
        callback(dic);
    }
}

/**
 隐藏导航栏右上角按钮的方法
 
 @param index 位置索引，1在右，2在左
 */
- (void)hideRightNaviItemAtIndex:(NSInteger)index {
    if (index == 1) {
        self.rightBarButtonItem1 = nil;
    } else {
        self.rightBarButtonItem2 = nil;
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = @[];
    
    if (self.rightBarButtonItem1) {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItems = @[self.rightBarButtonItem1, self.rightBarButtonItem2];
        } else {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem1;
        }
    } else {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem2;
        }
    }
}

//设置导航栏左侧按钮
- (void)setLeftNaviItemWithTitle:(NSString *)title OrImageUrl:(NSString *)imageUrl AndIsShowBackArrow:(NSInteger)isShowArrow {
    if (title) {
        self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftNaviItem:)];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        if (imageData) {
            self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:imageData] style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftNaviItem:)];
        } else {
            self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftNaviItem:)];
        }
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[];
    if (self.backBarButton) {
        if (self.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItems = @[self.backBarButton, self.leftBarButtonItem];
        } else {
            self.navigationItem.leftBarButtonItem = self.backBarButton;
        }
    } else {
        if (self.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
        }
    }
}

- (void)clickLeftNaviItem:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setLeftBtn"]) {
        WVJBResponseCallback callback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setLeftBtn"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"leftBtnAction"};
        callback(dic);
    }
}

//隐藏导航栏左上角自定义按钮的方法
- (void)hideLeftNaviItem {
    self.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[];
    
    if (self.backBarButton) {
        if (self.closeButtonItem) {
            self.navigationItem.leftBarButtonItems = @[self.backBarButton, self.closeButtonItem];
        } else {
            self.navigationItem.leftBarButtonItem = self.backBarButton;
        }
    } else {
        if (self.closeButtonItem) {
            self.navigationItem.leftBarButtonItem = self.closeButtonItem;
        }
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"web message", message.body);
    if ([message.name isEqualToString:@"sendVRCard"]) {
    //这个是传过来的参数
        NSLog(@"%@",message.body);
// // 回调JS方法
//    [_wkWebView evaluateJavaScript:@"nativeCallbackJscMothod('123')" completionHandler:^(id _Nullable x, NSError * _Nullable error) {
////        NSLog(@"x = %@, error = %@", x, error.localizedDescription);
//    }];
        }
    
    if ([message.name isEqualToString:@"getUserInfo"]) {
        //这个是传过来的参数
        NSLog(@"%@",message.body);
        
        if ([message.body isKindOfClass:[NSString class]]) {
            [self sendUserInfoToWeb];
        }
    }
    
    if ([message.name isEqualToString:@"call"]) {
        //这个是传过来的参数
        NSLog(@"%@",message.body);
        
        NSMutableDictionary *callDict = [[NSMutableDictionary alloc] initWithCapacity:6];
        [callDict setValue:@"app-call" forKey: @"type"];
        [callDict setValue:self.uid forKey: @"roomid"];
        [callDict setValue:self.modleUrl forKey:@"houseurl"];
        [callDict setValue:self.modelId forKey:@"houseid"];
        [callDict setValue:self.uid forKey:@"channelName"];
        
        [callDict setValue:self.bussinessHeadImage forKey:@"bussinessHeadImage"];
        [callDict setValue:self.bussinessIdentity forKey:@"bussinessIdentity"];
        [callDict setValue:self.bussinessNickname forKey:@"bussinessNickname"];
        [callDict setValue:self.bussinessUid forKey:@"bussinessUid"];
        [callDict setValue:self.bussinessAccid forKey:@"bussinessAccid"];
        
        [callDict setValue:self.customerHeadImage forKey:@"customerHeadImage"];
        [callDict setValue:self.customerIdentity forKey:@"customerIdentity"];
        [callDict setValue:self.customerNickname forKey:@"customerNickName"];
        [callDict setValue:self.customerUid forKey:@"customerUid"];
        [callDict setValue:self.customerAccid forKey:@"customerAccid"];
    
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callDict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self sendPeerMessage:msg toPeerId:self.peerID];
    }
    
    if ([message.name isEqualToString:@"hangup"]) {
        //这个是传过来的参数
        NSLog(@"hangup %@",message.body);
        
        [self leavelAudioChannel];
        
        [self onChatUpdate: @"7"];
        
        NSMutableDictionary *hangUpDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [hangUpDict setValue:@"mini-hangup" forKey:@"type"];
        [hangUpDict setValue:@(8) forKey:@"hangupType"];
        
        NSString *hangUpMsg = [self dictToStr:hangUpDict];
        [self sendPeerMessage:hangUpMsg toPeerId: self.peerID];
    }
    
    if ([message.name isEqualToString:@"refuse"]) {
        // 拒绝
        NSLog(@"%@",message.body);
        
        if ([message.body isKindOfClass:[NSString class]]) {
            NSDictionary *resultDict = [self parseJSON:message.body];
            
            NSString *peerId = [resultDict valueForKey:@"peerId"];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
            
            [dict setValue:@"refuse" forKey:@"type"];
            [dict setValue:@(5) forKey:@"status"];
            NSString *refuseMsg = [self dictToStr:dict];
            if (!peerId) {
                peerId = self.peerID;
            }
            [self sendPeerMessage:refuseMsg toPeerId:peerId];
        }
    }
    
    if ([message.name isEqualToString:@"accept"]) {
        // 接受消息
        NSLog(@"accept --- %@",message.body);
        
        [self onChatUpdate:@"3"];
        [self isAccept];
    }
    
    if ([message.name isEqualToString:@"getLog"]) {
        //这个是传过来的参数
        NSLog(@"getLog %@",message.body);
    }
    
    if ([message.name isEqualToString:@"mute"]) {
        //这个是传过来的参数
        NSLog(@"%@",message.body);
        [self.agoraKit muteLocalAudioStream:true];
    }
    
    if ([message.name isEqualToString:@"unmute"]) {
        //这个是传过来的参数
        NSLog(@"%@",message.body);
        
        [self.agoraKit muteLocalAudioStream:false];
    }
    
    // 初始化
    if ([message.name isEqualToString:@"initMessageAction"]) {
        NSLog(@"initMessageAction === %@",message.body);
        if ([message.body isKindOfClass:[NSString class]]) {
            NSDictionary *resultDict = [self parseJSON: message.body];
            // userId 是必传的
            self.uid = [resultDict objectForKey:@"userId"];
            if ([resultDict objectForKey:@"token"]) {
                self.token = [resultDict objectForKey:@"token"];
            }
            [self initializeAgoraEngine];
            [self getMessageToken:self.uid];
        }
    }
    
    if ([message.name isEqualToString:@"login"]) {
        NSLog(@"%@", message.body);
    }
    
    if ([message.name isEqualToString:@"jumpToWebView"]) {
        NSLog(@"%@", message.body);
        
        if ([message.body isKindOfClass:[NSString class]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:message.body] options:[[NSDictionary alloc] init] completionHandler:^(BOOL success) {
                            
            }];
        }
        
    }
    
    if ([message.name isEqualToString:@"sendData"]) {
        
        if ([message.body isKindOfClass:[NSString class]]) {
            
        }
        [self sendPeerMessage:message.body toPeerId:self.peerID];
    }
    
    if ([message.name isEqualToString:@"logout"]) {
        [self.kit logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
            switch (errorCode) {
                case AgoraRtmLogoutErrorOk:
                    [self updateUserStatus:self.uid withStatus:100];
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self.agoraKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
                    
        }];
    }
    
    if ([message.name isEqualToString:@"isRealOnline"]) {
        NSDictionary *resultDict = [self parseJSON:message.body];
        
        if ([resultDict valueForKey:@"bussinessUid"]) {
            NSString *buid = [resultDict valueForKey:@"bussinessUid"];
            
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:buid];
            
            [self.kit queryPeersOnlineStatus:array completion:^(NSArray<AgoraRtmPeerOnlineStatus *> *peerOnlineStatus, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
                for (AgoraRtmPeerOnlineStatus *peer in peerOnlineStatus) {
                    if (peer.isOnline) {
                        [self isInChannel: buid];
                    } else {
                        [self updateUserStatus:peer.peerId withStatus:100];
                    }
                }
            }];
        }
    }
    
    if ([message.name isEqualToString:@"sendUserInfo"]) {
        if ([message.body isKindOfClass:[NSString class]]) {
            NSDictionary *resultDict = [self parseJSON: message.body];
            
            if ([resultDict valueForKey:@"type"]) {
                self.businessType = [resultDict valueForKey:@"type"];
            }
            
            
            if ([resultDict valueForKey:@"bussiness"]) {
                NSDictionary *buisiness = [resultDict valueForKey:@"bussiness"];
                
                if ([buisiness valueForKey:@"bussinessHeadImage"]) {
                    self.bussinessHeadImage = [buisiness valueForKey:@"bussinessHeadImage"];
                }
                if ([buisiness valueForKey:@"bussinessIdentity"]) {
                    self.bussinessIdentity = [buisiness valueForKey:@"bussinessIdentity"];
                }
                if ([buisiness valueForKey:@"bussinessNickName"]) {
                    self.bussinessNickname = [buisiness valueForKey:@"bussinessNickName"];
                }
                if ([buisiness valueForKey:@"bussinessUid"]) {
                    self.bussinessUid = [buisiness valueForKey:@"bussinessUid"];
                }
                if ([buisiness valueForKey:@"bussinessAccid"]) {
                    self.bussinessAccid = [buisiness valueForKey:@"bussinessAccid"];
                }
                
                if ([self.businessType isEqualToString:@"bussiness"]) {
                    if (self.bussinessUid) {
                        self.uid = self.bussinessUid;
                    }
                } else {
                    if (self.bussinessUid) {
                        self.peerID = self.bussinessUid;
                    }
                }
            }
            
            if ([resultDict valueForKey:@"modleUrl"]) {
                self.modleUrl = [resultDict valueForKey:@"modleUrl"];
                NSLog(@"url %@", self.modleUrl);
            }
            
            if ([resultDict valueForKey:@"customer"]) {
                NSDictionary *customer = [resultDict valueForKey:@"customer"];
                
                if ([customer valueForKey:@"customerHeadImage"]) {
                    
                    NSString *customerHeadImage = [customer valueForKey:@"customerHeadImage"];
                    if (![customerHeadImage isEqualToString:@""]) {
                        self.customerHeadImage = [customer valueForKey:@"customerHeadImage"];
                    }
                    
                }
                
                if ([customer valueForKey:@"customerIdentity"]) {
                    self.customerIdentity = [customer valueForKey:@"customerIdentity"];
                }
                
                if (![[customer valueForKey:@"customerUid"] isEqual:@"0"]) {
                    self.customerUid = [customer valueForKey:@"customerUid"];
                }
                
                if ([customer valueForKey:@"customerAccid"]) {
                    if (![[customer valueForKey:@"customerAccid"] isEqualToString:@""]) {
                        self.customerAccid = [customer valueForKey:@"customerAccid"];
                    }
                }
                
                if (![self.businessType isEqualToString:@"bussiness"]) {
                    if (self.customerUid) {
                        self.uid = self.customerUid;
                    }
                } else {
                    if (self.customerUid) {
                        self.peerID = self.customerUid;
                    }
                }
                if ([customer valueForKey:@"customerNickName"]) {
                    if (![[customer valueForKey:@"customerNickName"] isEqualToString:@""]) {
                        self.customerNickname = [customer valueForKey:@"customerNickName"];
                    }
                    
                }
            }
        }
    }
}

-(void)sendUserInfoToWeb {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:6];
    
    NSMutableDictionary *customer = [[NSMutableDictionary alloc] initWithCapacity:6];
    [customer setValue:self.customerHeadImage forKey:@"customerHeadImage"];
    [customer setValue:self.customerIdentity forKey:@"customerIdentity"];
    [customer setValue:self.customerNickname forKey:@"customerNickName"];
    [customer setValue:self.customerUid forKey:@"customerUid"];
    [customer setValue:self.customerAccid forKey:@"customerAccid"];
    
    NSMutableDictionary *business = [[NSMutableDictionary alloc] initWithCapacity:6];
    [business setValue:self.bussinessHeadImage forKey:@"bussinessHeadImage"];
    [business setValue:self.bussinessIdentity forKey:@"bussinessIdentity"];
    [business setValue:self.bussinessNickname forKey:@"bussinessNickName"];
    [business setValue:self.bussinessUid forKey:@"bussinessUid"];
    [business setValue:self.bussinessAccid forKey:@"bussinessAccid"];
    
    [userInfo setValue:customer forKey:@"customer"];
    if ([self.businessType isEqualToString:@"bussiness"]) {
        [userInfo setValue:self.bussinessIdentity forKey:@"currentIdentity"];
    } else {
        [userInfo setValue:self.customerIdentity forKey:@"currentIdentity"];
    }
    [userInfo setValue:business forKey:@"bussiness"];
    
    [self resUserInfo: [self dictToStr:userInfo]];
}

- (void)isAccept {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    [dict setValue:@"accept" forKey:@"type"];
    [dict setValue:self.bussinessUid forKey:@"bussinessUid"];
    [dict setValue:self.customerUid forKey:@"customerUid"];
    NSString *acceptMsg = [self dictToStr:dict];
    [self sendPeerMessage:acceptMsg toPeerId:self.peerID];
}

#pragma mark --- MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- QHJSAuthApi

//注册自定义API的方法
- (BOOL)registerHandlersWithClassName:(NSString *)className moduleName:(NSString *)moduleName {
    return [self.bridge registerHandlersWithClassName:className moduleName:moduleName];
}

- (void)dealloc {
    [self.wv.configuration.userContentController removeScriptMessageHandlerForName:@"WKWebViewJavascriptBridge"];
    [self.wv.configuration.userContentController removeAllUserScripts];
    [self.wv removeObserver:self forKeyPath:@"title" context:&KVOContext];
    [self.wv removeObserver:self forKeyPath:@"estimatedProgress" context:&KVOContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"<QHJSBaseWebLoader>dealloc");
}

- (NSDictionary *)parseJSON: (NSString *)str {
    NSData* jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [jsonData objectFromJSONData];
    return resultDict;
}

- (void)onData:(NSString *)str {
    NSString *string = [self noWhiteSpaceString:str];
    NSString *script = [NSString stringWithFormat:@"onData('%@')", string];
    NSLog(@"onData %@", script);
    [self.wv evaluateJavaScript:script completionHandler:^(id _Nullable x, NSError * _Nullable error) {
        
    }];
}

- (void)onChatUpdate:(NSString *)str {
    NSString *script = [NSString stringWithFormat:@"updateChatStatus('%@')", str];
    
    [self.wv evaluateJavaScript:script completionHandler:^(id _Nullable x, NSError * _Nullable error) {
        
    }];
}

- (void)resUserInfo:(NSString *)str {
    NSString *string = [self noWhiteSpaceString:str];
//    NSString *script = [NSString stringWithFormat:@"getUserInfo('%@')", string];
    
    NSString *script = [NSString stringWithFormat:@"onReceiveUserInfo('%@')", string];
    [self.wv evaluateJavaScript:script completionHandler:^(id _Nullable x, NSError * _Nullable error) {
        
    }];
    
//    [self.wv evaluateJavaScript:script completionHandler:^(id _Nullable x, NSError * _Nullable error) {
//        NSLog(@"error %@", error);
//    }];
}

- (NSString *)noWhiteSpaceString:(NSString *)str {
    NSString *newString = str;
  //去除掉首尾的空白字符和换行字符
    newString = [newString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符使用
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    可以去掉空格，注意此时生成的strUrl是autorelease属性的，所以不必对strUrl进行release操作！
    return newString;
}

- (NSString *)dictToStr: (NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return msg;
}

- (void)joinChannelWithId: (NSString *)fromId andChanneName:(NSString *)channelName {
    NSString *chName = [NSString stringWithFormat:@"channel%@", channelName];
    NSString *urlString = @"https://gallery.creativ-space.com/apis/vragora/token";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:chName forKey:@"channelName"];
    [dict setValue:fromId forKey:@"uid"];
    [dict setValue:@(1) forKey:@"role"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        if ([code isEqual: @"200"]) {
            
            NSString *data = [dict valueForKey:@"data"];
            // TODO 加入频道的代码
            [self joinChannelWithUid:fromId channelName:chName token:data];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)joinChannelWithUid: (NSString *)userId channelName:(NSString *)channelName token:(NSString *)token {
    NSInteger uIdIn = [userId integerValue];
    [self updateUserStatus:userId withStatus:102];
    [self.agoraKit joinChannelByToken:token channelId:channelName info:@"" uid:uIdIn joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"%@ join === %@ === Success", userId, channel);
    }];

}

- (void)requestToken {
    NSString *urlString = @"https://gallery.creativ-space.com/apis/vragora/token";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:self.videoChannelName forKey:@"channelName"];
    [dict setValue:self.uid forKey:@"uid"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        if ([code isEqual: @"200"]) {
            
            NSString *data = [dict valueForKey:@"data"];
            
            self.agoraAudioToken = data;
            
//            [self joinChannelWithUid:self.uid channelName:s token:data];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)getMessageToken: (NSString *)userId {
    NSString *urlString = @"https://console.mspaco.com.sg/prod-api/mall-daogou/vragora/rtm-token";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:self.uid forKey:@"userId"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    
    [manager POST:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        if ([code isEqual: @"200"]) {
            
            NSString *data = [dict valueForKey:@"data"];
            
            // rtm token
            self.token = data;
            
            [self loginWithUserId:userId andToken:self.token];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get token error");
    }];
}

- (void)updateUserStatus: (NSString *)userId withStatus:(int)status {
    NSLog(@"update user %@ login status %d",userId, status);
    NSString *urlString = @"https://console.mspaco.com.sg/prod-api/mall-daogou/customer_status/status";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:userId forKey:@"uid"];
    [dict setValue:@(status) forKey:@"status"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        if ([code isEqual: @"200"]) {
            NSLog(@"user %@ login success", userId);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"test");
    }];
}

- (void)isInChannel:(NSString *)bUid {
    NSString *urlString = [NSString stringWithFormat:@"https://api.agora.io/dev/v1/channel/user/property/%@/%@/channel%@", self.agoraAudioAppId, bUid, bUid];
    NSDictionary *dict = [NSDictionary dictionary];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        
        if ([code isEqual: @"200"]) {
            NSDictionary *dataBoj = dict[@"data"];
            Boolean inChannel = [[dataBoj valueForKey:@"in_channel"] boolValue];
            
            if (inChannel) {
                [self updateUserStatus:bUid withStatus:102];
            } else {
                [self updateUserStatus:bUid withStatus:101];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)requestBaseUrl {
    NSString *urlString = @"https://console.mspaco.com.sg/prod-api/mate-system/dict/list-value?code=appconf";
    
    NSDictionary *dict = [NSDictionary dictionary];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        
        if ([code isEqual: @"200"]) {
            NSArray *resArray = dict[@"data"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            for (NSDictionary *obj in resArray) {
                if ([[obj valueForKey:@"dictKey"] isEqualToString:@"pic"]) {
                    NSString *guideUrl = [obj valueForKey:@"dictValue"];
                    [defaults setObject: guideUrl forKey:@"guideImage"];
                    [defaults synchronize];//立即保存
                } else if ([[obj valueForKey:@"dictKey"] isEqualToString:@"home"]) {
                    NSString *jumpUrl = [obj valueForKey:@"dictValue"];
                    [defaults setObject: jumpUrl forKey:@"home"];
                    [defaults synchronize];//立即保存
                    [self loadHtml:jumpUrl];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (UIImageView *)splashImageView {
    if (!_splashImageView) {
        _splashImageView = [[UIImageView alloc] init];
        [_splashImageView setFrame:self.view.frame];
        NSUserDefaults *de = [NSUserDefaults standardUserDefaults];
        NSString *urlStr = [de objectForKey:@"guideImage"];
        UIImage *spImage = [UIImage imageNamed:@"launch"];
        _splashImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (urlStr) {
            [_splashImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:spImage];
        } else {
            [_splashImageView setImage:spImage];
        }
    }
    
    return _splashImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"5s" forState:UIControlStateNormal];
        [_closeButton setFrame:CGRectMake(290, 50, 90, 32)];
        [_closeButton setTitleColor:[UIColor colorWithRed:231 green:230 blue:230 alpha:1] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(delayJump) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

@end
