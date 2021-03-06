//
//  LUSignInViewController.m
//  LinkUp
//
//  Created by Jon Como on 3/2/13.
//  Copyright (c) 2013 Underground. All rights reserved.
//

#import "LUSignInViewController.h"
#import "LUAuthorize.h"

@interface LUSignInViewController ()
{
    
}

@end

@implementation LUSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender
{
    [[LUAuthorize sharedManager] authorizeWithLogin:YES delegate:self completion:^(BOOL success, NSDictionary *profile) {
        if (success && profile)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
