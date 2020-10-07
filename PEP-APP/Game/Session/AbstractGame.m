#import "AbstractGame.h"

@implementation AbstractGame
-(void)startGame
{
    [self.delegate gameStarted:self];
}
-(void)endGame
{
    [self.delegate gameEnded:self];
}
-(void)startTimer
{
    if (timer) {
        return;
    }
    startdate=[NSDate date];
    dispatch_async(dispatch_get_main_queue(), ^{
        timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    });
}
-(void)timerTick:(NSTimer*)timer
{
    NSTimeInterval timeInterval = [startdate timeIntervalSinceNow];
    self.time = fabs(timeInterval);
}

-(void)killTimer
{
    if (!timer) {
        return;
    }
    [timer invalidate];
    timer=nil;
}

@end
