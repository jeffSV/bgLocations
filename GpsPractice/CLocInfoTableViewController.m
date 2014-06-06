/*
//  CLocInfoTableViewController.m
//  GpsPractice
//
//  Created by jbehrbaum on 6/5/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/

#import "Defs.h"
#import "CLocInfoTableViewController.h"
#import "CLocInfoViewController.h"

@interface CLocInfoTableViewController ()
	@property(nonatomic, strong) CGpsLocInfo *locInfo;
	@property(nonatomic, strong) CLLocation *currLoc;

	-(void)configureDetailedViewWithLocationInfo:(CLocInfoViewController *)vc;
@end

@implementation CLocInfoTableViewController

@synthesize locInfo = _locInfo;
@synthesize currLoc = _currLoc;

-(CGpsLocInfo *)locInfo
{
	if(_locInfo == nil)
	{
		_locInfo = [[CGpsLocInfo alloc]init];
		_locInfo.updateDelegate = self;
	}
	
	return _locInfo;
}

-(id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
    
	if (self)
	{
       // Custom initialization
   }

	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
 
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	if([self.locInfo startTheGPS:FALSE promptForGpsStartOnFail:TRUE] == FALSE)
		NSLog(@"Failed to init the GPS");
}

-(void)viewDidUnload
{
	[super viewDidUnload];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return NUMBER_OF_POSITION_CATEGORIES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case RECENT_POSITION_INDEX:
			return [self.locInfo retreiveNumberOfRecentPositions];
		case FADING_POSITION_INDEX:
			return [self.locInfo retreiveNumberOfFadingPositions];
		case OUTDATED_POSITION_INDEX:
			return [self.locInfo retreiveNumberOfOutdatedPositions];
		default:
			break;
	}
	
	return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"gpsTableCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if(cell == nil)
		NSLog(@"WTF!!!");

	CLLocation *loc = nil;
	switch (indexPath.section)
	{
		case RECENT_POSITION_INDEX:
			loc = [self.locInfo retreiveLatestLocation];
			break;
		case FADING_POSITION_INDEX:
			loc = [self.locInfo retreiveLastFadingLocation];
			break;
		case OUTDATED_POSITION_INDEX:
			loc = [self.locInfo retreiveLastOutdatedLocation];
			break;
		default:
			break;
	}
	
	if(loc == nil)
		return cell;

	cell.textLabel.text = [NSString stringWithFormat:@"%.2lf - %.2lf", loc.coordinate.latitude, loc.coordinate.longitude];

	return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	CLocInfoViewController *vc = nil;

	if([segue.destinationViewController isKindOfClass:[CLocInfoViewController class]] == FALSE)
		return;
		
	switch ([[self tableView] indexPathForSelectedRow].section)
	{
		case RECENT_POSITION_INDEX:
			self.currLoc = [self.locInfo retreiveLatestLocationAtIndex:[[self tableView] indexPathForSelectedRow].row];
			break;
		case FADING_POSITION_INDEX:
			self.currLoc = [self.locInfo retreiveFadingLocationAtIndex:[[self tableView] indexPathForSelectedRow].row];
			break;
		case OUTDATED_POSITION_INDEX:
			self.currLoc = [self.locInfo retreiveOutdatedLocationAtIndex:[[self tableView] indexPathForSelectedRow].row];
			break;
		default:
			self.currLoc = nil;
			break;
	}
	
	vc = (CLocInfoViewController *)segue.destinationViewController;
	[self configureDetailedViewWithLocationInfo:vc];
}

-(void)receivedAGpsLocationUpdate
{
	[self.tableView reloadData];
}


-(void)configureDetailedViewWithLocationInfo:(CLocInfoViewController *)vc
{
		if(vc == nil)
		{
			for(UIViewController *vctrl in self.splitViewController.childViewControllers)
			{
				NSLog(@"%@", vctrl.class);
			}

			NSLog(@"%@", self.parentViewController.class);
			
			if(self.splitViewController != nil)
				NSLog(@"%@", self.splitViewController.class);
		}
		else
		{
			vc.locInfo = self.currLoc;
		}
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		return;

	[self configureDetailedViewWithLocationInfo:nil];
	
	switch (indexPath.section)
	{
		case RECENT_POSITION_INDEX:
			self.currLoc = [self.locInfo retreiveLatestLocationAtIndex:indexPath.row];
			break;
		case FADING_POSITION_INDEX:
			self.currLoc = [self.locInfo retreiveFadingLocationAtIndex:indexPath.row];
			break;
		case OUTDATED_POSITION_INDEX:
			self.currLoc = [self.locInfo retreiveOutdatedLocationAtIndex:indexPath.row];
			break;
		default:
			self.currLoc = nil;
			break;
	}
	
	if(self.splitViewController == nil)
		return;
	
	CLocInfoViewController *vc = [self.splitViewController.viewControllers objectAtIndex:1];
	vc.locInfo = self.currLoc;
}

@end
