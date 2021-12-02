//
//  WCQRCodeVC.h
//  VApp-ios
//
//  Created by 孙玉建 on 2021/10/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QcResult)(NSString *resultData);


@interface WCQRCodeVC : UIViewController

@property (nonatomic, copy) QcResult qcResult;

- (void)returnQcResult:(QcResult)block;

@end

NS_ASSUME_NONNULL_END
