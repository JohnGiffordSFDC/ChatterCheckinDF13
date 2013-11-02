//
//  MapViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "MapViewController.h"
#import "CheckinViewController.h"
#import "SFAuthenticationManager.h"
#import "AppDelegate.h"
#import "Annotation.h"
#import "ChatterPinAnnotationView.h"

@implementation MapViewController

@synthesize mapView = _mapView, checkinButton = _checkinButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_locationManager == nil){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 10.0f;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
        
    [_locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
    
    [self setupNavbar];
    [self setupTabBar];

}

- (void)viewDidUnload
{
    _mapView = nil;
    _checkinButton = nil;
}

- (void)dealloc
{
	
}

- (void)setupNavbar
{
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
    
    UIBarButtonItem *checkinBtn = [[UIBarButtonItem alloc]initWithTitle:@"Checkin" style:UIBarButtonItemStyleBordered target:self action:@selector(performCoordinateGeocode:)];
    [self.navigationItem setRightBarButtonItem:checkinBtn];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:166.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0]];
}

- (void)setupTabBar {
    [self.tabBarController.tabBar setTintColor:[UIColor darkGrayColor]];
}

- (IBAction)performCoordinateGeocode:(id)sender
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D coord = _currentLocation;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            [self displayError:error];
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        
        [self displayCheckin:placemarks];

    }];
}

#pragma mark - MKMapViewDelegate messages

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = nil;
    static NSString* ShopAnnotationIdentifier = @"shopAnnotationIdentifier";
    static NSString *ChatterPinAnnotationIdentifier = @"ChatterPinAnnotationViewIdentifier";
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        annotationView = (ChatterPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: ChatterPinAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[ChatterPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: ChatterPinAnnotationIdentifier];
        }
    }
    else {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ShopAnnotationIdentifier];
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ShopAnnotationIdentifier];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            annotationView = pinView;
        }
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // we have received our current location, so enable the "Get Current Address" button
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.075;
    mapRegion.span.longitudeDelta = 0.075;
    
    [_mapView setRegion:mapRegion animated: YES];
    
    _currentLocation = [userLocation coordinate];
    
    [_checkinButton setEnabled:YES];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    
}

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


- (void)displayCheckin:(NSArray *)placemarks
{
    CheckinViewController *cvc = [[CheckinViewController alloc] initWithNibName:@"CheckinViewController" bundle:nil];
    
    [cvc setPlacemarks:placemarks];
    
    [self.navigationController pushViewController:cvc animated:YES];
}

- (void)logout {
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"Please Confirm!"
                                                      message:@"Are you sure you want to log out?"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:@"Cancel",nil];
    [alert setTag:123];
    [alert show];

}

- (void)displayError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled: message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default: message = [error description];
                break;
        }
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alert show];
    });   
}

#pragma mark - CLLocationManagerDelegate

- (void)startUpdatingCurrentLocation
{
    NSLog(@"startUpdatingCurrentLocation");
}


- (void)stopUpdatingCurrentLocation
{
    NSLog(@"stopUpdatingCurrentLocation");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation");
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    NSLog(@"%@", error);
    
    [self stopUpdatingCurrentLocation];
    
    _currentLocation = kCLLocationCoordinate2DInvalid;
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error updating location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
		[[SFAuthenticationManager sharedManager] logout];
    }
    
    return;
}

- (void)setAnnotations {
    
}

@end
