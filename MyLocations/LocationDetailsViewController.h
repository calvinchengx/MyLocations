//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Calvin Cheng on 27/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationDetailsViewController : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) CLPlacemark *placemark;


- (IBAction)done:(id)sender;

- (IBAction)cancel:(id)sender;

@end