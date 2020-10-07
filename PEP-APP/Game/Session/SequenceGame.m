#import "SequenceGame.h"
#import <AVFoundation/AVFoundation.h>

@interface SequenceGame()
{
    BOOL gamewon;
    AVAudioPlayer *audioPlayer;
    int muteAudio;
    int currentGameBallCount;
}
@end

@implementation SequenceGame

-(id)initWithBallCount: (int)ballCount
{
    if (self==[super init]) {
        self.currentBall=0;
        self.totalBalls= ballCount;
        self.totalBallsRaised=0;
        self.totalBallsAttempted=0;
        gamewon=NO;
        self.saveable=NO;
        self.halt=NO;
        self.time=0;
    }
    return self;
}

-(void)setBallCount: (float)ballCount{
    self.totalBalls = ballCount;
}

-(int)nextBall{
    
    self.halt=NO;
    self.currentBall++;
    self.totalBallsAttempted++;
    
        if (self.currentBall == self.totalBalls) {
            [self playVictorySound];
        }
    
        if (self.totalBallsRaised>=self.totalBalls) {
            if (!gamewon) {
                gamewon=YES;
                [self.delegate gameWon:self];

            }
            return -1;
        }
    if (!gamewon) {
        if (self.totalBallsAttempted>=self.totalBalls) {
            [self.delegate gameEnded:self];
            return -1;
        }
    }
    return self.currentBall;
}

-(void) playVictorySound {
    
    NSLog(@"Victory sound! muteaudio %d", muteAudio);
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"applauding" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume= 0.5;

        
        if (muteAudio == 1){
            NSLog(@"Victory AUDIO MUTED");
        }else{
            [audioPlayer play];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    @finally {
        
    }
}

-(void)setAudioMute: (int) muteSetting{
    
    NSLog(@"inner SEQUENCE set mute %d", muteSetting);
    muteAudio = muteSetting;
}

@end
