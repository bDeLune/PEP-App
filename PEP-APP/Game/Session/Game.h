#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@interface Game : NSManagedObject
@property (nonatomic, retain) NSNumber * gameType;
@property (nonatomic, retain) NSDate   * gameDate;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSString * gameDirection;
@end
