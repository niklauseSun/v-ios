//
//  ViewController.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/9.
//

#import "ViewController.h"
#import "QHJSBaseWebLoader.h"
#import "SGQRCode.h"

@interface ViewController () 

@property (nonatomic, strong) UIButton *messageTestButton;

@property (nonatomic, strong) UIButton *callTestButton;

@property (nonatomic, strong) UITextField  *urlAddress;

@property (nonatomic, strong) UIButton *jumpToTest;

@property (nonatomic, strong) SGScanCode *scanCode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    
    NSString *path = [self getJumpUrl];
    
    [self.urlAddress setText:path];
}

#pragma mark - action

- (void) initViews {
//    [self.view addSubview:self.messageTestButton];
//    [self.view addSubview:self.callTestButton];
    [self.view addSubview:self.urlAddress];
    [self.view addSubview:self.jumpToTest];
    [self.view addSubview:self.messageTestButton];
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
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)testAction {
    self.scanCode = [SGScanCode scanCode];
    
    __weak typeof(self) weakSelf = self;
        
        [self.scanCode scanWithController:self resultBlock:^(SGScanCode *scanCode, NSString *result) {
            if (result) {
                
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


@end
