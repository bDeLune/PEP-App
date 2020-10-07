#import "AllGamesForDayTableVC.h"
#import "Game.h"
#import "HeaderView.h"

@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
}

@property (nonatomic,strong)UIButton  *backButton;
@end

@implementation AllGamesForDayTableVC

-(void)setUSerData:(NSArray*)games
{
    NSMutableArray* myDateArray;
    int count = [games count];
    
    for (int i = 1; i < count; i++){
        Game  *game= [games objectAtIndex:i];
        NSDate  *date=game.gameDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm:ss"];
        [myDateArray addObject:date];
    }
    
    data = [games sortedArrayUsingComparator: ^NSComparisonResult(Game *c1, Game *c2)
    {
        NSDate *d1 = c2.gameDate;
        NSDate *d2 = c1.gameDate;
        return [d1 compare:d2];
    }];

    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    UIImage *image = [UIImage imageNamed: @"User-Project.png"];
    [self.backgroundColouredImage setImage:image];
    [self.view addSubview:self.backgroundColouredImage];
    [self.view bringSubviewToFront:self.backgroundColouredImage];
    [self.backgroundColouredImage sendSubviewToBack:self.view];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:237/255.0f alpha:1.0f] ;
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:237/255.0f alpha:1.0f] ;
}

- (void)viewWillDisappear:(BOOL)animated{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
}

- (IBAction)tapGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint tapLocation = [gesture locationInView: self.view];
    for (UIImageView *imageView in self.view.subviews) {
        if (CGRectContainsPoint(imageView.frame, tapLocation)) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.view removeFromSuperview];
        }
    }
}

- (void)goBack:(UIButton *)sender  {
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Game  *game= [data objectAtIndex:indexPath.row];
    NSDate  *date=game.gameDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
    int gameType=[game.gameType intValue];
    
    NSString  *typeString;
    if (gameType==0) {
        typeString=@"Balloon Game";
    }else if (gameType==1)
    {
        typeString=@"Image Game";
    }else if (gameType==2)
    {
        typeString=@"Duo Game";
    }
    
    NSString* durationString;
    NSString* powerString;
    
    if ([game.power intValue] == 0){
        powerString = @"0";
    }else{
        float number =  [game.power floatValue];
        float x = (int)(number * 10000) / 10000.0;
        powerString = [NSString stringWithFormat:@"%.2f", x];
    }
    
    @try{
        durationString= [[NSString stringWithFormat: @"%@", game.duration] substringToIndex:4];
    }@catch(NSException *exception){
         durationString= @"0" ;
    }
    
    cell.textLabel.text=[NSString stringWithFormat:@"%@   %@",typeString,attemptDateString];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    
    cell.detailTextLabel.numberOfLines = 5;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Strength: %@ \nDuration: %@ \nDirection: %@ \nSpeed: %@" ,powerString, durationString, game.gameDirection, game.speed];
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView  *header=[[HeaderView alloc]initWithFrame:CGRectMake(0, 100, 670, 0)];
    header.section=section;
    [header build];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.backButton addGestureRecognizer:tap];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

@end
