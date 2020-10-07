#import "User.h"
#import "Game.h"

@implementation User
@dynamic userName;
@dynamic game;
@dynamic note;
@dynamic defaultDirection;
@dynamic defaultSpeed;
@dynamic defaultRepetitionIndex;
@dynamic defaultSound;
@dynamic defaultMute;
@dynamic defaultEffect;

- (void)addGameObject:(Game *)value{
    NSLog(@"ADDED GAME OBJECT");
}

@end
