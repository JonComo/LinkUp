//
//  LUAuthorize.m
//  LinkUp
//
//  Created by Jon Como on 3/2/13.
//  Copyright (c) 2013 Underground. All rights reserved.
//

#import "LUAuthorize.h"
#import "LUAppDelegate.h"
#import "OAuthLoginView.h"

const NSString *apiKey = @"cj2jjytw6ed5";
const NSString *secretKey = @"f03A0ArEBdNrTxA1";

@implementation LUAuthorize
{
    OAuthLoginView *oAuthLoginView;
    AuthorizeCompletion completionBlock;
    
    OAToken *token;
    OAConsumer *consumer;
}

+(id)sharedManager
{
    static LUAuthorize *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}


-(void)authorizeWithCompletion:(AuthorizeCompletion)block
{
    completionBlock = block;
    
    consumer = [[OAConsumer alloc] initWithKey:apiKey secret:secretKey realm:@"http://api.linkedin.com/"];
    token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"linkedIn" prefix:@"LI"];
    
    if (token && consumer)
    {
        [self profileApiCall];
    }else{
        [self authorizeWithLogin];
    }
}

- (void)profileApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:consumer
                                       token:token
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(profileApiCallResult:didFinish:)
                  didFailSelector:@selector(profileApiCallResult:didFail:)];
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSDictionary *profile = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    if (profile && ![profile[@"status"] isEqual:@404])
    {
        token = oAuthLoginView.accessToken;
        [token storeInUserDefaultsWithServiceProviderName:@"linkedIn" prefix:@"LI"];
        
        if (completionBlock) completionBlock(YES, profile);
        NSLog(@"Success: %@" , [profile objectForKey:@"firstName"]);
        //name.text = [[NSString alloc] initWithFormat:@"%@ %@",[profile objectForKey:@"firstName"], [profile objectForKey:@"lastName"]];
        //headline.text = [profile objectForKey:@"headline"];
    }
    
    // The next thing we want to do is call the network updates
    //[self networkApiCall];
    
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
    
    [self authorizeWithLogin];
    //Reauthorize
}

-(void)authorizeWithLogin
{
    oAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:oAuthLoginView];
    
    LUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [appDelegate.window.rootViewController presentViewController:oAuthLoginView animated:YES completion:nil];
}

-(void)loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // We're going to do these calls serially just for easy code reading.
    // They can be done asynchronously
    // Get the profile, then the network updates
    [self profileApiCall];
}

- (void)networkApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/network/updates?scope=self&count=1&type=STAT"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:oAuthLoginView.consumer
                                       token:oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(networkApiCallResult:didFinish:)
                  didFailSelector:@selector(networkApiCallResult:didFail:)];
    
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    //NSDictionary *person = [[[[[responseBody objectFromJSONString] objectForKey:@"values"] objectAtIndex:0] objectForKey:@"updateContent"] objectForKey:@"person"];
    
    
    //    if ( [person objectForKey:@"currentStatus"] )
    //    {
    //        [postButton setHidden:false];
    //        [postButtonLabel setHidden:false];
    //        [statusTextView setHidden:false];
    //        [updateStatusLabel setHidden:false];
    //        status.text = [person objectForKey:@"currentStatus"];
    //    } else {
    //        [postButton setHidden:false];
    //        [postButtonLabel setHidden:false];
    //        [statusTextView setHidden:false];
    //        [updateStatusLabel setHidden:false];
    //        status.text = [[[[person objectForKey:@"personActivities"]
    //                         objectForKey:@"values"]
    //                        objectAtIndex:0]
    //                       objectForKey:@"body"];
    //
    //    }
    //
    //    [self dismissModalViewControllerAnimated:YES];
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

@end
