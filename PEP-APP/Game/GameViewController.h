#import <UIKit/UIKit.h>
#import "User.h"
#import "Game.h"
#import "GameViewGauge.h"
#import "SettingsViewGauge.h"
#import "AbstractGame.h"
#import "MidiController.h"
#import "GPUImage.h"
#define THUMBNAIL_SIZE 30
#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 400

@class SettingsViewController;
@protocol SETTINGS_DELEGATE
    -(void)sendValue:(int)note onoff:(int)onoff;
    -(void)setFilter:(int)index;
    -(void)setRate:(float)value;
    -(void)setThreshold:(float)value;
    -(void)setBTTreshold:(float)value;
    -(void)setBTBoost:(float)value;
    -(void)setRepetitionCount:(int)value;
    -(void)setBreathLength:(float)value;
    -(void)setImageSoundEffect:(NSString*)value;
    -(void)test:(float)value;
    -(void)setSpeed:(float)value;
    -(void)setDirection:(int)value;
    -(void)settingsModeDismissRequest:(SettingsViewController*)caller;
    -(void)settingsModeToUser:(SettingsViewController*)caller;
@end

@interface GameViewController : UIViewController<MidiControllerProtocol,GameProtocol,  SETTINGS_DELEGATE,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate>{
    GPUImageOutput<GPUImageInput> *sepiaFilter, *sepiaFilter2;
    UISlider *imageSlider;
}

-(IBAction)toggleDirection:(id)sender;
-(IBAction)toggleGameMode:(id)sender;
-(IBAction)presentSettings:(id)sender;
-(IBAction)resetGame:(id)sender;
-(void)setupDisplayFiltering;
-(void)prepareDisplay;
-(void)setLabels;

@property (weak, nonatomic) IBOutlet UIImageView *bluetoothIcon;
@property (weak, nonatomic) IBOutlet UIButton *soundIcon;
@property (weak, nonatomic) IBOutlet UIButton *photoPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *HQPhotoPickerButton;
@property (unsafe_unretained) id<SETTINGS_DELEGATE> settinngsDelegate;
@property (nonatomic,weak) IBOutlet  UIButton *toggleDirectionButton;
@property (nonatomic,weak) IBOutlet  UIButton *toggleGameModeButton;
@property (nonatomic,strong) SettingsViewController *settingsViewController;
@property (nonatomic,weak) IBOutlet  UILabel *currentUsersNameLabel;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic,strong)User  *gameUser;
@property (nonatomic,unsafe_unretained)id<UITabBarDelegate>delegate;
@property float velocity;
@property float animationrate;
@end
