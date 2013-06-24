//  AGViewController.m
//
//  Generated by the the JBoss AeroGear Xcode Project Template on 6/17/13.
//  See Project's web site for more details http://www.aerogear.org
//

#import "AGMyLeadsViewController.h"
#import "AGLeadViewController.h"
#import "ProDoctorAPIClient.h"
#import "AGLead.h"

@implementation AGMyLeadsViewController {
    NSMutableArray *_leads;
    id<AGStore> _myStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AGDataManager *dm = [AGDataManager manager];
    _myStore = [dm store:^(id<AGStoreConfig> config) {
        [config setName:@"myLeads"];
        [config setType:@"PLIST"];
    }];
    [self displayLeads];
}

- (void) displayLeads {
    _leads = [[_myStore readAll] mutableCopy];
}

- (void) saveLead:(AGLead *)lead {
    NSError *error;
    NSDictionary *leadDict = [lead dictionary];
    if (![_myStore save:leadDict error:&error]) {
        ALog(@"Save: An error occured during save! \n%@", error);
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_leads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    AGLead *lead = [_leads objectAtIndex:row];
    cell.textLabel.text = lead.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    AGLead *lead = [_leads objectAtIndex:row];
    
    AGLeadViewController *leadController = [[AGLeadViewController alloc] init];
    leadController.lead = lead;
    leadController.hidesBottomBarWhenPushed = YES;
    
	[self.navigationController pushViewController:leadController animated:YES];
}


@end