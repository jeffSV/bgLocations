/*
|  CSecurityManager.m
|  GpsPractice
|
|  Created by jbehrbaum on 6/9/14.
|  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
|
|  In iOS Keychain Services, certificates, keys, and identities are stored 
|  and retrieved in exactly the same way as passwords, except that they have 
|  different attributes.
*/


#import <Security/Security.h>

#import "CSecurityManager.h"

//Unique string used to identify the keychain item:
static const UInt8 strArrKeychainItemIdentifier[] = "com.foo.fooAppKeychainEntry\0";

@interface CSecurityManager()
	@property(nonatomic, strong) NSMutableDictionary *keychainItemData;
	@property(nonatomic, strong) NSMutableDictionary *dictGenericPasswordQuery;

	-(void)writeToKeychain;
	-(void)resetKeychainItem;
	-(NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
@end

@implementation CSecurityManager

@synthesize keychainItemData = _keychainItemData;
@synthesize dictGenericPasswordQuery = _dictGenericPasswordQuery;

-(NSMutableDictionary *)keychainItemData
{
	if(_keychainItemData == nil)
		_keychainItemData = [[NSMutableDictionary alloc]init];
	
	return _keychainItemData;
}

-(NSMutableDictionary *)dictGenericPasswordQuery
{
	if(_dictGenericPasswordQuery == nil)
	{
		_dictGenericPasswordQuery = [[NSMutableDictionary alloc]init];
		
		// This keychain item is a generic password.
		[_dictGenericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
		
		// The kSecAttrGeneric attribute is used to store a unique string that is used
		// to easily identify and find this keychain item. The string is first
		// converted to an NSData object:
		NSData *keychainItemID = [NSData dataWithBytes:strArrKeychainItemIdentifier length:strlen((const char *)strArrKeychainItemIdentifier)];
		
		[_dictGenericPasswordQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];

		// Return the attributes of the first match only:
		[_dictGenericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
		
		// Return the attributes of the keychain item (the password is
		//  acquired in the secItemFormatToDictionary: method):
		[_dictGenericPasswordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
	}

	return _dictGenericPasswordQuery;
}

-(void)addToKeyChain
{
	NSData *passData = nil;
	CFDataRef pwAttributes = nil;

	NSMutableDictionary *dictPasswordInfo = [[NSMutableDictionary alloc]init];
	
	OSStatus eSecStatAdd = SecItemAdd((__bridge CFDictionaryRef)dictPasswordInfo, (CFTypeRef *)&pwAttributes);

	switch (eSecStatAdd)
	{
		case errSecSuccess://0
			NSLog(@"No Error");
			break;
		case errSecUnimplemented://-4
			NSLog(@"Function or operation not implemented.");
			break;
		case errSecParam://-50
			NSLog(@"One or more parameters passed to the function were not valid.");
			break;
		case errSecAllocate://-108
			NSLog(@"Failed to allocate memory.");
			break;
		case errSecNotAvailable://–25291
			NSLog(@"No trust results are available.");
			break;
		case errSecAuthFailed://–25293
			NSLog(@"Authorization/Authentication failed.");
			break;
		case errSecDuplicateItem://–25299
			NSLog(@"The item already exists.");
			break;
		case errSecItemNotFound://–25300
			NSLog(@"The item cannot be found.");
			break;
		case errSecInteractionNotAllowed://–25308
			NSLog(@"Interaction with the Security Server is not allowed.");
			break;
		case errSecDecode://-26275
			NSLog(@"Unable to decode the provided data.");
			break;
		default:
			break;
	}
}

-(BOOL)findInKeyChain
{	
	CFMutableDictionaryRef dictPwMatchingAttributes = nil;

	OSStatus eFindStat = SecItemCopyMatching((__bridge CFDictionaryRef)self.dictGenericPasswordQuery, (CFTypeRef *)&dictPwMatchingAttributes);

	BOOL bRetStat = FALSE;
	switch (eFindStat)
	{
		case errSecSuccess://0
		{
			NSLog(@"No Error");
			bRetStat = TRUE;

			// Create a return dictionary populated with the attributes:
			NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSMutableDictionary *)dictPwMatchingAttributes];
			
			// To acquire the password data from the keychain item,
			// first add the search key and class attribute required to obtain the password:
			[returnDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
			[returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

			// Then call Keychain Services to get the password:
			CFDataRef passwordData = NULL;
			OSStatus keychainError = noErr; //
			keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData);
			if (keychainError == noErr)
			{
				// Remove the kSecReturnData key; we don't need it anymore:
				[returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
				
				// Convert the password to an NSString and add it to the return dictionary:
				NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)passwordData bytes] length:[(__bridge NSData *)passwordData length] encoding:NSUTF8StringEncoding];
				[returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
			}
			// Don't do anything if nothing is found.
			else if (keychainError == errSecItemNotFound) 
			{
            NSAssert(NO, @"Nothing was found in the keychain.\n");
            if (passwordData) 
					CFRelease(passwordData);
			}
			// Any other error is unexpected.
			else
			{
				NSAssert(NO, @"Serious error.\n");
				if (passwordData) 
					CFRelease(passwordData);
			}
			
			self.keychainItemData = returnDictionary;
		}
			break;
		case errSecUnimplemented://-4
			NSLog(@"Function or operation not implemented.");
			break;
		case errSecParam://-50
			NSLog(@"One or more parameters passed to the function were not valid.");
			break;
		case errSecAllocate://-108
			NSLog(@"Failed to allocate memory.");
			break;
		case errSecNotAvailable://–25291
			NSLog(@"No trust results are available.");
			break;
		case errSecAuthFailed://–25293
			NSLog(@"Authorization/Authentication failed.");
			break;
		case errSecDuplicateItem://–25299
			NSLog(@"The item already exists.");
			break;
		case errSecItemNotFound://–25300
			NSLog(@"The item cannot be found.");
			[self resetKeychainItem];
			break;
		case errSecInteractionNotAllowed://–25308
			NSLog(@"Interaction with the Security Server is not allowed.");
			break;
		case errSecDecode://-26275
			NSLog(@"Unable to decode the provided data.");
			break;
		default:
			break;
	}

	return bRetStat;
}

-(void)resetKeychainItem
{
	if(self.keychainItemData.count > 0)
	{
		// Format the data in the keychainData dictionary into the format needed for a query
		//  and put it into tmpDictionary:
		NSMutableDictionary *tmpDictionary = [self dictionaryToSecItemFormat:self.keychainItemData];

		// Delete the keychain item in preparation for resetting the values:
		OSStatus errorcode = SecItemDelete((__bridge CFDictionaryRef)tmpDictionary);
		NSAssert(errorcode == noErr, @"Problem deleting current keychain item." );
	}

	// Default generic data for Keychain Item:
	[self.keychainItemData setObject:@"Item label" forKey:(__bridge id)kSecAttrLabel];
	[self.keychainItemData setObject:@"Item description" forKey:(__bridge id)kSecAttrDescription];
	[self.keychainItemData setObject:@"Account" forKey:(__bridge id)kSecAttrAccount];
	[self.keychainItemData setObject:@"Service" forKey:(__bridge id)kSecAttrService];
	[self.keychainItemData setObject:@"Your comment here." forKey:(__bridge id)kSecAttrComment];
	[self.keychainItemData setObject:@"password" forKey:(__bridge id)kSecValueData];
}

-(void)writeToKeychain
{
	CFDictionaryRef attributes = nil;
	NSMutableDictionary *updateItem = nil;
	
	// If the keychain item already exists, modify it:
	if (SecItemCopyMatching((__bridge CFDictionaryRef)self.dictGenericPasswordQuery, (CFTypeRef *)&attributes) == noErr)
	{
		// First, get the attributes returned from the keychain and add them to the
		// dictionary that controls the update:
		updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)attributes];
		
		// Second, get the class value from the generic password query dictionary and
		// add it to the updateItem dictionary:
		[updateItem setObject:[self.dictGenericPasswordQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
		
		// Finally, set up the dictionary that contains new values for the attributes:
		NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:self.keychainItemData];

		//Remove the class--it's not a keychain attribute:
		[tempCheck removeObjectForKey:(__bridge id)kSecClass];
		
		// You can update only a single keychain item at a time.
		OSStatus errorcode = SecItemUpdate(
													  (__bridge CFDictionaryRef)updateItem,
													  (__bridge CFDictionaryRef)tempCheck);

		NSAssert(errorcode == noErr, @"Couldn't update the Keychain Item." );
	}
	else
	{
		// No previous item found; add the new item.
		// The new value was added to the keychainData dictionary in the mySetObject routine,
		// and the other values were added to the keychainData dictionary previously.
		// No pointer to the newly-added items is needed, so pass NULL for the second parameter:
		OSStatus errorcode = SecItemAdd(
												  (__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:self.keychainItemData],
												  NULL);

		NSAssert(errorcode == noErr, @"Couldn't add the Keychain Item." );

		if (attributes)
			CFRelease(attributes);
	}
}

-(BOOL)retreivePasswordAttributes:(NSDictionary **)dictAttributes
{	
	// Set up the keychain search dictionary:
	NSMutableDictionary *genericPasswordQuery = [[NSMutableDictionary alloc] init];
	
	NSString *strIdentifier = [NSString stringWithFormat:@"%@", @"Password"];

	// This keychain item is a generic password.
	[genericPasswordQuery setObject:(__bridge_transfer id)kSecClassGenericPassword forKey:(__bridge_transfer id)kSecClass];
	[genericPasswordQuery setObject:strIdentifier forKey:(__bridge_transfer id)kSecAttrGeneric];
	
	// Use the proper search constants, return only the attributes of the first match.
	[genericPasswordQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
	[genericPasswordQuery setObject:(__bridge_transfer id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnAttributes];

	NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:genericPasswordQuery];
	
//	NSMutableDictionary *outDictionary = nil;
	CFDataRef attributes;
	OSStatus eSecStatRetreive = SecItemCopyMatching((__bridge_retained  CFDictionaryRef)tempQuery, (CFTypeRef *)&attributes);//What we're looking for here is one match for a "Password"

	/*
//	NSData *passData = nil;
//	if(attributes != nil)
//	{
//		@try
//		{
//			passData = (__bridge_transfer NSData *)attributes;
//			NSString *myString = [[NSString alloc] initWithData:passData encoding:NSASCIIStringEncoding];
//			NSLog(@"%@", myString);
//		}
//		@catch (NSException *exception) 
//		{
//			NSLog(@"%@", [exception debugDescription]);
//		}
//		@finally 
//		{}
//	}
	*/

	BOOL bPlaceItIntoKeyChain = TRUE;
	//Case values are available in iOS 2.0 and later.
	switch (eSecStatRetreive)
	{
		case errSecSuccess://0
			bPlaceItIntoKeyChain = FALSE;//Means you found it so don't insert - instead retreive.
			NSLog(@"No Error");
			break;
		case errSecUnimplemented://-4
			NSLog(@"Function or operation not implemented.");
			break;
		case errSecParam://-50
			NSLog(@"One or more parameters passed to the function were not valid.");
			break;
		case errSecAllocate://-108
			NSLog(@"Failed to allocate memory.");
			break;
		case errSecNotAvailable://–25291
			NSLog(@"No trust results are available.");
			break;
		case errSecAuthFailed://–25293
			NSLog(@"Authorization/Authentication failed.");
			break;
		case errSecDuplicateItem://–25299
			NSLog(@"The item already exists.");
			break;
		case errSecItemNotFound://–25300
			NSLog(@"The item cannot be found.");
			break;
		case errSecInteractionNotAllowed://–25308
			NSLog(@"Interaction with the Security Server is not allowed.");
			break;
		case errSecDecode://-26275
			NSLog(@"Unable to decode the provided data.");
			break;
		default:
			break;
	}
	
	switch (bPlaceItIntoKeyChain)
	{
		case TRUE:
			// Add the generic attribute and the keychain access group.
			[self.keychainItemData setObject:strIdentifier forKey:(__bridge_transfer id)kSecAttrGeneric];
			break;
		default:
		{
			//self.keychainItemData = [self secItemFormatToDictionary:outDictionary];
			
			// Create a dictionary to return populated with the attributes and data.
			NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
			
			// Add the proper search key and class attribute.
			[returnDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
			[returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
			
			// Acquire the password data from the attributes.
			NSData *passwordData;
			
			CFDataRef pwDataAttributes;
			if (SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (CFTypeRef *)&pwDataAttributes) == noErr)
			{
				// Remove the search, class, and identifier key/value, we don't need them anymore.
				[returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
				
				NSData* passwordData = (__bridge NSData*) pwDataAttributes;
				
				// Add the password to the dictionary, converting from NSData to NSString.
				NSString *password = [[NSString alloc] initWithBytes:[passwordData bytes] length:[passwordData length] encoding:NSUTF8StringEncoding];

				[returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
			}

			
		}
			break;
	}

	return TRUE;
}

-(BOOL)configureAndSavePasswordData:(NSString *)strPw attribs:(NSDictionary *)dictAttributes
{
	// Set up the keychain search dictionary:
	NSMutableDictionary *genericPasswordQuery = [[NSMutableDictionary alloc] init];
	
	NSString *strIdentifier = [NSString stringWithFormat:@"%@", @"Password"];
	
	// This keychain item is a generic password.
	[genericPasswordQuery setObject:(__bridge_transfer id)kSecClassGenericPassword forKey:(__bridge_transfer id)kSecClass];
	[genericPasswordQuery setObject:strIdentifier forKey:(__bridge_transfer id)kSecAttrGeneric];
	
	// Use the proper search constants, return only the attributes of the first match.
	[genericPasswordQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
	[genericPasswordQuery setObject:(__bridge_transfer id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnAttributes];

	NSDictionary *attributes = NULL;
	NSMutableDictionary *updateItem = NULL;
	OSStatus result;
	
	NSData *passData = nil;
	CFDataRef pwAttributes;

	if (SecItemCopyMatching((__bridge CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&pwAttributes) == noErr)
	{
		// First we need the attributes from the Keychain.
		updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
		
		// Second we need to add the appropriate search key/values.
		[updateItem setObject:[genericPasswordQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
		
		// Lastly, we need to set up the updated attribute list being careful to remove the class.
		NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:self.keychainItemData];
		[tempCheck removeObjectForKey:(__bridge id)kSecClass];
		
#if TARGET_IPHONE_SIMULATOR
		[tempCheck removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
		
		// An implicit assumption is that you can only update a single item at a time.
		
		result = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)tempCheck);
		
		NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
	}
	else
	{
		// No previous item found; add the new one.
		result = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:self.keychainItemData], NULL);
		NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
	}

	
	
	
	
//	SecItemAdd(<#CFDictionaryRef attributes#>, <#CFTypeRef *result#>)
//	SecItemUpdate(<#CFDictionaryRef query#>, <#CFDictionaryRef attributesToUpdate#>)
	
	OSStatus eSecStatRetreive = errSecSuccess;
	
	// If the keychain item exists, return the attributes of the item: 
	//keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&outDictionary);
	
	//Case values are available in iOS 2.0 and later.
	switch (eSecStatRetreive)
	{
		case errSecSuccess://0
			NSLog(@"No Error");
			break;
		case errSecUnimplemented://-4
			NSLog(@"Function or operation not implemented.");
			break;
		case errSecParam://-50
			NSLog(@"One or more parameters passed to the function were not valid.");
			break;
		case errSecAllocate://-108
			NSLog(@"Failed to allocate memory.");
			break;
		case errSecNotAvailable://–25291
			NSLog(@"No trust results are available.");
			break;
		case errSecAuthFailed://–25293
			NSLog(@"Authorization/Authentication failed.");
			break;
		case errSecDuplicateItem://–25299
			NSLog(@"The item already exists.");
			break;
		case errSecItemNotFound://–25300
			NSLog(@"The item cannot be found.");
			break;
		case errSecInteractionNotAllowed://–25308
			NSLog(@"Interaction with the Security Server is not allowed.");
			break;
		case errSecDecode://-26275
			NSLog(@"Unable to decode the provided data.");
			break;
		default:
			break;
	}
	
	return TRUE;
}

-(NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
   // The assumption is that this method will be called with a properly populated dictionary
   // containing all the right key/value pairs for a SecItem.
	
	// Create a dictionary to return populated with the attributes and data.
	NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
	
	// Add the Generic Password keychain item class attribute.
	[returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	
	NSArray *arrAllKeys = [dictionaryToConvert allKeys];
	NSArray *arrAllValues = [dictionaryToConvert allValues];
	
	for(NSObject *obj in arrAllKeys)
	{
		NSString *strKey = [arrAllKeys objectAtIndex:0];
		NSString *strVal = [arrAllValues objectAtIndex:0];
		
		NSLog(@"%@, %@", strKey, strVal);
	}
	
	// Convert the NSString to NSData to meet the requirements for the value type kSecValueData.
	// This is where to store sensitive data that should be encrypted.
	NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
	[returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
	
	return returnDictionary;
}

@end