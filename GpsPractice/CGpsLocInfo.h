/*
//  CGpsLocInfo.h
//  GpsPractice
//
//  Created by jbehrbaum on 6/5/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol locationUpdatesProcessed <NSObject>
@required
	-(void)receivedAGpsLocationUpdate;

@end

@interface CGpsLocInfo : NSObject<CLLocationManagerDelegate>

@property(nonatomic, weak) id<locationUpdatesProcessed> updateDelegate;

+(int)retreiveRecentPositionsIndex;
+(int)retreiveFadingPositionsIndex;
+(int)retreiveOutdatedPositionsIndex;
+(int)retreiveNumberOfPositionCategories;

-(BOOL)stopTheGPS;
-(BOOL)startTheGPS:(BOOL)bUseSignificantChange promptForGpsStartOnFail:(BOOL)bStartIfDisabled;

-(int)retreiveNumberOfFadingPositions;
-(int)retreiveNumberOfRecentPositions;
-(int)retreiveNumberOfOutdatedPositions;

-(CLLocation *)retreiveLatestLocation;
-(CLLocation *)retreiveLastFadingLocation;
-(CLLocation *)retreiveLastOutdatedLocation;

-(CLLocation *)retreiveLatestLocationAtIndex:(int)iIndex;
-(CLLocation *)retreiveFadingLocationAtIndex:(int)iIndex;
-(CLLocation *)retreiveOutdatedLocationAtIndex:(int)iIndex;

@end