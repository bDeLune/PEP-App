#import <UIKit/UIKit.h>

@class UserListViewController;
@protocol UserListProtoCol <NSObject>
-(void)userListDismissRequest:(UserListViewController*)caller;
@end
@interface UserListViewController : UIViewController<UIAlertViewDelegate >{
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColouredImage;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,unsafe_unretained)id<UserListProtoCol>delegate;
-(void)getListOfUsers;
@end
