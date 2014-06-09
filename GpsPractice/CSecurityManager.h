/*
//  CSecurityManager.h
//  GpsPractice
//
//  Created by jbehrbaum on 6/9/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
*/


#import <Foundation/Foundation.h>

@interface CSecurityManager : NSObject

-(void)addToKeyChain;
-(BOOL)findInKeyChain;

-(BOOL)retreivePasswordAttributes:(NSDictionary **)dictAttributes;
-(BOOL)configureAndSavePasswordData:(NSString *)strPw attribs:(NSDictionary *)dictAttributes;

@end
