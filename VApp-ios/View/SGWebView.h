//
//  SGWebView.h
//  VApp-ios
//
//  Created by 孙玉建 on 2021/10/1.
//

#import <UIKit/UIKit.h>

@class SGWebView;

@protocol SGWebViewDelegate <NSObject>

@optional
/** 页面开始加载时调用 */
- (void)webViewDidStartLoad:(SGWebView *)webView;
/** 内容开始返回时调用 */
- (void)webView:(SGWebView *)webView didCommitWithURL:(NSURL *)url;
/** 页面加载失败时调用 */
- (void)webView:(SGWebView *)webView didFinishLoadWithURL:(NSURL *)url;
/** 页面加载完成之后调用 */
- (void)webView:(SGWebView *)webView didFailLoadWithError:(NSError *)error;


@end
NS_ASSUME_NONNULL_BEGIN

@interface SGWebView : UIView

/** SGDelegate */
@property (nonatomic, weak) id<SGWebViewDelegate> SGQRCodeDelegate;
/** 进度条颜色(默认蓝色) */
@property (nonatomic, strong) UIColor *progressViewColor;
/** 导航栏标题 */
@property (nonatomic, copy) NSString *navigationItemTitle;
/** 导航栏存在且有穿透效果(默认导航栏存在且有穿透效果) */
@property (nonatomic, assign) BOOL isNavigationBarOrTranslucent;

/** 类方法创建 SGWebView */
+ (instancetype)webViewWithFrame:(CGRect)frame;
/** 加载 web */
- (void)loadRequest:(NSURLRequest *)request;
/** 加载 HTML */
- (void)loadHTMLString:(NSString *)HTMLString;
/** 刷新数据 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
