#import "HeaderView.h"
@interface HeaderView ()
@property (nonatomic,strong)UILabel  *label;
@property (nonatomic,strong)UIButton  *deleteButton;
@property (nonatomic,strong)UILabel  *currentUserLabel;
@property (nonatomic,strong)UIButton  *dataButton;
@end

@implementation HeaderView

-(void)build
{
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(30,30, 500, self.bounds.size.height)];
    [self.label setText:self.user.userName];
    [self addSubview:self.label];
    NSString *currentUser=[[NSUserDefaults standardUserDefaults]objectForKey:@"currentUser"];
    
    if ([currentUser isEqualToString:self.user.userName]){
        self.currentUserLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-100, 30, 100, self.bounds.size.height)];
        [self.currentUserLabel setText:@"Current User"];
        [self.currentUserLabel setTextColor:[UIColor blackColor]];
        [self.currentUserLabel setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)]];
        [self addSubview:self.currentUserLabel];
    }else{
        self.deleteButton=[UIButton buttonWithType:UIButtonTypeSystem];
        self.deleteButton.frame=CGRectMake(self.bounds.size.width-125, 30, 100, self.bounds.size.height);
        [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [self.deleteButton.titleLabel setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)]];
        [self.deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self addSubview:self.deleteButton];
    }
    
}

-(void)viewHistoricalData
{
    [self.delegate viewHistoricalData:self];
}
-(void)deleteAction
{
    [self.delegate deleteMember:self];
}

@end
