#import "GCDQueue.h"
#import "AppDelegate.h"
#import "AddNewScoreOperation.h"
#import "SettingsViewController.h"
#import "GameViewController.h"

@interface AppDelegate()
{
    UIImageView  *startupImageView;
    NSTimer      *startupTimer;
}

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    NSLog(@"APP FINISHED LAUNCHING with language: %@", language);
    [self showSplash];
    
    self.mainTableViewController = (UITabBarController *)self.window.rootViewController.childViewControllers.lastObject;
    
//    CGRect tabFrame = self.mainTableViewController.view.frame;
//    tabFrame.size.height = 230;
//    tabFrame.origin.y = self.mainTableViewController.view.frame.size.height - 410;
//    self.mainTableViewController.view.frame = tabFrame;
    
    return YES;
}

- (void)viewWillLayoutSubviews {
//    []
//    CGRect tabFrame = self.mainTableViewController.view.frame;
//    tabFrame.size.height = 130;
//    tabFrame.origin.y = self.mainTableViewController.view.frame.size.height - 210;
//    self.mainTableViewController.view.frame = tabFrame;
//    [self.mainTableViewController.tabBarController setItemPositioning:UITabBarItemPositioningFill];
}

- (void)showSplash
{
    self.initialSplash = [[SplashViewController alloc]initWithNibName:@"SplashViewController" bundle:nil];
    self.initialSplash.view.frame = self.window.frame;
    
    [self.window addSubview:self.initialSplash.view];
    [self.window bringSubviewToFront:self.initialSplash.view];
    
    [NSTimer scheduledTimerWithTimeInterval:4.0
                                     target:self
                                   selector:@selector(removeSplash:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)removeSplash:(NSTimer *)timer{
    [timer invalidate];
    NSLog(@"Removing splash");
    [self.initialSplash.view removeFromSuperview];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.mainTableViewController saveUserSettings];
}


- (void)setRootTablViewController: (MainTableViewController*)mtvc{
    self.mainTableViewController = mtvc;
}


@end
