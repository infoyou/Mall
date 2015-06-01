//
//  MapViewController.h
//  SVPulsingAnnotationView
//
//  Created by Sam Vermette on 03.03.13.
//  Copyright (c) 2013 Sam Vermette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RootViewController.h"

@interface MapViewController : RootViewController

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

- (id)initWithLatitude:(CLLocationDegrees)latitude
             longitude:(CLLocationDegrees)longitude
                 title:(NSString *)title
              subTitle:(NSString *)subTitle;

@end
