/*
//  CGpsLocInfo.m
//  GpsPractice
//
//  Created by jbehrbaum on 6/5/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/

#import "CGpsLocInfo.h"

@interface CGpsLocInfo()
{
	BOOL bUsingSignificantChange;
}

@property(nonatomic, strong) CLLocationManager *locMgr;

@property(nonatomic, strong) NSMutableArray *arrRecentPositions;
@property(nonatomic, strong) NSMutableArray *arrFadingPositions;
@property(nonatomic, strong) NSMutableArray *arrOutdatedPositions;

-(BOOL)startStandardLocationServices;
-(BOOL)startSignificantChangeServices;

-(BOOL)addLocationToRecentPositions:(CLLocation *)loc;
-(BOOL)addLocationToFadingPositions:(CLLocation *)loc;
-(BOOL)addLocationToOutdatedPositions:(CLLocation *)loc;

@end

@implementation CGpsLocInfo

@synthesize locMgr = _locMgr;
@synthesize updateDelegate = _updateDelegate;
@synthesize arrRecentPositions = _arrRecentPositions;
@synthesize arrFadingPositions = _arrFadingPositions;
@synthesize arrOutdatedPositions = _arrOutdatedPositions;

-(CLLocationManager *)locMgr
{
	if(_locMgr == nil)
		_locMgr = [[CLLocationManager alloc]init];
	
	return _locMgr;
}

-(NSMutableArray *)arrRecentPositions
{
	if(_arrRecentPositions == nil)
		_arrRecentPositions = [[NSMutableArray alloc]init];

	return _arrRecentPositions;
}

-(NSMutableArray *)arrFadingPositions
{
	if(_arrFadingPositions == nil)
		_arrFadingPositions = [[NSMutableArray alloc]init];
	
	return _arrFadingPositions;
}

-(NSMutableArray *)arrOutdatedPositions
{
	if(_arrOutdatedPositions == nil)
		_arrOutdatedPositions = [[NSMutableArray alloc]init];
	
	return _arrOutdatedPositions;
}

+(int)retreiveRecentPositionsIndex
{return 0;}

+(int)retreiveFadingPositionsIndex
{return 1;}

+(int)retreiveOutdatedPositionsIndex
{return 2;}

+(int)retreiveNumberOfPositionCategories
{return 3;}

-(id)init
{
	self = [super init];
	
	if(self)
	{}

	return self;
}
#pragma mark - public interface

-(BOOL)stopTheGPS
{
	(bUsingSignificantChange == TRUE) ? [self.locMgr stopMonitoringSignificantLocationChanges] : [self.locMgr stopUpdatingLocation];
	return TRUE;
}

-(BOOL)startTheGPS:(BOOL)bUseSignificantChange promptForGpsStartOnFail:(BOOL)bStartIfDisabled
{
	if([CLLocationManager locationServicesEnabled] == FALSE)
	{
		if(bStartIfDisabled == FALSE)
			return FALSE;
	}

	self.locMgr.delegate = self;
	return (bUseSignificantChange == TRUE) ? [self startSignificantChangeServices] : [self startStandardLocationServices];	
}

-(int)retreiveNumberOfFadingPositions
{
	return self.arrFadingPositions.count;
}

-(int)retreiveNumberOfRecentPositions
{
	return self.arrRecentPositions.count;
}

-(int)retreiveNumberOfOutdatedPositions
{
	return self.arrOutdatedPositions.count;
}

-(CLLocation *)retreiveLatestLocation
{
	int iLastIndex = [self retreiveNumberOfRecentPositions];

	if(iLastIndex <= 0)
		return nil;
	
	return [self.arrRecentPositions objectAtIndex:iLastIndex - 1];
}

-(CLLocation *)retreiveLastFadingLocation
{
	int iLastIndex = [self retreiveNumberOfFadingPositions];
	
	if(iLastIndex <= 0)
		return nil;
	
	return [self.arrFadingPositions objectAtIndex:iLastIndex - 1];
}

-(CLLocation *)retreiveLastOutdatedLocation
{
	int iLastIndex = [self retreiveNumberOfOutdatedPositions];
	
	if(iLastIndex <= 0)
		return nil;
	
	return [self.arrOutdatedPositions objectAtIndex:iLastIndex - 1];
}

-(CLLocation *)retreiveLatestLocationAtIndex:(int)iIndex
{
	if( (iIndex < 0) || (iIndex >= self.arrRecentPositions.count) )
		return nil;
	
	return [self.arrRecentPositions objectAtIndex:iIndex];
}

-(CLLocation *)retreiveFadingLocationAtIndex:(int)iIndex
{
	if( (iIndex < 0) || (iIndex >= self.arrFadingPositions.count) )
		return nil;
	
	return [self.arrFadingPositions objectAtIndex:iIndex];

}

-(CLLocation *)retreiveOutdatedLocationAtIndex:(int)iIndex
{
	if( (iIndex < 0) || (iIndex >= self.arrOutdatedPositions.count) )
		return nil;
	
	return [self.arrOutdatedPositions objectAtIndex:iIndex];	
}

#pragma mark - private interface

-(BOOL)startStandardLocationServices
{
	bUsingSignificantChange = FALSE;

	self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
	self.locMgr.distanceFilter = 0.0;
	
	[self.locMgr startUpdatingLocation];
	
	return TRUE;
}

-(BOOL)startSignificantChangeServices
{
	bUsingSignificantChange = TRUE;

	[self.locMgr startMonitoringSignificantLocationChanges];

	return TRUE;
}

#pragma mark - the location delegate callbacks

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if( ([self addLocationToRecentPositions:newLocation] == TRUE) && (self.updateDelegate != nil) )
		[self.updateDelegate receivedAGpsLocationUpdate];
	else
		NSLog(@"Faile to insert new position");
}

#pragma mark - interface called from gps update callbacks
-(BOOL)addLocationToRecentPositions:(CLLocation *)loc
{
	if(loc == nil)
		return FALSE;
	
	BOOL bRetStat = TRUE;

	@try
	{
		[self.arrRecentPositions addObject:loc];	
	}
	@catch (NSException *exception)
	{
		bRetStat = FALSE;
	}
	@finally 
	{}

	return TRUE;	
}

-(BOOL)addLocationToFadingPositions:(CLLocation *)loc
{
	if(loc == nil)
		return FALSE;
	
	BOOL bRetStat = TRUE;
	
	@try
	{
		[self.arrFadingPositions addObject:loc];	
	}
	@catch (NSException *exception)
	{
		bRetStat = FALSE;
	}
	@finally 
	{}

	
	return TRUE;	
}

-(BOOL)addLocationToOutdatedPositions:(CLLocation *)loc
{
	if(loc == nil)
		return FALSE;
	
	BOOL bRetStat = TRUE;
	
	@try
	{
		[self.arrOutdatedPositions addObject:loc];	
	}
	@catch (NSException *exception)
	{
		bRetStat = FALSE;
	}
	@finally 
	{}

	return TRUE;	
}

@end