#import <AVFoundation/AVFoundation.h>
#import "BalloonViewController.h"
#import "Balloon.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "GCDQueue.h"
#define BALL_RADIUS  80
#define BALLOON_RADIUS  30

@interface BalloonViewController ()<UICollisionBehaviorDelegate>
{
    CGPoint  topPoint;
    NSMutableArray *activeBallsForPower;
    int ballGameCount;
    AVAudioPlayer *audioPlayer;
    BOOL muteAudio;
    int  selectedGameBallCount;
    int  selectedSpeedSetting;
    float timeCounter;
    NSTimer* _timer;
    BOOL isaccelerating;
    int currentBall;
    NSDate* start;
}
@property(nonatomic,strong)  NSMutableArray  *balls;
@property(nonatomic,strong)  NSMutableArray  *emptyBalloons;
@property(nonatomic,strong) NSMutableArray  *animators;
@property int currentBallININdex;
@end

@implementation BalloonViewController

- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [(UIView*)item setTintColor:[UIColor lightGrayColor]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withBallCount:(int)ballCount{
    self=[super init];
    if (self) {
        UIView  *view=[[UIView alloc]initWithFrame:frame];
        self.view=view;
        self.view.backgroundColor=[UIColor  clearColor];
        self.balls=[NSMutableArray new];
        self.emptyBalloons=[NSMutableArray new];
        self.animators=[NSMutableArray new];
        selectedGameBallCount = ballCount;
        self.view.layer.zPosition = 3;
    }
    return self;
}

-(void)makeBalls
{
    self.currentBallININdex=0;
   __block int  startx=0;
    
    for (int i=0; i<selectedGameBallCount; i++) {
        
        Balloon *balloon=[[Balloon alloc]initWithFrame:CGRectMake(startx, 0, BALLOON_RADIUS, BALLOON_RADIUS)];
        BOOL allowAnimate = 1;
        
        if (_currentGameType == gameTypeTest || _currentGameType == gameTypeImage ){
            allowAnimate = 0;
        }
        
        [balloon setSpeed:selectedSpeedSetting allowAnimate: allowAnimate];
        [self.balls addObject:balloon];
        balloon.gaugeHeight=self.view.bounds.size.height;
        balloon.delegate=self;
        [self.view addSubview:balloon];
        startx+=BALLOON_RADIUS+6;
    }

    [self animateBallStart];
}

-(void)animateBallStart
{
    for (ItemCount i=0; i<[self.balls count]; i++) {
        Balloon  *ball=[self.balls objectAtIndex:i];
        ball.alpha=0;
        CALayer *layer= ball.layer;
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CGPoint targetCenter=CGPointMake(ball.center.x,self.view.bounds.size.height-BALL_RADIUS/2 );
        ball.animation = [self dockBounceAnimationWithIconHeight:150];
        ball.targetPoint=targetCenter;
        [ball.animation setDelegate:ball];
        ball.animation.beginTime = CACurrentMediaTime()+(0.1*i);
        [layer addAnimation:ball.animation forKey:@"position"];
        [CATransaction commit];
        [ball setCenter:targetCenter];
    }
}

-(void)resetwithBallCount:(int)ballCount
{
    selectedGameBallCount = ballCount;
    for (Balloon *ball in self.balls) {
        [ball stop];
        [ball blowingEnded];
        [ball removeFromSuperview];
    }
    [self.balls removeAllObjects];
    [self makeBalls];
}

- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight
{
    CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i=0; i<32; i++)
    {
        CGFloat positionOffset = factors[i]/128.0f * iconHeight;
        
        CATransform3D transform = CATransform3DMakeTranslation(0, -positionOffset, 0);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = 32.0f/30.0f;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion = YES;
    animation.autoreverses = NO;
    
    return animation;
}

-(void)blowStarted: (int)currentBallNo atSpeed:(int)speed{
    isaccelerating=YES;
    currentBall = currentBallNo;
    selectedSpeedSetting = speed;
    
    if (self.currentGameType == gameTypeTest || self.currentGameType == gameTypeImage){
        return;
    }
    
    timeCounter = 0;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        start = [NSDate date];
    }
}

-(void)blowEnded{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    isaccelerating=NO;
}

- (void)timerFired:(NSTimer *)timer{
    
    timeCounter += .01;
    NSTimeInterval timeElapsed = [start timeIntervalSinceNow];
    int percentageComplete = (fabs(timeElapsed)/selectedSpeedSetting)*100;
    Balloon  *ball=[self.balls objectAtIndex: currentBall];
    
    if (percentageComplete > 0 && percentageComplete < 12.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon1"];
    }else if (percentageComplete > 12.5 && percentageComplete < 25){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon2"];
    }else if (percentageComplete > 25 && percentageComplete < 37.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon3"];
    }else if(percentageComplete > 50 && percentageComplete < 62.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon4"];
    }else if(percentageComplete > 62.5 && percentageComplete < 75){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon5"];
    }else if(percentageComplete > 75 && percentageComplete < 87.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon6"];
    }else if(percentageComplete > 87.5 && percentageComplete < 100){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon7"];
    }else if(percentageComplete >= 100){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon8"];
    }
}

- (void) blowAttempt:(int)ballNo{
    Balloon  *ball=[self.balls objectAtIndex: currentBall];
    NSString* ballString = [NSString stringWithFormat:@"Balloon%d",ballNo];
    ball.currentBalloonImage.image = [UIImage imageNamed:ballString];
}

-(void)setAudioMute: (BOOL) muteSetting{
    
    NSLog(@"inner set mute %hhd", muteSetting);
    muteAudio = muteSetting;
}

@end
