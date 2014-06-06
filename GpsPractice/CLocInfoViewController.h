/*
//  CLocInfoViewController.h
//  GpsPractice
//
//  Created by jbehrbaum on 6/5/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class CLLocation;

@interface CLocInfoViewController : UIViewController

@property (weak, nonatomic) CLLocation *locInfo;

@property (weak, nonatomic) IBOutlet UITextField *txtbxLatitude;
@property (weak, nonatomic) IBOutlet UITextField *txtbxLongitude;

-(IBAction)OnOK:(UIButton *)sender forEvent:(UIEvent *)event;

@end
