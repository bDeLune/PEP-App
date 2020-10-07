#import "SettingsViewGauge.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewGauge ()
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
    UIView *animationObject;
    float bestDistance;
    bool setToInhale;
    bool currentlyExhaling;
    bool userBreathingCorrectly;
}

@end

@implementation SettingsViewGauge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animate)];
        [displayLink setFrameInterval:8];
        
        start=[NSDate date];
        animationObject=[[UIView alloc]initWithFrame:self.bounds];
        
        UIColor* customColour = RGB(00, 33, 66);
        [animationObject setBackgroundColor:customColour];
        animationObject.layer.cornerRadius=16;
        [self addSubview:animationObject];
        [self sendSubviewToBack:animationObject];
        isaccelerating=false;
        self.backgroundColor=[UIColor clearColor];
        self.layer.cornerRadius=16;
        mass=1;
        force=15;
    }
    return self;
}

-(void)setMass:(float)value
{
    mass=value;
}

-(void)setDefaults
{
    velocity=0.0;
    distance=0.01;
    bestDistance=0;
    isaccelerating=NO;
    distance=0.01;
    time=0.01;
    acceleration=0.01;
}

-(void)setBestDistanceWithY:(float)yValue
{
    bestDistance= yValue;
}

-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;{
    
    currentlyExhaling = value2;
    setToInhale = value;
    
    if ((currentlyExhaling == 1 && setToInhale == 0) || (currentlyExhaling == 0 && setToInhale == 1)){
        userBreathingCorrectly = true;
    }else{
        userBreathingCorrectly = false;
        isaccelerating=NO;
    }
}

-(void)setForce:(float)pforce
{
    NSLog(@"Settings gauge setForce %f", pforce);
    force=(pforce/mass);
}

-(void)blowingBegan
{
    NSLog(@"Settings gauge blow started");
    isaccelerating=YES;
}

-(void)blowingEnded
{
    NSLog(@"Settings gauge blow ended");
    isaccelerating=NO;
}

-(void)animate
{
    time=0.2;
    
    if (isaccelerating) {

    }else
    {
        force -= force*0.1;
        acceleration -= acceleration*0.1;
    }
    
    if (force<1) {
        force=1;
    }
    
  //  NSLog(@"distance %f", distance);
   // NSLog(@"isaccelerating %hhd", isaccelerating);

    acceleration = 35.73 * force; //13.4
    velocity = distance / time;
    time = distance / velocity;
    distance = ceilf((0.1) * (acceleration * powf(time, 2)));
    
    CGRect frame=animationObject.frame;
    frame.origin.y=self.bounds.size.height-distance;
    frame.size.height= distance;
    [animationObject setFrame:frame];
    [self setNeedsDisplay];
    
    if (distance>bestDistance) {
        bestDistance=distance;
    }
    
    [animationObject setFrame:frame];
    [self setNeedsDisplay];
    
}

-(void)stop
{
    NSLog(@"stopping");
     if (_animationRunning) {
         [displayLink invalidate];
         _animationRunning=NO;
     }
}

-(void)start
{
    [self setDefaults];
    if (!_animationRunning)
    {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animate)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _animationRunning = YES;
    }
}
@end
