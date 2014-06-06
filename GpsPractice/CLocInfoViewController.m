/*
//  CLocInfoViewController.m
//  GpsPractice
//
//  Created by jbehrbaum on 6/5/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/

#import <CoreLocation/CoreLocation.h>

#import "CLocInfoViewController.h"
#import "UtilsHelperFunctions.h"

@interface CLocInfoViewController ()

@end

@implementation CLocInfoViewController

@synthesize lblGreeting = _lblGreeting;
@synthesize locInfo = _locInfo;
@synthesize txtbxLatitude = _txtbxLatitude;
@synthesize txtbxLongitude = _txtbxLongitude;

-(void)setLocInfo:(CLLocation *)paramLocInfo
{
	if(paramLocInfo == nil)
		return;
	
	_locInfo = paramLocInfo;
	
	if(self.txtbxLatitude != nil)
		[self.txtbxLatitude setText:[NSString stringWithFormat:@"%.2lf", self.locInfo.coordinate.latitude]];
	
	if(self.txtbxLongitude != nil)
		[self.txtbxLongitude setText:[NSString stringWithFormat:@"%.2lf", self.locInfo.coordinate.longitude]];
	
	if( (self.lblGreeting != nil) && ([self.lblGreeting.text caseInsensitiveCompare:@"label"] == NSOrderedSame) )
	{
		NSString *strGreeting = [UtilsHelperFunctions retreiveLocalizedStringForKey:@"greeting"];
		
		if( (strGreeting != nil) && (strGreeting.length > 0) )
			[self.lblGreeting setText:strGreeting];
		else
			[self.lblGreeting setText:@"Hello"];
	}
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
	if(self) 
	{
        // Custom initialization
	}

	return self;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if(self.locInfo != nil)
	{
		[self.txtbxLatitude setText:[NSString stringWithFormat:@"%.2lf", self.locInfo.coordinate.latitude]];
		[self.txtbxLongitude setText:[NSString stringWithFormat:@"%.2lf", self.locInfo.coordinate.longitude]];
		
		if(self.lblGreeting != nil)
		{
			NSString *strGreeting = [UtilsHelperFunctions retreiveLocalizedStringForKey:@"greeting"];
			[self.lblGreeting setText:strGreeting];
		}
	}
}


-(void)viewDidUnload
{
	[self setTxtbxLatitude:nil];
	[self setTxtbxLongitude:nil];
    [self setLblGreeting:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)OnOK:(UIButton *)sender forEvent:(UIEvent *)event
{
	if(self.txtbxLatitude.isFirstResponder == TRUE)
		[self.txtbxLatitude resignFirstResponder];
	else if(self.txtbxLongitude.isFirstResponder == TRUE)
		[self.txtbxLongitude resignFirstResponder];
	
	NSLog(@"OnOK");

	
}

@end