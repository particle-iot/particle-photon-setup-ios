//
//  ParticleGetReadyViewController.h
//  teacup-ios-app
//
//  Created by Ido on 1/15/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "ParticleSetupUIViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ParticleGetLocationPermissionViewController: ParticleSetupUIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *claimCode;
@property (nonatomic, strong) NSArray *claimedDevices;

@end
