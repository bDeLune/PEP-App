#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "SettingsViewGauge.h"

@interface SettingsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate, SETTINGS_DELEGATE>
{
    IBOutlet UISlider *speedSlider;
    IBOutlet UIPickerView *filterPicker;
    IBOutlet UIPickerView *pickerViewB;
    IBOutlet UIPickerView *pickerViewC;
    IBOutlet UILabel *settingsStrengthLabel;
    IBOutlet UILabel *settingsDurationLabel;
    IBOutlet UIImageView *whiteBackground;
    IBOutlet UIImageView *backgroundImage;
    IBOutlet UILabel *breathLengthLabel;
    NSMutableArray *imageGameSoundArray;
    NSMutableArray *repititionsArray;
    NSMutableArray *filterArray;
    NSMutableArray *imageGameSoundFileNameArray;
    NSMutableArray *filterFileNameArray;
    int currentdirection;
    id<SETTINGS_DELEGATE> __unsafe_unretained settinngsDelegate;
}

@property (unsafe_unretained) id<SETTINGS_DELEGATE> settinngsDelegate;
@property(nonatomic,strong)SettingsViewGauge  *gaugeView;
-(void) setSettingsStrengthLabelText:(NSString*)text;
-(void) setSettingsDurationLabelText:(NSString*)text;
-(void) setGaugeForce:(float)force;
-(void) setSettingsViewDirection:(int)val;
-(void) setGaugeSettings: (int)breathToggle exhaleToggle:(BOOL)ex;
-(void) settingsGaugeBeginBlow;
-(void) settingsGaugeEndedBlow;
@end
