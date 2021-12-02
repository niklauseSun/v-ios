//
//  ScanSuccessJumpVC.h
//  VApp-ios
//
//  Created by 孙玉建 on 2021/10/1.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScanSuccessJumpComeFromWB,
    ScanSuccessJumpComeFromWC
} ScanSuccessJumpComeFrom;

NS_ASSUME_NONNULL_BEGIN

@interface ScanSuccessJumpVC : UIViewController

/** 判断从哪个控制器 push 过来 */
@property (nonatomic, assign) ScanSuccessJumpComeFrom comeFromVC;
/** 接收扫描的二维码信息 */
@property (nonatomic, copy) NSString *jump_URL;
/** 接收扫描的条形码信息 */
@property (nonatomic, copy) NSString *jump_bar_code;

@end

NS_ASSUME_NONNULL_END
