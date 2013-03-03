//
//  LUViewController.m
//  LinkUp
//
//  Created by Jon Como on 3/2/13.
//  Copyright (c) 2013 Underground. All rights reserved.
//

#import "LUViewController.h"
#import "LUAuthorize.h"

@interface LUViewController ()

@end

@implementation LUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[LUAuthorize sharedManager] authorizeWithCompletion:^(BOOL success, NSDictionary *profile) {
        NSLog(@"Got a profile: %@", profile);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
