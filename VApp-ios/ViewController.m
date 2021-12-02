//
//  ViewController.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/9.
//

#import "ViewController.h"
#import "QHJSBaseWebLoader.h"
#import "QCScan/WCQRCodeVC.h"
#import <SGQRCode/SGAuthorization.h>
#import "AFNetworking.h"

@interface ViewController () 

@property (nonatomic, strong) UIButton *messageTestButton;

@property (nonatomic, strong) UIButton *callTestButton;

@property (nonatomic, strong) UITextField  *urlAddress;

@property (nonatomic, strong) UIButton *jumpToTest;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [self setStatusBarBackgroundColor:[UIColor redColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    [self initViews];
    
    NSString *path = [self getJumpUrl];
    
    [self.urlAddress setText:path];
    
//    [self jumpToUrl:@"http://10.12.254.148:8080/"];
    [self requestBaseUrl];
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - action

- (void) initViews {
//    [self.view addSubview:self.messageTestButton];
//    [self.view addSubview:self.callTestButton];
    [self.view addSubview:self.urlAddress];
    [self.view addSubview:self.jumpToTest];
    [self.view addSubview:self.messageTestButton];
}

- (void)normalJump {
    
}

#pragma mark - action

- (void)jumpToWebView {
//    / QHJSBaseWebLoader *vc = [[QHJSBaseWebLoader alloc] init];
    NSString *url = self.urlAddress.text;
    if ([self isUrl:url]) {
        [self saveJumpUrl:url];
        QHJSBaseWebLoader *vc = [[QHJSBaseWebLoader alloc] init];
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setObject:url forKey:@"pageUrl"];
        vc.params = paramDic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)jumpToUrl:(NSString *)url {
    if ([self isUrl:url]) {
        [self saveJumpUrl:url];
        QHJSBaseWebLoader *vc = [[QHJSBaseWebLoader alloc] init];
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setObject:url forKey:@"pageUrl"];
        vc.params = paramDic;
        
        UINavigationController *root = [[UINavigationController alloc] initWithRootViewController:vc];
        [root setNavigationBarHidden:YES animated:YES];
        
        [[UIApplication sharedApplication].keyWindow setRootViewController:root];
        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
        
//        [self.navigationController pushViewController:vc animated:YES];
        
//        [self.navigationController setViewControllers:@[vc] animated:YES];
    }
}

- (void)testAction {
    SGAuthorization *authorization = [[SGAuthorization alloc] init];
    authorization.openLog = YES;
    
    [authorization AVAuthorizationBlock:^(SGAuthorization * _Nonnull authorization, SGAuthorizationStatus status) {
        if (status == SGAuthorizationStatusSuccess) {
            WCQRCodeVC *WBVC = [[WCQRCodeVC alloc] init];
            [self.navigationController pushViewController:WBVC animated:YES];
        } else if (status == SGAuthorizationStatusFail) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                       }];
                       
            [alertC addAction:alertA];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertC animated:YES completion:nil];
            });
        } else {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                           
                       }];
                       
            [alertC addAction:alertA];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertC animated:YES completion:nil];
            });
        }
    }];
    
}

- (BOOL)isUrl:(NSString *)url {
    
    if(self == nil) {
        return NO;
    }
    NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
}

- (void)saveJumpUrl:(NSString *)path {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:path forKey:@"jumpUrl"];
    [defaults synchronize];
}

- (NSString *)getJumpUrl {
    // 1. 创建NSUserDefaults单例:
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *url = [defaults stringForKey:@"jumpUrl"];
    return url;
}

#pragma mark - init

- (UITextField *)urlAddress {
    if (!_urlAddress) {
        _urlAddress = [[UITextField alloc] init];
        [_urlAddress setFrame:CGRectMake(20, 100, 240, 40)];
        [_urlAddress setBorderStyle:UITextBorderStyleLine];
    }
    return _urlAddress;
}

- (UIButton *)jumpToTest {
    if (!_jumpToTest) {
        _jumpToTest = [UIButton buttonWithType:UIButtonTypeCustom];
        [_jumpToTest setTitle:@"跳转到网页" forState:UIControlStateNormal];
        [_jumpToTest setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_jumpToTest setFrame:CGRectMake(20, 150, 120, 40)];
        [_jumpToTest addTarget:self action:@selector(jumpToWebView) forControlEvents: UIControlEventTouchUpInside];
    }
    
    return _jumpToTest;
}

- (UIButton *)messageTestButton {
    if (!_messageTestButton) {
        _messageTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageTestButton setTitle:@"测试功能" forState:UIControlStateNormal];
        [_messageTestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_messageTestButton setFrame:CGRectMake(20, 200, 80, 40)];
        [_messageTestButton addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _messageTestButton;
}

- (UIButton *)callTestButton {
    if (!_callTestButton) {
        [_callTestButton setTitle:@"语音通话测试" forState:UIControlStateNormal];
        [_callTestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_callTestButton setFrame:CGRectMake(20, 250, 80, 40)];
    }
    
    return _callTestButton;
}

#pragma mark - request

- (void)requestBaseUrl {
    NSString *urlString = @"https://jiance.99rongle.com/prod-api/mate-component/config/get-h5-url";
    
    NSDictionary *dict = [NSDictionary dictionary];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        
        NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
        
        if ([code isEqual: @"200"]) {
            NSString *url = dict[@"data"];
            if (url) {
                [self jumpToUrl: url];
            } else {
                [self jumpToUrl:@"https://m.mspace.com.sg/mobile/"];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

@end
