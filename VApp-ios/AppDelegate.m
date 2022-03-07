//
//  AppDelegate.m
//  VApp-ios
//
//  Created by 孙玉建 on 2021/7/9.
//

#import "AppDelegate.h"
#import "QHJSBaseWebLoader.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
       
    QHJSBaseWebLoader *rootVc = [[QHJSBaseWebLoader alloc]init];
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:rootVc];
    [rootNav setNavigationBarHidden:YES];
    [self.window setRootViewController:rootNav];
    [self.window makeKeyAndVisible];
    
    return YES;
}




@end
