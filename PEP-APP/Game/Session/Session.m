#import "Session.h"

@implementation Session

-(id)init
{
    self=[super init];
    
    if (self) {
        _sessionDate=[NSDate date];
        _sessionStrength=[NSNumber numberWithFloat:0.0];
        _sessionDuration= [NSString stringWithFormat:@"%g", 0.0];
        _sessionSpeed=[NSNumber numberWithFloat:0.0];
        _sessionType=[NSNumber numberWithInt:0];
        _sessionBreathDirection=[NSNumber numberWithInt:0];
    }
    
    return self;
}

-(void)updateStrength:(float)pvalue
{
    if (pvalue>[_sessionStrength floatValue]) {
        _sessionStrength=[NSNumber numberWithFloat:pvalue];
    }
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_sessionDate forKey:@"sessionDate"];
    [encoder encodeObject:_sessionDuration forKey:@"sessionDuration"];
    [encoder encodeObject:_sessionStrength forKey:@"sessionStrength"];
    [encoder encodeObject:_sessionSpeed forKey:@"sessionSpeed"];
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_sessionType forKey:@"sessionType"];
    [encoder encodeObject:_sessionBreathDirection forKey:@"sessionDirection"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.sessionDate = [decoder decodeObjectForKey:@"sessionDate"];
    self.sessionStrength = [decoder decodeObjectForKey:@"sessionStrength"];
    self.username = [decoder decodeObjectForKey:@"username"];
    self.sessionDuration = [decoder decodeObjectForKey:@"sessionDuration"];
    self.sessionSpeed=[decoder decodeObjectForKey:@"sessionSpeed"];
    self.sessionType=[decoder decodeObjectForKey:@"sessionType"];
    self.sessionBreathDirection=[decoder decodeObjectForKey:@"sessionDirection"];
    return self;
}

@end
