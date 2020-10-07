#import "InfoViewController.h"

@interface InfoViewController ()
@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.infoViewBackgroundImage setImage: [UIImage imageNamed:NSLocalizedString(@"InfoBackground", nil)]];
    [self.externalURLButton setImage: [UIImage imageNamed:NSLocalizedString(@"externalURLButton", nil)]forState:UIControlStateNormal];
}

- (IBAction)goToWebsite:(id)sender {
    NSLog(@"Moving to website");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:NSLocalizedString(@"manualURL", nil)]]];
}

@end
