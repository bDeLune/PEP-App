#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
extern NSString *kAddNewUserOperationUserExistsError;
extern NSString *kAddNewUserOperationUserAdded;
extern NSString *kAddNewUserOperationUserError;
@interface AddNewUserOperation : NSOperation
- (id)initWithData:(NSString *)username sharedPSC:(NSPersistentStoreCoordinator *)psc;
@end
