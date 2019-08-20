//
//  ParticleGetReadyViewController.m
//  teacup-ios-app
//
//  Created by Ido on 1/15/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "ParticleGetReadyViewController.h"
#import "ParticleSetupWebViewController.h"
#import <CoreLocation/CoreLocation.h>

#ifdef USE_FRAMEWORKS
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif
#import "ParticleSetupMainController.h"
#import "ParticleDiscoverDeviceViewController.h"
#import "ParticleSetupUIElements.h"
#import "ParticleSetupResultViewController.h"
#import "ParticleSetupCustomization.h"
#import "ParticleGetLocationPermissionViewController.h"

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif


@interface ParticleGetLocationPermissionViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (weak, nonatomic) IBOutlet UIImageView *brandBackgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end

@implementation ParticleGetLocationPermissionViewController {
    CLLocationManager *_locationManager;
    BOOL _animating;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.brandImage.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImage.backgroundColor = [UIColor clearColor];
    self.brandBackgroundImage.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    self.brandBackgroundImage.image = [ParticleSetupCustomization sharedInstance].brandImageBackgroundImage;

    self.cancelSetupButton.titleLabel.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.self.cancelSetupButton.titleLabel.font.pointSize];
    UIColor *navBarButtonsColor = ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? [UIColor whiteColor] : [UIColor blackColor];
    [self.cancelSetupButton setTitleColor:navBarButtonsColor forState:UIControlStateNormal];

    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];


    _locationManager = [[CLLocationManager alloc] init];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    _animating = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"discover"]) {
        ParticleDiscoverDeviceViewController *vc = [segue destinationViewController];
        vc.claimCode = self.claimCode;
        vc.claimedDevices = self.claimedDevices;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    #ifdef ANALYTICS
        [[SEGAnalytics sharedAnalytics] track:@"DeviceSetup_GetLocationPermission"];
    //    NSLog(@"analytics enabled");
    #endif
}



-(void)viewWillAppear:(BOOL)animated
{
    [self updateContent];
}

- (void)updateContent {
    NSLog(@"updateContent called!!!");
    if ([CLLocationManager locationServicesEnabled] &&
            ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
        [self.bodyLabel setText:@"Photon setup reads current Wi-Fi SSID to determine when your phone connects to a device.\n\n"
                                "Starting iOS 13, for apps to have access to Wi-Fi SSID information, user must grant location services permission.\n\n"
                                "Particle app will only use this permission to read Wi-Fi SSID and not to track your location."];
        [self.continueButton setTitle:@"GRANT PERMISSION" forState:UIControlStateNormal];
    } else if ([CLLocationManager locationServicesEnabled] &&
            (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))) {
        if (!_animating) {
            [self performSegueWithIdentifier:@"discover" sender:self];
            _animating = true;
        }
    } else {
        [self.bodyLabel setText:@"Photon setup reads current Wi-Fi SSID to determine when your phone connects to a device.\n\n"
                                "Starting iOS 13, for apps to have access to Wi-Fi SSID information, user must grant location services permission.\n\n"
                                "You have previously denied Particle application permission to access location services. Please grant the permission in Settings app.\n\n"
                                "Particle app will only use this permission to read Wi-Fi SSID and not to track your location."];
        [self.continueButton setTitle:@"OPEN SETTINGS" forState:UIControlStateNormal];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self updateContent];
}

- (IBAction)cancelButtonTouched:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidFinishNotification object:nil userInfo:@{kParticleSetupDidFinishStateKey:@(ParticleSetupMainControllerResultUserCancel)}];
}

- (IBAction)continueButtonTouched:(id)sender {
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
    } else {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)])
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        else
            [[UIApplication sharedApplication] openURL:url];
    }
}




@end
