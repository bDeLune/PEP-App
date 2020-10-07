#import <UIKit/UIKit.h>
#import "BTLEManager.h"
#define GAUGE_WIDTH  330
#define GUAGE_HEIGHT 710
#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]

@interface SettingsViewGauge : UIView 
@property BOOL animationRunning;
-(void)start;
-(void)stop;
-(void)setForce:(float)pforce;
-(void)blowingBegan;
-(void)blowingEnded;
-(void)setMass:(float)value;
-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;
-(void)setBestDistanceWithY:(float)yValue;
@end
