#import "GameViewController.h"
#import "SettingsViewController.h"
#import "UserListViewController.h"
#import "InfoViewController.h"

@interface MainTableViewController:UITabBarController

@property(nonatomic,strong) UserListViewController *userListViewController;
@property(nonatomic,strong) GameViewController  *gameViewController;
@property(nonatomic,strong) InfoViewController  *infoViewController;
@property(nonatomic,strong) SettingsViewController *settingsViewController;
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) UITableView *tableview;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.gameViewController) {
        self.gameViewController=[[GameViewController alloc]initWithNibName:@"GameViewController" bundle:nil];
        self.gameViewController.delegate = self;
    }
    
    if (!self.settingsViewController) {
        self.settingsViewController=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    }
    
    if (!self.infoViewController) {
        self.infoViewController=[[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];
    }
    
    if (!self.userListViewController) {
        self.userListViewController=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    }
    
    self.gameViewController.settingsViewController = self.settingsViewController;
    [self.settingsViewController setSettinngsDelegate:self.gameViewController];
    [self.gameViewController prepareDisplay];
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:self.gameViewController];
    [tabViewControllers addObject:self.settingsViewController];
    [tabViewControllers addObject:self.userListViewController];
    [tabViewControllers addObject:self.infoViewController];
    
    [self setViewControllers:tabViewControllers];
    self.gameViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"GameViewController"
                                  image:[UIImage imageNamed:@"PEP-App-INACTIVE-80x80"]
                                    tag:1];
    self.settingsViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"SettingsViewController"
                                  image:[UIImage imageNamed:@"Settings-INACTIVE-80x80"]
                                    tag:2];
    self.userListViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"UserListViewController"
                                  image:[UIImage imageNamed:@"Users-INACTIVE-80x80"]
                                    tag:3];
    self.infoViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"InfoViewController"
                                  image:[UIImage imageNamed:@"Info-INACTIVE-80x80"]
                                    tag:4];
    
    
    self.infoViewController.tabBarItem.title = @"";
    self.userListViewController.tabBarItem.title = @"";
    self.settingsViewController.tabBarItem.title = @"";
    self.gameViewController.tabBarItem.title = @"";
    self.delegate = self;
}
const CGFloat kBarHeight = 100;
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"Laying out tab bar");

    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = kBarHeight;
    tabFrame.origin.y = self.view.frame.size.height - kBarHeight;
    self.tabBar.frame = tabFrame;
}

-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user withManagedObjectContext:(NSManagedObjectContext*)moc{
    self.gameViewController.gameUser=user;
    [self.gameViewController setLabels];
    self.gameViewController.sharedPSC=store;
    self.userListViewController.sharedPSC=store;
    [self.userListViewController getListOfUsers];
    self.managedObjectContext = moc;
}

-(void)saveUserSettings {
    
    NSLog(@"SAVING SETTINGS");
    
    NSString *direction=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultDirection"];
    NSNumber *defaultSpeed=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSpeed"];
    NSNumber *defaultRepetitionIndex=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultRepetitionIndex"];
    NSString *defaultSound=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSound"];
    NSNumber *defaultEffect=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultEffect"];
    NSNumber *defaultMute=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultMute"];

    NSString  *name=[self.gameViewController.gameUser valueForKey:@"userName"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    [fetchRequest setEntity:entity];
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];

    User *user = items[0];
    [user setValue:direction forKey:@"defaultDirection"];
    [user setValue:defaultSpeed forKey:@"defaultSpeed"];
    [user setValue:defaultRepetitionIndex forKey:@"defaultRepetitionIndex"];
    [user setValue:defaultSound forKey:@"defaultSound"];
    [user setValue:defaultMute forKey:@"defaultMute"];
    [user setValue:defaultEffect forKey:@"defaultEffect"];
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during developmeint. If it is not possible to recover from the error, display an alerto
            // panel that instructs the user to quit the application by pressing the Home button.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableview =tableView;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)viewDidDisappear:(BOOL)animated{
     [self saveUserSettings];
}

@end
