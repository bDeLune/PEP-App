#import "GameViewGauge.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewGauge ()
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
    UIView  *animationObject;
    float bestDistance;
    bool setToInhale;
    bool currentlyExhaling;
    bool userBreathingCorrectly;
}

@end
@implementation GameViewGauge

-(void)setMass:(float)value
{
    mass=value;
}

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
        
        isaccelerating=false;
        self.backgroundColor=[UIColor clearColor];
        self.layer.cornerRadius=16;
        
        mass=.3;
        force=15;
    }
    return self;
}

-(void)setDefaults
{
    velocity=0.0;
    distance=0.01;
    time=0.01;
    acceleration=0.01;
    bestDistance=0;
    isaccelerating=NO;
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
    force=(pforce/mass);
}

-(void)blowingBegan
{
    isaccelerating=YES;
}

-(void)blowingEnded
{
        NSLog(@"game gauge blow ended");
    isaccelerating=NO;
}

-(void)animate
{
    time=0.2;
    
    if (isaccelerating) {
        // force+=500;
    }else
    {
        force-=force*0.1;
        acceleration-=acceleration*0.1;  //.03
        
        //force-=force*0.03;
       // acceleration-=acceleration*0.03;
        
    }
    
    if (force<1) {
        force=1;
    }
    
    //acceleration= acceleration +( force/mass);
   // velocity = distance / time;
    //time = distance / velocity;
   // distance= ceilf((0.5)* (acceleration * powf(time, 2)));
    
    acceleration = 50.1*  force; //was 1.95.01
    velocity = distance / time;
    time = distance / velocity;
    distance = ceilf((0.01)* (acceleration * powf(time, 2)));//.1
    
   // NSLog(@"game distance %f", force);
    
   // if (distance > MAINGUAGE_HEIGHT){ //15750
    //    distance = MAINGUAGE_HEIGHT;
   // }

    CGRect frame=animationObject.frame;
    frame.origin.x=0;
    frame.size.height=90;
    frame.size.width=distance;
    
   // if (distance>bestDistance) {
   //     bestDistance=distance;
    //}

    [animationObject setFrame:frame];
    [self setNeedsDisplay];
}

-(void)stop
{
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
