#import "GameViewController.h"
#import "BalloonViewController.h"
#import "SettingsViewController.h"
#import "User.h"
#import "Balloon.h"
#import "Session.h"
#import "SequenceGame.h"
#import "AbstractGame.h"
#import "Game.h"
#import "AddNewScoreOperation.h"
#import "GCDQueue.h"
#import "BTLEManager.h"
#import "UserListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#define THUMBNAIL_SIZE 30
#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 400

@interface GameViewController ()<BTLEManagerDelegate, UITabBarDelegate,UITabBarControllerDelegate, SETTINGS_DELEGATE>
{
    int threshold;
    gameDifficulty  currentDifficulty;
    AVAudioPlayer  *audioPlayer;
    bool wasExhaling;
    float bestCurrentVelocity;
    GPUImagePicture *sourcePicture;
    GPUImageFilter *stillImageFilter;
    GPUImageView *imageView;
    CGFloat  targetRadius;
    CADisplayLink *displayLink;
    UIImagePickerController *imagePickerController;
    UIImagePickerController *hqImagePickerController;
    UIButton  *togglebutton;
    UIPopoverController *popover;
    BOOL toggleIsON;
    BOOL gameSoundPlaying;
    BOOL isaccelerating;
    BOOL globalSoundActivated;
    MidiController  *noteController;
    Session  *currentSession;
    NSNumber* currentBreathLength;
    bool currentlyExhaling;
    bool currentlyInhaling;
    NSString* currentImageGameSound;
    int currentlySelectedEffectIndex;
    int selectedBallCount;
    int selectedSpeed;
    bool disableModeButton;
}

@property (nonatomic, retain) NSMutableArray *hqImages;
@property (nonatomic,strong) GameViewGauge  *mainGaugeView;
@property (nonatomic,strong) SettingsViewGauge  *gaugeView;
@property (nonatomic,strong) BTLEManager  *btleMager;
@property (nonatomic,strong) UIView  *hqPickerContainer;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSOperationQueue  *addGameQueue;
@property (nonatomic,strong) BalloonViewController  *balloonViewController;
@property (nonatomic,strong) MidiController  *noteController;
@property (nonatomic)        gameType  currentGameType;
@property (nonatomic,strong) Session  *currentSession;
@property (nonatomic,strong) SequenceGame  *sequenceGameController;
@property (nonatomic,strong) BTLEManager  *btleManager;
@property (weak, nonatomic) IBOutlet UIImageView *imageFilterView;
@property (weak, nonatomic) IBOutlet UIImageView *balloonView;
@end

@implementation GameViewController

-(void)btleManagerConnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-ON"]];
    });
}

-(void)btleManagerDisconnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
    });
}

-(void)startSession
{
    self.currentSession=[Session new];
    self.currentSession.sessionDate=[NSDate date];
    self.currentSession.sessionSpeed = [NSNumber numberWithInt:selectedSpeed];
    self.currentSession.sessionDuration = [NSString stringWithFormat:@"%d", 0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.settingsViewController = [self.tabBarController.viewControllers objectAtIndex:2];
        NSString *defaultDirection=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultDirection"];
        NSNumber *defaultSpeed=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSpeed"];
        NSNumber *defaultRepetitionIndex=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultRepetitionIndex"];
        NSString *defaultSound=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSound"];
        NSNumber *defaultEffectIndex=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultEffect"];
        NSNumber *defaultMute=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultMute"];

        selectedBallCount = [defaultRepetitionIndex intValue];
        currentlySelectedEffectIndex = [defaultEffectIndex intValue];
        currentImageGameSound = defaultSound;
        globalSoundActivated = [defaultMute intValue];
        selectedSpeed = [defaultSpeed intValue];
  
        if ([defaultDirection isEqual: @"Inhale"]){
            self.noteController.toggleIsON = YES;
            [self.settingsViewController setSettingsViewDirection: 0];
            wasExhaling = false;
            [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
            [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
            [self.settingsViewController setGaugeSettings:0 exhaleToggle: YES];
           [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        }else if (defaultDirection == NULL || [defaultDirection isEqual: @"Exhale"]){
            self.noteController.toggleIsON = NO;
            [self.settingsViewController setSettingsViewDirection: 1];
            [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
            [self.settingsViewController setGaugeSettings:1 exhaleToggle: NO];
            [self.settingsViewController.gaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            wasExhaling = true;
        }
        currentDifficulty=gameDifficultyEasy;
        self.title = @"Groov";
        _animationrate=selectedSpeed;
        self.balloonViewController=[[BalloonViewController alloc]initWithFrame:CGRectMake(10, 0, 130,220) withBallCount:selectedBallCount];
        self.noteController=[[MidiController alloc]init];
        self.noteController.delegate=self;
        [self.noteController addObserver:self forKeyPath:@"numberOfSources" options:0 context:NULL];
        self.currentGameType=gameTypeDuo;
        [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:currentDifficulty] forKey:@"difficulty"];
        
        self.addGameQueue=[[NSOperationQueue alloc]init];
        self.btleManager=[BTLEManager new];
        self.btleManager.delegate=self;
        [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.1];
        [self.btleManager setRangeReduction:2];
        [self.btleManager setTreshold:60];
        [self startSession];
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
        [self.photoPickerButton addTarget:self action:@selector(photoButtonLibraryAction) forControlEvents:UIControlEventTouchUpInside];
        [self.HQPhotoPickerButton addTarget:self action:@selector(photoButtonBundleAction) forControlEvents:UIControlEventTouchUpInside];
        self.hqImages = [NSMutableArray array];
        
        imagePickerController = [[UIImagePickerController alloc] init] ;
        imagePickerController.delegate = self;
        hqImagePickerController = [[UIImagePickerController alloc] init] ;
        hqImagePickerController.delegate = self;
        
        self.mainGaugeView=[[GameViewGauge alloc]initWithFrame:CGRectMake(445, 20, 40, MAINGUAGE_HEIGHT) ];
        [self.view addSubview:self.mainGaugeView ];
        [self.view sendSubviewToBack:self.mainGaugeView];
        [self.mainGaugeView setBreathToggleAsExhale:wasExhaling isExhaling: noteController.toggleIsON];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.balloonViewController.view];
    [self.imageFilterView sendSubviewToBack:imageView];
    [self.settingsViewController setSettinngsDelegate:self];
    self.tabBarController.delegate = self;
    
    self.currentGameType = gameTypeDuo;
    self.balloonViewController.currentGameType = self.currentGameType;
    [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    
    if (globalSoundActivated == 1){
        NSLog(@"unmuting sound");
        UIImage *soundOnImage = [UIImage imageNamed:@"Sound-ON.png"];
        [self.soundIcon setImage:soundOnImage forState:UIControlStateNormal];
        [self.balloonViewController setAudioMute: 0];
        [self.sequenceGameController setAudioMute: 0];
        
    }else if(globalSoundActivated == 0){
        NSLog(@"muting sound");
        UIImage *soundOffImage = [UIImage imageNamed:@"Sound-OFF.png"];
        [self.soundIcon setImage:soundOffImage forState:UIControlStateNormal];
        [self.balloonViewController setAudioMute: 1];
        [self.sequenceGameController setAudioMute: 1];
    }
    
    NSString *defaultDirection=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultDirection"];
    if ([defaultDirection isEqual: @"Inhale"]){
        self.noteController.toggleIsON = YES;
        [self.settingsViewController setSettingsViewDirection: 0];
        wasExhaling = false;
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
        [self.settingsViewController setGaugeSettings:0 exhaleToggle: YES];
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
    }else if (defaultDirection == NULL || [defaultDirection isEqual: @"Exhale"]){
        self.noteController.toggleIsON = NO;
        [self.settingsViewController setSettingsViewDirection: 1];
        [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
        [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [self.settingsViewController setGaugeSettings:1 exhaleToggle: NO];
        [self.settingsViewController.gaugeView setBreathToggleAsExhale:1 isExhaling: NO];
        wasExhaling = true;
    }

    [self resetGame:nil];
    velocity=0;
    targetRadius=0;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.currentGameType = gameTypeDuo;
    self.balloonViewController.currentGameType = self.currentGameType;
    [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    [self resetGame:nil];
    
    if (!displayLink) {
        [self setupDisplayFiltering];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateimage)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [displayLink setFrameInterval:3];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [self.mainGaugeView start];
}

- (void)viewDidDisappear:(BOOL)animated{
    self.currentGameType =gameTypeTest;
    [self.mainGaugeView stop];
}

-(void)btleManagerBreathBegan:(BTLEManager*)manager{
    
    if (self.noteController.toggleIsON == 0){wasExhaling = 1;}else{wasExhaling = 0;};
    
    disableModeButton = true;
    if ([self.noteController allowBreath]==NO) {
        return;
    }

    if ((self.noteController.toggleIsON == 0 && wasExhaling == 1) || (self.noteController.toggleIsON == 1 && wasExhaling == 0)){
        self.sequenceGameController.time = 0;
        bestCurrentVelocity = 0;
        
        if ((self.noteController.toggleIsON == 0 && wasExhaling == 1) || (self.noteController.toggleIsON == 1 && wasExhaling == 0)){
            
            [self.sequenceGameController startTimer];
            
            switch (self.currentGameType) {
                case gameTypeDuo:
                    [self noteBeganForSequence:nil];
                    self.balloonViewController.currentGameType=gameTypeDuo;
                    break;
                case gameTypeImage:
                    self.balloonViewController.currentGameType=gameTypeImage;
                    break;
                case gameTypeBalloon:
                    [self noteBeganForSequence:nil];
                    self.balloonViewController.currentGameType=gameTypeBalloon;
                    break;
                case gameTypeTest:
                    [self noteBeganForSequence:nil];
                    self.balloonViewController.currentGameType=gameTypeTest;
                    break;
                default:
                    break;
            }
        }
        
        if (self.mainGaugeView.animationRunning) {
            [self.mainGaugeView blowingBegan];
        }
        
        if (self.gaugeView.animationRunning) {
            [self.gaugeView blowingBegan];
        }
        
        if (self.settingsViewController.gaugeView.animationRunning) {
            [[self.settingsViewController gaugeView] blowingBegan];
        }
    }
}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    disableModeButton = false;
    
    //added
    [[self.settingsViewController gaugeView] blowingEnded];
    [self.sequenceGameController killTimer];
    self.sequenceGameController.time = 0;
    
    if ([self.noteController allowBreath]==NO) {
        return;
    }
    [self.balloonViewController blowEnded];
   
    if ((self.noteController.toggleIsON == false && wasExhaling == true) || (self.noteController.toggleIsON == true && wasExhaling == false)){
        if (_currentGameType == gameTypeImage || _currentGameType == gameTypeTest ){
            return;
        }
        if (self.currentGameType == gameTypeImage ) {
            [self imageGameWon];
        }
        
        [self.sequenceGameController killTimer];
        [self.sequenceGameController nextBall];
    }
    
    NSLog(@"END");
    
    [self.mainGaugeView blowingEnded];
    [self.gaugeView blowingEnded];
    
    if (self.currentGameType == gameTypeTest){
        NSLog(@"Currently in test mode, saving disabled");
    }else{
        if ((self.noteController.toggleIsON == false && wasExhaling == true) || (self.noteController.toggleIsON == true && wasExhaling == false)){
            [self saveCurrentSession];
        }
    }

    isaccelerating=NO;
    gameSoundPlaying = NO;
}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    
    wasExhaling = false;

    if (self.noteController.toggleIsON==NO) {
        return;
    }
    
    [self.mainGaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.noteController.toggleIsON];
    [self.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.noteController.toggleIsON];
    [self.settingsViewController.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.noteController.toggleIsON];
    [self.balloonViewController blowStarted: self.sequenceGameController.currentBall atSpeed:selectedSpeed];
    
    if (gameSoundPlaying == NO){
        switch (self.currentGameType) {
                case gameTypeDuo:
                    [self playImageGameSound];
                    gameSoundPlaying = YES;
                    break;
                case gameTypeImage:
                    [self playImageGameSound];
                     gameSoundPlaying = YES;
                    break;
                case gameTypeBalloon:
                    [self playGameSound];
                     gameSoundPlaying = YES;
                    break;
                case gameTypeTest:
                    break;
                default:
                    break;
            }
    }
    
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    self.noteController.velocity=127.0*percentOfmax;
    self.noteController.speed= (fabs( self.noteController.velocity- self.noteController.previousVelocity));
    self.noteController.previousVelocity= self.noteController.velocity;
    
   float scale=50.0f;
   float value=self.velocity*scale;
   [self.mainGaugeView setForce:(value)];
   [self.gaugeView setForce:(value)];
   [self.settingsViewController.gaugeView setForce:(value)];
   [self noteContinuing: self.noteController];
}

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    
    wasExhaling = true;
    if (self.noteController.toggleIsON==YES) {
        return;
    }
    
    [self.mainGaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.noteController.toggleIsON];
    [self.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.noteController.toggleIsON];
    [self.settingsViewController.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.noteController.toggleIsON];
    [self.balloonViewController blowStarted: self.sequenceGameController.currentBall atSpeed:selectedSpeed];
    
    if (gameSoundPlaying == NO){
        switch (self.currentGameType) {
            case gameTypeDuo:
                [self playImageGameSound];
                 gameSoundPlaying = YES;
                break;
            case gameTypeImage:
                [self playImageGameSound];
                 gameSoundPlaying = YES;
                break;
            case gameTypeBalloon:
                [self playGameSound];
                 gameSoundPlaying = YES;
                break;
            case gameTypeTest:
                break;
            default:
                break;
        }
    }
    
    self.noteController.velocity=127.0*percentOfmax;
    self.noteController.speed= (fabs( self.noteController.velocity- self.noteController.previousVelocity));
    self.noteController.previousVelocity= self.noteController.velocity;
    
    [self noteContinuing: self.noteController];
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    float scale=100.0f;
    float value=self.velocity*scale;
    [self.mainGaugeView setForce:(value)];
    [self.gaugeView setForce:(value)];
    [self.settingsViewController setGaugeForce:(value)];
}

- (IBAction)openPhotoPicker:(id)sender {
    [self photoButtonLibraryAction];
}

- (IBAction)openHQContrastPhoto:(id)sender {
    [self photoButtonBundleAction];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    if (self.sharedPSC != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    return _managedObjectContext;
}

-(void)setLabels
{
    [self managedObjectContext];
    [[GCDQueue mainQueue]queueBlock:^{
        self.currentUsersNameLabel.text=[self.gameUser valueForKey:@"userName"];
    }];
}

- (IBAction)goToSettings:(id)sender {
    self.currentGameType = gameTypeTest;
    self.balloonViewController.currentGameType = self.currentGameType;
    [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    [self.settingsViewController setSettingsDurationLabelText: [NSString stringWithFormat:@"%.1f", 0.0]];
}

-(IBAction)toggleDirection:(id)sender
{
    [self.gaugeView blowingEnded];
   // [self.settingsViewController.gaugeView blowingEnded];
    [[self.settingsViewController gaugeView] blowingEnded];
    //[self.settingsViewController settingsGaugeEndedBlow];
    
    if (self.noteController.toggleIsON == YES){
            self.noteController.toggleIsON=NO;
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
            [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            [self.settingsViewController setGaugeSettings:1 exhaleToggle: NO];
            wasExhaling = true;
    }else if (self.noteController.toggleIsON == NO){
            self.noteController.toggleIsON=YES;
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
            wasExhaling = false;
            [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
            [self.settingsViewController setGaugeSettings:0 exhaleToggle: YES];
    }
}

-(void)setDirection:(int)value{
    
    [self.gaugeView blowingEnded];
    //[self.settingsViewController.gaugeView blowingEnded];
    [[self.settingsViewController gaugeView] blowingEnded];
    //[self.settingsViewController settingsGaugeEndedBlow];
    
    if (self.noteController.toggleIsON == YES){
        self.noteController.toggleIsON=NO;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
        [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
        wasExhaling = true;
    }else if (self.noteController.toggleIsON == NO){
        self.noteController.toggleIsON=YES;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        wasExhaling = false;
        [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
    }
}

-(IBAction)toggleGameMode:(id)sender
{
    if (disableModeButton == true){
        NSLog(@"game mode button is disabled");
    }else{
        NSLog(@"Toggling game mode");
        int mode=self.currentGameType;
        mode++;
        
        if (mode>2) {
            mode=gameTypeBalloon;
        }
        
        self.currentGameType=mode;
        self.balloonViewController.currentGameType = self.currentGameType;
        [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
        [self resetGame:nil];
    }
}

-(NSString*)stringForMode:(int)mode
{
    NSString  *modeString;
    
    switch (mode) {
        case gameTypeDuo:
            modeString=@"MainMode-BOTH";
            break;
        case gameTypeImage:
            modeString=@"MainMode-IMAGE";
            break;
        case gameTypeBalloon:
            modeString=@"MainMode-BALLOON";
            break;
        case gameTypeTest:
            modeString=@"MainMode-BALLOON";
            break;
        default:
            break;
    }
    return modeString;
}

-(IBAction)resetGame:(id)sender
{
    self.sequenceGameController= [[SequenceGame alloc] initWithBallCount:selectedBallCount ];
        self.sequenceGameController.delegate=self;
    [self.balloonViewController resetwithBallCount:selectedBallCount];
    if (globalSoundActivated == 1){
        NSLog(@"unmuting sound");
        [self.sequenceGameController setAudioMute: 0];
    }else if(globalSoundActivated == 0){
        NSLog(@"muting sound");
        [self.sequenceGameController setAudioMute: 1];
    }
}

-(void)noteContinuing:(MidiController*)note
{
    if (note.velocity==127) {
        return;
    }

    if (note.velocity > bestCurrentVelocity){
        bestCurrentVelocity = note.velocity;
    }
    
    NSLog(@"note.velocity %f", note.velocity);
    
    if (self.currentGameType == gameTypeTest){
        if (note.velocity > 100){bestCurrentVelocity = 100;}
        
        if (self.noteController.toggleIsON == false){
            [self.settingsViewController setSettingsStrengthLabelText:[NSString stringWithFormat:@"%0.0f",bestCurrentVelocity*2.1]];
        }else{
            [self.settingsViewController setSettingsStrengthLabelText:[NSString stringWithFormat:@"%0.0f",bestCurrentVelocity]];
        }
    }else{
        if  (note.velocity > 250){ bestCurrentVelocity = 250;}
    }
    
    if (self.noteController.toggleIsON == false){
       // if (note.velocity > [self.currentSession.sessionStrength floatValue]) {
            NSLog(@"FG %f",bestCurrentVelocity*2.1);
            self.currentSession.sessionStrength=[NSNumber numberWithFloat:bestCurrentVelocity*2.1];
      //  }
    }else{
       // if (note.velocity > [self.currentSession.sessionStrength floatValue]) {
            NSLog(@"FG %f",bestCurrentVelocity*2.2);
            self.currentSession.sessionStrength=[NSNumber numberWithFloat:bestCurrentVelocity];
      //  }
    }
    
    [self.settingsViewController setSettingsDurationLabelText:[NSString stringWithFormat:@"%.1f",self.sequenceGameController.time]];
    self.currentSession.sessionSpeed = [NSNumber numberWithInt:selectedSpeed];
    self.currentSession.sessionDuration = [NSString stringWithFormat:@"%g", self.sequenceGameController.time];
    
    [[GCDQueue mainQueue]queueBlock:^{
        switch (self.currentGameType) {
            case gameTypeDuo:
                [self noteContinuingForSequence:note];
                break;
            case gameTypeImage:
                break;
            case gameTypeBalloon:
                [self noteContinuingForSequence:note];
                break;
            case gameTypeTest:
                break;
            default:
                break;
        }
    }];
}

-(void)noteBeganForSequence:(MidiController *)note
{
    self.sequenceGameController.currentSpeed= -1;
    self.sequenceGameController.time = 0;
    
    if (_currentGameType == gameTypeImage || _currentGameType == gameTypeTest ){
        return;
    }
    [self.sequenceGameController startTimer];
}


-(void)noteContinuingForSequence:(MidiController*)note
{
    self.sequenceGameController.currentSpeed=note.speed;
    
    if (_currentGameType == gameTypeImage || _currentGameType == gameTypeTest){
        return;
    }
    
    [self.sequenceGameController setAllowNextBall:YES];
    
    if (self.sequenceGameController.halt) {
        return;
    }
    
    if (self.sequenceGameController.allowNextBall) {
        self.sequenceGameController.halt=YES;
        
        [[GCDQueue mainQueue]queueBlock:^{
            if (note.speed!=0) {
                self.sequenceGameController.totalBallsRaised++;
            }
        }];
    }
}

- (IBAction)toggleMuteSound:(id)sender {

    if (globalSoundActivated == 0){
        globalSoundActivated = 1;
        UIImage *soundOnImage = [UIImage imageNamed:@"Sound-ON.png"];
         [self.soundIcon setImage:soundOnImage forState:UIControlStateNormal];
         NSLog(@"unmuting sound");
         [self.balloonViewController setAudioMute: 0];
         [self.sequenceGameController setAudioMute: 0];
    }else if(globalSoundActivated == 1){
        globalSoundActivated = 0;
         NSLog(@"muting sound");
        UIImage *soundOffImage = [UIImage imageNamed:@"Sound-OFF.png"];
        [self.soundIcon setImage:soundOffImage forState:UIControlStateNormal];
         [self.balloonViewController setAudioMute: 1];
         [self.sequenceGameController setAudioMute: 1];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:globalSoundActivated] forKey:@"defaultMute"];
}

-(void)gameEnded:(AbstractGame *)game
{
    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame:nil];
    }];
    
    [self saveCurrentSession];
    [self.sequenceGameController killTimer];
}

-(void)imageGameWon
{
    [[GCDQueue mainQueue]queueBlock:^{
        [self saveCurrentSession];
    }];
}

-(void)gameWon:(AbstractGame *)game
{
    
    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame:nil];
    }];
    
    [self.sequenceGameController killTimer];
}

-(void)saveCurrentSession
{
    self.currentSession.sessionType=[NSNumber numberWithInt:self.currentGameType];
    AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:self.currentSession sharedPSC:self.sharedPSC];
    [self.addGameQueue addOperation:operation];
    [self startSession];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self setupDisplayFilteringWithImage:image];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        NSData *webData = UIImagePNGRepresentation(image);
        [webData writeToFile:imagePath atomically:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
     [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)photoButtonLibraryAction
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [popover presentPopoverFromRect:CGRectMake(0, 0, 500, 500) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)photoButtonBundleAction
{
    self.hqPickerContainer = [[UIView alloc] initWithFrame:CGRectMake(280, 520, 246, 270)];
    self.hqPickerContainer.backgroundColor = [UIColor blackColor];
    
    NSArray *hqImages = [self getHQImages];
    CGFloat currentX = 2.0f;
    CGFloat currentY = 2.0f;

    for (int i=0; i < [hqImages count]; i++) {
        UIImage *image = [UIImage imageNamed:[hqImages objectAtIndex:i]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        imageView.image= image;
        CGRect rect = imageView.frame;
        rect.origin.x = currentX;
        rect.origin.y = currentY;
        imageView.frame = rect;
        
        if(i == 0){
           // NSLog(@"first");
        }else if (i % 4 == 0){
            currentY += 54;
            rect.origin.y = currentY;
            currentX = 2.0f;
            rect.origin.x = currentX;
        }else if (i == 19){
            UIImage *lastImage = [UIImage imageNamed:@"HQ 1.jpg"];
            UIImageView *lastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
            lastImageView.image= lastImage;
            CGRect lastRect = lastImageView.frame;
            lastRect.origin.x = 184;
            lastRect.origin.y = 218;
            lastImageView.frame = lastRect;
            lastImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [lastImageView addGestureRecognizer:tap];
            [self.hqPickerContainer addSubview:lastImageView];
            [self.hqPickerContainer bringSubviewToFront:lastImageView];
        }else{
            currentX += imageView.frame.size.width + 2;
        }
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [imageView addGestureRecognizer:tap];
        [self.hqPickerContainer addSubview:imageView];
        [self.hqPickerContainer bringSubviewToFront:imageView];
    }
    
    [self.view addSubview: self.hqPickerContainer];
}

- (IBAction)tapGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint tapLocation = [gesture locationInView: self.hqPickerContainer];
    for (UIImageView *imageView in self.hqPickerContainer.subviews) {
        if (CGRectContainsPoint(imageView.frame, tapLocation)) {
            [self setupDisplayFilteringWithImage:imageView.image];
        }
    }
    
    [self.hqPickerContainer removeFromSuperview];
}

-(NSArray*)getHQImages{
    
    NSString *bundleRootPath = [[NSBundle mainBundle] bundlePath];
    NSArray *bundleRootContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRootPath error:nil];
    NSArray *files = [bundleRootContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self beginswith 'HQ'"]];
    
    return files;
}

@synthesize velocity;

-(void)setBreathLength:(float)value
{
    selectedSpeed = (int) (value + 0.5);
    _animationrate= (int) (value + 0.5);
}

-(void)setSpeed:(float)value
{
    selectedSpeed = roundf(value);
    self.currentSession.sessionSpeed = [NSNumber numberWithFloat:selectedSpeed];
    _animationrate=selectedSpeed;
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:selectedSpeed] forKey:@"defaultSpeed"];
}

-(void)prepareDisplay{
    [self.mainGaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: noteController.toggleIsON];
    [self.mainGaugeView start];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tap];
    
    if (!displayLink) {
        [self setupDisplayFiltering];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateimage)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [displayLink setFrameInterval:3];
    }
}

-(void)updateimage
{
    if (self.currentGameType == gameTypeTest) {
    return;
    }else if (self.currentGameType == gameTypeBalloon){
    return;
    }
    
    if (isaccelerating)
    {
        if (self.velocity>=threshold) {
            float newRate = .05/_animationrate;
            targetRadius=targetRadius+newRate;
        }
    }else
    {
        targetRadius=targetRadius-(40.0/500);
    }
    
    if (targetRadius<0.001) {
        targetRadius=0.001;
    }
    
    if (targetRadius>1) {
        targetRadius=1;
    }
    
//    NSLog(@"radius - @%", targetRadius);
    
    if ([stillImageFilter isKindOfClass:[GPUImageBulgeDistortionFilter class]])
    {
        if (targetRadius<0.001) {
            targetRadius=0.0;
        }
        [(GPUImageBulgeDistortionFilter*)stillImageFilter setRadius:targetRadius];
    }else if ([stillImageFilter isKindOfClass:[GPUImageSwirlFilter class]])
    {
        [(GPUImageSwirlFilter*)stillImageFilter setRadius:targetRadius];
    }else if ([stillImageFilter isKindOfClass:[GPUImageZoomBlurFilter class]])
    {
        [(GPUImageZoomBlurFilter*)stillImageFilter setBlurSize:targetRadius];
    }else if ([stillImageFilter isKindOfClass:[GPUImageVignetteFilter class]])
    {
        [(GPUImageVignetteFilter*)stillImageFilter setVignetteStart:1-targetRadius];
    }else if ([stillImageFilter isKindOfClass:[GPUImageToonFilter class]])
    {
        [(GPUImageToonFilter*)stillImageFilter setThreshold:1-(targetRadius-0.1)];
    }else if ([stillImageFilter isKindOfClass:[GPUImageExposureFilter class]])
    {
        [(GPUImageExposureFilter*)stillImageFilter setExposure:targetRadius+0.1];
    }else if ([stillImageFilter isKindOfClass:[GPUImagePolkaDotFilter class]])
    {
        [(GPUImagePolkaDotFilter*)stillImageFilter setFractionalWidthOfAPixel:targetRadius/10];
    }else if ([stillImageFilter isKindOfClass:[GPUImagePosterizeFilter class]])
    {
        [(GPUImagePosterizeFilter*)stillImageFilter setColorLevels:11-(10*targetRadius)];
    }else if ([stillImageFilter isKindOfClass:[GPUImagePixellateFilter class]])
    {
        [(GPUImagePixellateFilter*)stillImageFilter setFractionalWidthOfAPixel:targetRadius/10];
    }else if ([stillImageFilter isKindOfClass:[GPUImageContrastFilter class]])
    {
        [(GPUImageContrastFilter*)stillImageFilter setContrast:1-targetRadius];
    }
    
    if (isaccelerating){
        [sourcePicture processImage];
    }
}

-(void)setupDisplayFilteringWithImage:(UIImage*)aImage
{
    [sourcePicture removeAllTargets];
    stillImageFilter=nil;
    sourcePicture = [[GPUImagePicture alloc] initWithImage:aImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex:1];
    [self.imageFilterView insertSubview:imageView atIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    [sourcePicture processImage];
    [(GPUImageSwirlFilter*)stillImageFilter setRadius:100];
}

- (void)setupDisplayFiltering;
{
    UIImage *inputImage;
    inputImage=[UIImage imageNamed:@"giraffe-614141_1280.jpg"];
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex: currentlySelectedEffectIndex];
    imageView = [[GPUImageView alloc]initWithFrame:self.imageFilterView.frame];
    [self.imageFilterView insertSubview:imageView atIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
}

-(void)setFilter:(int)index
{
    [sourcePicture removeAllTargets];
    stillImageFilter=nil;
    stillImageFilter=[self filterForIndex:index];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    [self.mainGaugeView start];
    [self.mainGaugeView setForce:0];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:index] forKey:@"defaultEffect"];
    currentlySelectedEffectIndex = index;
}

-(void)setRepetitionCount:(int)value{
    selectedBallCount = value;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:selectedBallCount] forKey:@"defaultRepetitionIndex"];
}

-(void)setImageSoundEffect:(NSString*)value{
    currentImageGameSound = value;
    [[NSUserDefaults standardUserDefaults]setObject:currentImageGameSound forKey:@"defaultSound"];
}

-(GPUImageFilter*)filterForIndex:(int)index
{
    GPUImageFilter *filter;
    
    switch (index) {
        case 0:
            filter=[[GPUImageBulgeDistortionFilter alloc] init];
            break;
        case 1:
            filter=[[GPUImageSwirlFilter alloc] init];
            break;
        case 2:
            filter=[[GPUImageZoomBlurFilter alloc] init];
            break;
        case 3:
            filter=[[GPUImageToonFilter alloc] init];
            break;
        case 4:
            filter=[[GPUImageExposureFilter alloc] init];
            break;
        case 5:
            filter=[[GPUImagePolkaDotFilter alloc] init];
            break;
        case 6:
            filter=[[GPUImagePosterizeFilter alloc] init];
            break;
        case 7:
            filter=[[GPUImagePixellateFilter alloc] init];
            break;
        case 8:
            filter=[[GPUImageContrastFilter alloc] init];
            break;
        default:
            break;
    }
    return filter;
}

-(void) playImageGameVictorySound {
    
    NSLog(@"playImageGameVictorySound");
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"applauding" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume= 0.5;
        
        
        if (globalSoundActivated == 1){
            NSLog(@"playImageGameVictorySound AUDIO MUTED");
        }else{
            [audioPlayer play];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    @finally {
        
    }
}

-(void) playImageGameSound {
    NSString* imageName = @"";
    
    if (_currentGameType == gameTypeBalloon){
        imageName = [NSString stringWithFormat:@"%dBallon", selectedSpeed];
    }else{
        imageName = [NSString stringWithFormat:@"%d%@", selectedSpeed, currentImageGameSound];
    }
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: imageName ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    
    if (globalSoundActivated == 1){
        [audioPlayer play];
    }else{
        NSLog(@"Global sound set to off");
    }
}

-(void) playGameSound {
    NSString* imageName = @"";
    
    if (_currentGameType == gameTypeBalloon){
        imageName = [NSString stringWithFormat:@"%dBallon", selectedSpeed];
    }else{
        imageName = [NSString stringWithFormat:@"%d%@", selectedSpeed, currentImageGameSound];
    }
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: imageName ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    
    if (globalSoundActivated == 1){
        [audioPlayer play];
    }else{
        NSLog(@"Global sound set to off");
    }
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[SettingsViewController class]]){
        self.settingsViewController = (SettingsViewController *) viewController;
    }
    return TRUE;
}

@end
