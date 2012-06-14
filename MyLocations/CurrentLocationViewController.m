//
//  FirstViewController.m
//  MyLocations
//
//  Created by Calvin Cheng on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()
- (void)updateLabels;
- (void)startLocationManager;
- (void)stopLocationManager;
- (void)configureGetButton;
@end

@implementation CurrentLocationViewController{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performReverseGeocoding;
    NSError *lastGeocodingError;
    
    CLLocationManager *locationManager;
    CLLocation *location;
    NSError *lastLocationError;
    BOOL updatingLocation;
}

@synthesize messageLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize tagButton;
@synthesize getButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateLabels];
    [self configureGetButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messageLabel = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.addressLabel = nil;
    self.tagButton = nil;
    self.getButton = nil;
}

- (IBAction)getLocation:(id)sender
{
    if (updatingLocation) {
        [self stopLocationManager];
    } else {
        location = nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocodingError = nil;
        
        [self startLocationManager];
    }
    
    [self updateLabels];
    [self configureGetButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    lastLocationError = error;
    [self updateLabels];
    [self configureGetButton];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation %@", newLocation);
    
    // if the time at which the location object was determined is too long ago,
    // then this is a cached result.
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }

    // Use the horizontalAccuracy property of the location object to determine if our new readings
    // are more accurate than previous ones. Ignore invalid measurements by returning.
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        lastLocationError = nil;
        location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            NSLog(@"*** we're done!");
            [self stopLocationManager];
            [self configureGetButton];
        }
        
        if (!performReverseGeocoding) {
            NSLog(@"*** Going to geocode");
            
            performReverseGeocoding = YES;
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                
                lastGeocodingError = error;
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                } else {
                    placemark = nil;
                }
                
                performReverseGeocoding = NO;
                [self updateLabels];
            }];
        }
    }
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}

- (void)updateLabels
{
    if (location != nil){
        self.messageLabel.text = @"GPS Coordinates";
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        self.tagButton.hidden = NO;
        
        if (placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark:placemark];
        } else if (performReverseGeocoding) {
            self.addressLabel.text = @"Searching for Address...";
        } else if (lastGeocodingError != nil) {
            self.addressLabel.text = @"Error finding Address";
        } else {
            self.addressLabel.text = @"No Address Found";
        }
        
    } else {
        self.messageLabel.text = @"Press the Button to Start";
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        
        // Handle various user-friendly message that we want to provide to the user
        NSString *statusMessage;
        if (lastLocationError != nil) {
            if ([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disabled";
            } else {
                statusMessage = @"Error Getting Location";
            }
        } else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Location Services disabled";
        } else if (updatingLocation) {
            statusMessage = @"Searching...";
        } else {
            statusMessage = @"Press the Button to Start";
        }
        
        self.messageLabel.text = statusMessage;
    }
}

- (void)configureGetButton
{
    if (updatingLocation) {
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
    }
}

- (void)stopLocationManager
{
    if (updatingLocation) {
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}

@end