#import <UIKit/UIKit.h>
#import "Balloon.h"
#import "AbstractGame.h"
#import "Game.h"
#import "GPUImage.h"

@interface BalloonViewController : UIViewController<BalloonProtocol>
-(id)initWithFrame:(CGRect)frame withBallCount:(int)ballCount;
-(void)blowAttempt:(int)ballNo;
-(void)resetwithBallCount:(int)ballCount;
-(void)blowStarted:(int)currentBallNo atSpeed:(int)speed;
-(void)blowEnded;
-(void)timerFired:(NSTimer *)timer;
-(CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight;
-(void)setAudioMute: (BOOL) muteSetting;
@property gameType  currentGameType;
@end
