//  AGViewController.m
//
//  Generated by the the JBoss AeroGear Xcode Project Template on 6/17/13.
//  See Project's web site for more details http://www.aerogear.org
//

#import "AGMyLeadsViewController.h"
#import "AGLeadsViewController.h"
#import "AGLeadViewController.h"
#import "ProDoctorAPIClient.h"
#import "AGLead.h"
#import "LeadCell.h"

@implementation AGLeadsViewController

@synthesize leads = _leads;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // register to receive the notification
    // when a new lead is pushed
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(leadPushed:) name:@"LeadAddedNotification" object:nil];
    
    [self displayLeads];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // unregister our notification listener
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"LeadAddedNotification" object:nil];
}

- (void) displayLeads {
    [[ProDoctorAPIClient sharedInstance] fetchLeads:^(NSMutableArray *leads) {
        _leads = leads;
        [self.tableView reloadData];
    
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}


- (void) displayLeadsWithPush:(NSString *)pushedId {
    [[ProDoctorAPIClient sharedInstance] fetchLeads:^(NSMutableArray *leads) {
        _leads = leads;

        for(AGLead *currLead in leads) {
            if ([pushedId isEqual:currLead.name]) {
                currLead.isPushed = @1;
            }
                
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_leads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    LeadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = [indexPath row];
    AGLead *lead = [_leads objectAtIndex:row];
    
    if (cell == nil) {
        cell = [[LeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTableView:tableView andIndexPath:indexPath withImageDisplay:lead.isPushed];
    }
    [cell decorateCell:row inListCount:[self.leads count] with:lead.isPushed];
    
    cell.topLabel.text = [NSString stringWithFormat:@"%@.", lead.name];
    cell.bottomLabel.text = [NSString stringWithFormat:@"at: %@", lead.location];
	   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    AGLead *lead = [_leads objectAtIndex:row];
    
    AGLeadViewController *leadController = [[AGLeadViewController alloc] init];
    leadController.delegate = self;
    leadController.lead = lead;
    leadController.hidesBottomBarWhenPushed = YES;
    
	[self.navigationController pushViewController:leadController animated:YES];
}

- (void)didAccept:(AGLeadViewController *)controller lead:(AGLead *)lead {
    //------------------------------------------------------
    // Update lead
    //------------------------------------------------------
    [[ProDoctorAPIClient sharedInstance] postLead:lead success:^{
        // add it to the local store
        NSError *error = nil;
        if (![[ProDoctorAPIClient sharedInstance].localStore save:[lead dictionary] error:&error]) {
            DLog(@"Save: An error occured during save! \n%@", [error localizedDescription]);
        }
        
        [self remove:lead from:_leads];
        
        [self.tableView reloadData];
    
        } failure:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"An error has occured during save!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Bummer"
                                                  otherButtonTitles:nil];
            [alert show];
        }];

}

- (void)didDismiss:(AGLeadViewController *)controller lead:(AGLead *)lead {
    //TODO remove highlight
    //[self.tableView reloadData];
}

- (void) remove:(AGLead*)lead from:(NSMutableArray*)list {
    int i;
    for(i=0; i<[list count]; i++) {
        AGLead *currentLead = [list objectAtIndex:i];
        if(currentLead.recId == lead.recId) {
            [list removeObjectAtIndex:i];
            i--;
        }
    }
}

#pragma mark - Notification

- (void)leadPushed:(NSNotification *)notification {
    [self displayLeadsWithPush:notification.userInfo[@"name"]];
}

@end