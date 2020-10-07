#import <UIKit/UIKit.h>
#import "User.h"

@interface MainTableViewController : UITableViewController
-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user withManagedObjectContext:(NSManagedObjectContext*)moc;
-(void)saveUserSettings;
@end
