#import "ViewController.h"
#import "AddNewUserOperation.h"
#import "User.h"
#import "Game.h"
#import "MainTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BTLEManager.h"

typedef void(^RunTimer)(void);
@interface ViewController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) LoginViewController  *loginViewController;
@property (nonatomic,strong) MainTableViewController  *mainTableViewController;
@property (nonatomic,strong) User  *currentUser;
@property (nonatomic,strong) Game  *currentGame;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserError:) name:kAddNewUserOperationUserError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserExistsError:) name:kAddNewUserOperationUserExistsError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserSuccess:) name:kAddNewUserOperationUserAdded object:nil];
    [self managedObjectContext];
    [self addUserLoginViewController]; 
}

-(void)addUserLoginViewController
{
    if (!self.loginViewController) {
        self.loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self.view addSubview:self.loginViewController.view];
    self.loginViewController.sharedPSC=self.persistentStoreCoordinator;
    self.loginViewController.delegate=self;
}

-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user
{
    self.currentUser=user;
    
    if (!self.mainTableViewController) {
        self.mainTableViewController=[[MainTableViewController alloc]initWithNibName:@"MainTableViewController" bundle:nil];
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate setRootTablViewController: self.mainTableViewController];
    }
    
    [self.mainTableViewController setMemoryInfo:self.persistentStoreCoordinator withuser:user withManagedObjectContext: _managedObjectContext];
    
    [UIView transitionFromView:self.loginViewController.view toView:self.mainTableViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){}
    ];
}


- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"mom"]; //was mom
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Model.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        abort();
    }
    return _persistentStoreCoordinator;
}

- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

-(void)addUserSuccess:(NSNotification*)notification
{
}
-(void)addUserExistsError:(NSNotification*)notification
{
}
-(void)addUserError:(NSNotification*)notification
{
}

#pragma mark -
@end
