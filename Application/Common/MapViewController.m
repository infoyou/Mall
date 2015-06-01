//
//  MapViewController.m
//  SVPulsingAnnotationView
//
//  Created by Sam Vermette on 03.03.13.
//  Copyright (c) 2013 Sam Vermette. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "SVAnnotation.h"

#import "SVPulsingAnnotationView.h"

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation MapViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (id)initWithLatitude:(CLLocationDegrees)latitude
             longitude:(CLLocationDegrees)longitude
                 title:(NSString *)title
              subTitle:(NSString *)subTitle
{
    
    if (self = [super init]) {
        
        self.latitude = latitude;
        self.longitude = longitude;
        self.title = title;
        self.subTitle = subTitle;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:NO];
    
    SVAnnotation *annotation = [[SVAnnotation alloc] initWithCoordinate:coordinate];
    annotation.title = self.title;
    annotation.subtitle = self.subTitle;
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        
        static NSString *identifier = @"currentLocation";
		SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if(pulsingView == nil) {
			pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
            pulsingView.canShowCallout = YES;
        }
		
		return pulsingView;
    }
    
    return nil;
}

@end
