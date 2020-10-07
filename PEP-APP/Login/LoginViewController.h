#import <UIKit/UIKit.h>
#import "User.h"
#import "UserListViewController.h"

@class LoginViewController;

@protocol LoginProtocol <NSObject>
-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user;
@end

@interface LoginViewController : UIViewController
-(IBAction)login:(id)sender;
-(IBAction)signup:(id)sender;
@property (nonatomic,weak)IBOutlet  UITextField  *usernameTextField;
@property (nonatomic,weak)IBOutlet UIButton      *loginButton;
@property (nonatomic,weak)IBOutlet UIButton      *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *loginBackground;
@property (strong) NSPersistentStoreCoordinator  *sharedPSC;
@property (nonatomic,unsafe_unretained)id<LoginProtocol>delegate;
@property (nonatomic,strong)UserListViewController *userList;
@end
