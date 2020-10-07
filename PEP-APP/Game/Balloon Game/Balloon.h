#import <UIKit/UIKit.h>

@class Balloon;
@protocol BalloonProtocol <NSObject>
-(void)balloonReachedFinalTarget:(Balloon*)ball;
@end
@interface Balloon : UIView <NSObject, CAAnimationDelegate>
@property (nonatomic,strong)NSNumber  *weight;
@property(nonatomic,strong)UIDynamicAnimator *animator;
@property(nonatomic,strong)CAAnimation *animation;
@property(nonatomic)CGPoint  targetPoint;
@property(nonatomic,unsafe_unretained)id<BalloonProtocol>delegate;
@property BOOL animationRunning;
@property(nonatomic,weak)UIImageView  *arrow;
@property int gaugeHeight;
@property UIImageView* currentBalloonImage;
-(void)start;
-(void)stop;
-(void)setForce:(float)pforce;
-(void)setMass:(float)value;
-(void)blowingBegan;
-(void)blowingEnded;
-(void)setSpeed:(int)speed allowAnimate:(BOOL)allow;
@end
