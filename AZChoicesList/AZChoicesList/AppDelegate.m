//
//  AppDelegate.m
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
    [_window makeKeyAndVisible];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (@available(iOS 11.0, *)) {
        NSLog(@"home path === %@,%f,%f",NSHomeDirectory(),_window.safeAreaInsets.bottom,_window.safeAreaInsets.top);
        [userDefaults setFloat:_window.safeAreaInsets.bottom forKey:@"SCREEN_SAFE_AREA_BOTTOM"];
    } else {
        // Fallback on earlier versions
        [userDefaults setFloat:0.0 forKey:@"SCREEN_SAFE_AREA_BOTTOM"];
    }
    [userDefaults synchronize];
    return YES;
}











@end
