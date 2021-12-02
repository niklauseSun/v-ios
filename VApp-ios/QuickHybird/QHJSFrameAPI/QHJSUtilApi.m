//
//  QHJSUtilApi.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/30.
//

#import "QHJSUtilApi.h"
#import "WCQRCodeVC.h"
#import <SGQRCode/SGAuthorization.h>
#import "TZImagePickerController.h"
#import "FileUtil.h"

@interface QHJSUtilApi()<TZImagePickerControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) WVJBResponseCallback callback;
@property (nonatomic, strong) TZImagePickerController *imagePick;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, weak) UIImagePickerController *imagePickerVc;

@end


@implementation QHJSUtilApi

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
    //弹框提示
    [self registerHandlerName:@"scan" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        SGAuthorization *authorization = [[SGAuthorization alloc] init];
        authorization.openLog = YES;
        
        [authorization AVAuthorizationBlock:^(SGAuthorization * _Nonnull authorization, SGAuthorizationStatus status) {
            if (status == SGAuthorizationStatusSuccess) {
                WCQRCodeVC *WBVC = [[WCQRCodeVC alloc] init];
                
                [weakSelf.webloader.navigationController pushViewController:WBVC animated:YES];
                [WBVC returnQcResult:^(NSString * _Nonnull resultData) {
                    
                    if ([resultData isKindOfClass:[NSString class]]) {
                        NSDictionary *resultDic = @{@"resultData" : resultData};
                        NSDictionary *backDic = @{@"result" : resultDic, @"code" : @1, @"msg" : @""};
                        responseCallback(backDic);
                    }
                }];
            } else if (status == SGAuthorizationStatusFail) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 -  打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                           }];
        
                [alertC addAction:alertA];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.webloader presentViewController:alertC animated:YES completion:nil];
                });
            } else {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
                           }];
        
                [alertC addAction:alertA];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.webloader presentViewController:alertC animated:YES completion:nil];
                });
            }
        }];

    }];
    
    
    [self registerHandlerName:@"selectFile" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 选择文件
    }];
    
    [self registerHandlerName:@"selectImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 选择图片
        self.callback = responseCallback;
        self.imagePick = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        [self.imagePick setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            responseCallback(photos);
        }];
        [weakSelf.webloader.navigationController pushViewController:self.imagePick animated:YES];
    }];
    
    [self registerHandlerName:@"cameraImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 拍照
        __weak typeof(self) weakSelf = self;
        [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.location = [locations firstObject];
        } failureBlock:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.location = nil;
        }];
        
        self.imagePickerVc = [[UIImagePickerController alloc] init];
        self.imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        self.imagePickerVc.navigationBar.barTintColor = self.webloader.navigationController.navigationBar.barTintColor;
        self.imagePickerVc.navigationBar.tintColor = self.webloader.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        }
//        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                self.imagePickerVc.sourceType = sourceType;
                [weakSelf.webloader.navigationController pushViewController:self.imagePickerVc animated:YES];
//                [weakSelf.webloader presentViewController:self.imagePickerVc animated:YES completion:nil];
            } else {
                NSLog(@"模拟器中无法打开照相机,请在真机中使用");
            }
    }];
    
    [self registerHandlerName:@"openFolder" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 打开指定文件夹
        
    }];
    
    [self registerHandlerName:@"copyFileToLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 保存文件到指定路径
        NSString *oldPath = data[@"oldpath"];
        NSString *desPath = data[@"despath"];
        
        [FileUtil copyItemAtPath:oldPath toPath:desPath];
        
        NSDictionary *resultDic = @{@"resultData" : @{}};
        NSDictionary *backDic = @{@"result" : resultDic, @"code" : @1, @"msg" : @""};
        responseCallback(backDic);
    }];
    
    [self registerHandlerName:@"createFolder" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 新建文件夹
        NSString *path = data[@"path"];
        
        if (path) {
            [FileUtil createDirectory:path];
            NSDictionary *resultDic = @{@"resultData" : @{}};
            NSDictionary *backDic = @{@"result" : resultDic, @"code" : @1, @"msg" : @""};
            responseCallback(backDic);
        }
        
        NSDictionary *resultDic = @{@"resultData" : @{}};
        NSDictionary *backDic = @{@"result" : resultDic, @"code" : @0, @"msg" : @""};
        responseCallback(backDic);
        
    }];
    
    [self registerHandlerName:@"saveFilePaths" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 保存数据到本地
    }];
    
    [self registerHandlerName:@"getFileList" handler:^(id data, WVJBResponseCallback responseCallback) {
       // 获取保存在本地的文件列表
    }];
    
    [self registerHandlerName:@"getMd5List" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *filePath = data[@"filePath"];
        
        NSString *mainMd = [FileUtil getMd5HashOfString:filePath];
        
        NSArray *mdList = [FileUtil splitFileToPart:filePath];
        
        NSString *firstPart = [FileUtil getMd5HashOfString:mdList[0]];
        
        NSString *lastPart = [FileUtil getMd5HashOfString:mdList[mdList.count - 1]];
        
        NSMutableDictionary *resultData = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        [resultData setValue:@"success" forKey:@"type"];
        [resultData setValue:mainMd forKey:@"totalMd5"];
        [resultData setValue:firstPart forKey:@"firstMd5"];
        [resultData setValue:lastPart forKey:@"lastMd5"];
        [resultData setValue:mdList forKey:@"fileList"];
        
        NSDictionary *backDic = @{@"result" : resultData, @"code" : @1, @"msg" : @""};
        responseCallback(backDic);
    }];
    
    [self registerHandlerName:@"uploadImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
    
    [self registerHandlerName:@"uploadMd5Part" handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
}

@end
