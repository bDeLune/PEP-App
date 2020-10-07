#import <UIKit/UIKit.h>
#import "User.h"
@class HeaderView;
@protocol HeaderViewProtocl<NSObject>
-(void)deleteMember:(HeaderView*)header;
-(void)viewHistoricalData:(HeaderView*)header;
@end
@interface HeaderView : UIView
@property NSManagedObjectID  *mmoid;
@property int section;
@property(nonatomic,unsafe_unretained)id<HeaderViewProtocl>delegate;
@property(nonatomic,weak)User  *user;
-(void)build;
@end
