#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;
@class Note;
@interface User : NSManagedObject
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *game;
@property (nonatomic, retain) NSSet *note;
@property (nonatomic, retain) NSString * defaultDirection;
@property (nonatomic, retain) NSNumber * defaultSpeed;
@property (nonatomic, retain) NSNumber * defaultRepetitionIndex;
@property (nonatomic, retain) NSString * defaultSound;
@property (nonatomic, retain) NSNumber * defaultMute;
@property (nonatomic, retain) NSNumber * defaultEffect;
@end

@interface User (CoreDataGeneratedAccessors)
- (void)addGameObject:(Game *)value;
- (void)removeGameObject:(Game *)value;
- (void)addGame:(NSSet *)values;
- (void)removeGame:(NSSet *)values;
@end
