//
//  LUHomeViewController.m
//  LinkUp
//
//  Created by Jon Como on 3/2/13.
//  Copyright (c) 2013 Underground. All rights reserved.
//

#import "LUHomeViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "LUAuthorize.h"

@interface LUHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSDictionary *userProfile;
    PFGeoPoint *location;
    NSMutableArray *usersNearby;
    
    CGPoint lastPanLocation;
    
    __weak IBOutlet UICollectionView *collectionViewUsers;
}

@end

@implementation LUHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    //[viewUser addGestureRecognizer:pan];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[LUAuthorize sharedManager] authorizeWithLogin:NO delegate:self completion:^(BOOL success, NSDictionary *profile) {
        if (!success)
        {
            [self performSegueWithIdentifier:@"signIn" sender:self];
        }else{
            userProfile = profile;
            
            PFUser *user = [PFUser currentUser];
            
            if (user) {
                //Already signed in
                [self userLocationAndInfoUpdateCompletion:^{
                    [self usersNearbyCompletion:^(NSArray *users) {
                        [self updateStack];
                    }];
                }];
            }else{
                //Create new one
                user = [PFUser user];
                
                user.username = [NSString stringWithFormat:@"%@%@", userProfile[@"firstName"], userProfile[@"lastName"]];
                user.password = userProfile[@"id"];
                
                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //Created new user!
                    if (error) return;
                    [self userLocationAndInfoUpdateCompletion:^{
                        [self usersNearbyCompletion:^(NSArray *users) {
                            [self updateStack];
                        }];
                    }];
                }];
            }
            
            //Save installation for push notifications
        }
    }];
}

-(void)panning:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            lastPanLocation = [pan locationInView:self.view];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self gestureEnded];
            break;
            
        default:
            break;
    }
    
    CGPoint currentLocation = [pan locationInView:self.view];
    //viewUser.layer.transform = CATransform3DTranslate(viewUser.layer.transform, currentLocation.x - lastPanLocation.x, currentLocation.y - lastPanLocation.y, 0);
    
    lastPanLocation = currentLocation;
}

-(void)gestureEnded
{
    /*
    if (lastPanLocation.x > 200)
    {
        //Networked
        [UIView animateWithDuration:0.3 animations:^{
            //go back
            viewUser.layer.transform = CATransform3DTranslate(viewUser.layer.transform, 400, 0, 0);
            [self.view layoutSubviews];
        } completion:^(BOOL finished) {
            viewUser.layer.transform = CATransform3DIdentity;
            [self popTopUserWithAction:LUActionNetwork];
        }];
    }else if (lastPanLocation.x < 120)
    {
        //Canceled
        [UIView animateWithDuration:0.3 animations:^{
            //go back
            viewUser.layer.transform = CATransform3DTranslate(viewUser.layer.transform, -400, 0, 0);
            [self.view layoutSubviews];
        } completion:^(BOOL finished) {
            viewUser.layer.transform = CATransform3DIdentity;
            [self popTopUserWithAction:LUActionDiscard];
        }];
    }else{
        //Inaction
        [UIView animateWithDuration:0.2 animations:^{
            //go back
            viewUser.layer.transform = CATransform3DIdentity;
            [self.view layoutSubviews];
        } completion:^(BOOL finished) {
            viewUser.layer.transform = CATransform3DIdentity;
        }];
    }
     
     */
}

-(void)popTopUserWithAction:(LUAction)action
{
    if (usersNearby.count > 1)
    {
        PFUser *selectedUser = usersNearby[0];
        [usersNearby removeObject:selectedUser];
    }else{
        //find more users
        [self usersNearbyCompletion:^(NSArray *users) {
            [self updateStack];
        }];
    }
}

-(void)updateStack
{
    /*
    PFUser *topUser = usersNearby[0];
    labelName.text = [NSString stringWithFormat:@"%@ %@", topUser[@"LIProfile"][@"firstName"], topUser[@"LIProfile"][@"lastName"]];
    labelSkill.text = topUser[@"LIProfile"][@"industry"];
     */
    
    [collectionViewUsers reloadData];
}

-(void)userLocationAndInfoUpdateCompletion:(void(^)(void))block
{
    PFUser *user = [PFUser currentUser];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        location = geoPoint;
        
        [user setObject:userProfile[@"id"] forKey:@"LIId"];
        [user setObject:userProfile forKey:@"LIProfile"];
        [user setObject:geoPoint forKey:@"location"];
        
        [user saveInBackground];
        
        if (block) block();
    }];
}

-(void)usersNearbyCompletion:(void(^)(NSArray *users))block
{
    PFQuery *geoQuery = [PFUser query];
    
    [geoQuery whereKey:@"location" nearGeoPoint:location];
    
    [geoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) return;
        usersNearby = [objects mutableCopy];
        if (block) block(usersNearby);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    
    PFUser *user = usersNearby[indexPath.row];
    
    UIImageView *pic = (UIImageView *)[cell viewWithTag:100];
    UILabel *name = (UILabel *)[cell viewWithTag:200];
    UILabel *skill = (UILabel *)[cell viewWithTag:300];
    
    name.text = [NSString stringWithFormat:@"%@ %@", user[@"LIProfile"][@"firstName"], user[@"LIProfile"][@"lastName"]];
    skill.text = user[@"LIProfile"][@"industry"];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return usersNearby.count;
}

@end
