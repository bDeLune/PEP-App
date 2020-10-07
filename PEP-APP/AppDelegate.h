#import <UIKit/UIKit.h>
#import "SplashViewController.h"
#import "MainTableViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTableViewController *mainTableViewController;
@property (nonatomic, strong) SplashViewController *initialSplash;
- (void)removeSplash;
- (void)setRootTablViewController: (MainTableViewController*)mtvc;
@end
