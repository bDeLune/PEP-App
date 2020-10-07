@class Game;
@class User;
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef enum
{
    gameDifficultyEasy=1,
    gameDifficultMedium=2,
    gameDifficultyHard=3,
    gameDifficultyVeryHard
}gameDifficulty;

typedef enum
{
    hillTypeFlat=0,
    hillTypeHill=1,
    hillTypeMountain=2
}gameHillType;
extern NSString * const gameHillType_toString[];

typedef enum
{
    userTypeSignifigant=0,
    userTypeReduced=1,
    userTypeLittleReduced=2,
    userTypeNotReduced=3
}gameUserType;

extern NSString * const gameUserType_toString[];

@interface Globals : NSObject
+(Globals *)sharedInstance;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
-(Game*)gameForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype;
-(NSManagedObjectID*)gameIDForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype;
-(void)updateCoreData;
-(void)updateUser:(User*)user;
@end
