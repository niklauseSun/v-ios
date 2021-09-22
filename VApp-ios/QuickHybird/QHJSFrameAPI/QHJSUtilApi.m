//
//  QHJSUtilApi.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/30.
//

#import "QHJSUtilApi.h"

@implementation QHJSUtilApi

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
    //弹框提示
    [self registerHandlerName:@"scan" handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
}

@end
