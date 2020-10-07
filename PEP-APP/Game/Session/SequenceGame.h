#import "AbstractGame.h"

@interface SequenceGame : AbstractGame
@property BOOL allowNextBall;
@property int totalBallsRaised;
@property int totalBallsAttempted;
@property int currentSpeed;
@property BOOL  halt;
-(id) initWithBallCount: (int)ballCount;
-(void)setAudioMute: (int) muteSetting;
@end
