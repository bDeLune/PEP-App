#import <Foundation/Foundation.h>
#import "User.h"
#import "Game.h"
#import "Session.h"
@interface AddNewScoreOperation : NSOperation
- (id)initWithData:(User *)user  session:(Session*)session sharedPSC:(NSPersistentStoreCoordinator *)psc;
@end
