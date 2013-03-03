//
//  LUAuthorize.h
//  LinkUp
//
//  Created by Jon Como on 3/2/13.
//  Copyright (c) 2013 Underground. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AuthorizeCompletion)(BOOL success, NSDictionary *profile);

@interface LUAuthorize : NSObject

+(id)sharedManager;
-(void)authorizeWithCompletion:(AuthorizeCompletion)block;

@end