//
//  CallTestViewController.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/23.
//

#import "CallTestViewController.h"

@interface CallTestViewController () 

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *callButton;

@end

@implementation CallTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
}

- (void)initViews {
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.callButton];
}


#pragma mark init

- (UIButton *)closeButton {
    if (!_closeButton) {
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton setFrame:CGRectMake(20, 150, 80, 40)];
    }
    
    return _closeButton;
}

- (UIButton *)callButton {
    if (!_callButton) {
        [_callButton setTitle:@"拨打" forState:UIControlStateNormal];
        [_callButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_callButton setFrame:CGRectMake(20, 200, 80, 40)];
    }
    
    return _callButton;
}


@end
