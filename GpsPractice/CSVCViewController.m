/*
//  CSVCViewController.m
//  GpsPractice
//
//  Created by jbehrbaum on 6/5/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/

#import "CSVCViewController.h"

@interface CSVCViewController()

@end


@implementation CSVCViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		// Custom initialization
		self.delegate = self;
	}

	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view.
}

-(void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - delegate calls



@end