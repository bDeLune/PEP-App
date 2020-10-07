#import <UIKit/UIKit.h>

@interface AllGamesForDayTableVC : UITableViewController
-(void)setUSerData:(NSArray*)games;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundColouredImage;
@end
