//
//  LUHomeViewController.m
//  LinkUp
//
//  Created by Jon Como on 3/2/13.
//  Copyright (c) 2013 Underground. All rights reserved.
//

#import "LUHomeViewController.h"
#import "LUAuthorize.h"

@interface LUHomeViewController ()

@end

@implementation LUHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[LUAuthorize sharedManager] authorizeWithLogin:NO delegate:self completion:^(BOOL success, NSDictionary *profile) {
        if (!success)
        {
            [self performSegueWithIdentifier:@"signIn" sender:self];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
