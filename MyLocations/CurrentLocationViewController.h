//
//  FirstViewController.h
//  MyLocations
//
//  Created by Calvin Cheng on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// import done in .pch file already :-) No need to leave this here
// #import <UIKit/UIKit.h>
// #import <CoreLocation/CoreLocation.h>
#import "LocationDetailsViewController.h"

@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UIButton *tagButton;
@property (nonatomic, strong) IBOutlet UIButton *getButton;

- (IBAction)getLocation:(id)sender;

@end
