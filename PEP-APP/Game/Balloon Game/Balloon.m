#import "Balloon.h"
#import "GCDQueue.h"

@interface Balloon()
{
    float velocity;
    float distance;
    float time;
    float acceleration;
    BOOL  isaccelerating;
    float force;
    float mass;
    CADisplayLink *displayLink;
    NSDate *start;
    float currentYPosition;
    int timeCounter;
    NSTimer *timer;
    int selectedSpeed;
    BOOL allowBalloonAnimation;
}
@end

@implementation Balloon

-(void)setMass:(float)value
{
    mass=value;
}

-(void)setDefaults
{
    velocity=0.0;
    distance=0.1;
    time=0.1;
    acceleration=0.1;
    isaccelerating=NO;
    mass=1;
    force=15;
    [self addObserver:self forKeyPath:@"currentYPosition" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"currentYPosition"]) {
        
        if (currentYPosition<=self.bounds.size.width/2) {
            [self.delegate balloonReachedFinalTarget:self];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)setForce:(float)pforce
{
    force=(pforce/mass);
}

-(void)blowingBegan
{
    isaccelerating=YES;
    timeCounter = 0;
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(timekeeper) userInfo:nil repeats:YES];
}

-(void) setSpeed:(int)speed allowAnimate:(BOOL)allow{
    allowBalloonAnimation = allow;
    selectedSpeed = speed;
}

- (void)timekeeper{
    timeCounter += .5;
    int selectedSpeedSetting = selectedSpeed;
    int percentageComplete = (timeCounter/selectedSpeedSetting)*100;
    
    if (percentageComplete > 0 && percentageComplete < 12.5){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon1"];
    }else if (percentageComplete > 12.5 && percentageComplete < 25){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon2"];
    }else if (percentageComplete > 25 && percentageComplete < 37.5){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon3"];
    }else if(percentageComplete > 50 && percentageComplete < 62.5){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon4"];
    }else if(percentageComplete > 62.5 && percentageComplete < 75){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon5"];
    }else if(percentageComplete > 75 && percentageComplete < 87.5){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon6"];
    }else if(percentageComplete > 87.5 && percentageComplete < 100){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon7"];
    }else if(percentageComplete == 100){
         self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon8"];
    }
}

-(void)blowingEnded
{
    [timer invalidate];
    isaccelerating=NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        [self setDefaults];
        currentYPosition=frame.origin.y;
        self.currentBalloonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
        self.currentBalloonImage.image = [UIImage imageNamed:@"Balloon0"];
        [self addSubview:self.currentBalloonImage];
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self setCenter:self.targetPoint];
}

-(void)animationDidStart:(CAAnimation *)ani
{
    self.alpha=1.0;
}

-(void)stop
{
    CGRect frame=self.frame;
    frame.origin.y=0;
    self.frame=frame;
    [self setNeedsDisplay];
    if (_animationRunning) {
        [displayLink invalidate];
        _animationRunning=NO;
        [[GCDQueue mainQueue]queueBlock:^{
            [self.delegate balloonReachedFinalTarget:self];
        } afterDelay:0.1];
    }
}

-(void)start
{
    [self setDefaults];
    if (!_animationRunning)
    {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animateForPower)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _animationRunning = YES;
    }
}

-(void)animateForPower
{
    if (isaccelerating) {
    }else
    {
        force-=force*0.03;
        acceleration-=acceleration*0.03;
    }
    
    if (force<1) {
        force=1;
    }
    
    acceleration= acceleration +( force/mass);
    velocity = distance / time;
    time = distance / velocity;
    
    distance= ceilf((0.5)* (acceleration * powf(time, 2)));
    CGRect frame=self.frame;
    
    if (frame.origin.y>self.bounds.size.height/2) {
        frame.origin.y=(self.gaugeHeight-self.bounds.size.height) -distance;
        
        [self setFrame:frame];
    }else
    {
        frame.origin.y=0;
        self.frame=frame;
        [self setNeedsDisplay];
        [self stop];
    }
}
@end
