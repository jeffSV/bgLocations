//
//  UtilsHelperFunctions.m
//  GpsPractice
//
//  Created by jbehrbaum on 6/6/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

//#import "Defs.h"
#import "UtilsHelperFunctions.h"

@implementation UtilsHelperFunctions

+(NSString *)retreiveLocalizedStringForKey:(NSString *)strKey
{	
	NSString *strLocalizedValue;

	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [defs objectForKey:@"AppleLanguages"];
	NSString *currentLangAbbreviation = [languages objectAtIndex:0];

	NSString *path = [[ NSBundle mainBundle ] pathForResource:currentLangAbbreviation ofType:@"lproj" ];
	
//	if(path == nil)
//		return [NSString stringWithFormat:@"%s", DEFAULT_GREETING];
	//[[NSUserDefaults standardUserDefaults] synchronize];

	NSBundle *localizedBundle = [NSBundle bundleWithPath:path];
	if(localizedBundle != nil)
	{
		strLocalizedValue = [localizedBundle objectForInfoDictionaryKey:strKey];
	}//End
	
	return strLocalizedValue;
}//End


@end
