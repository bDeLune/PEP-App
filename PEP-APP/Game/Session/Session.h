#import <Foundation/Foundation.h>

@interface Session : NSObject<NSCoding>
@property(nonatomic,strong)NSNumber  *sessionStrength;
@property(nonatomic,strong)NSString  *sessionDuration;
@property(nonatomic,strong)NSNumber  *sessionSpeed;
@property(nonatomic,strong)NSNumber  *sessionType;
@property(nonatomic,strong)NSNumber  *sessionBreathDirection;
@property(nonatomic,strong)NSDate    *sessionDate;
@property(nonatomic,strong)NSString  *username;
-(void)updateStrength:(float)pvalue;
@end
