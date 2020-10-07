#import "AddNewScoreOperation.h"
@interface AddNewScoreOperation ()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)User  *user;
@property(nonatomic,strong)Session  *session;
@end
@implementation AddNewScoreOperation
- (id)initWithData:(User *)auser  session:(Session*)asession sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
        self.sharedPSC = psc;
        self.user=auser;
        self.session=asession;
    }
    return self;
    
}
- (void)main {
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    [self addTheSession];
}

-(void)addTheSession
{
     //NSLog(@"SAVING SESSION");
    Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    [game setDuration:self.session.sessionDuration];
    [game setGameDate:self.session.sessionDate];
    [game setPower:self.session.sessionStrength];
    [game setGameType:self.session.sessionType];
    [game setSpeed:self.session.sessionSpeed];
    NSString *direction=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultDirection"];
    [game setGameDirection:direction];
    
    NSString   *name=[self.user valueForKey:@"userName"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"game %@", game);
    
    if ([items count]>0) {
        User *auser=[items objectAtIndex:0];
        [[auser mutableSetValueForKey:@"game"]addObject:game];
    }
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}
@end
