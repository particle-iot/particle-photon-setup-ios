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


@interface ParticleGetReadyViewController ()
@property(weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property(weak, nonatomic) IBOutlet UIImageView *brandBackgroundImageView;
@property(weak, nonatomic) IBOutlet UIButton *readyButton;
@property(weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;

@property(weak, nonatomic) IBOutlet UILabel *loggedInLabel;
@property(weak, nonatomic) IBOutlet ParticleSetupUILabel *instructionsLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@property(weak, nonatomic) IBOutlet UIImageView *productImageView;

// new claiming process
@property(nonatomic, strong) NSString *claimCode;
@property(nonatomic, strong) NSArray *claimedDevices;
@property(weak, nonatomic) IBOutlet ParticleSetupUIButton *logoutButton;
@property(weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property(weak, nonatomic) IBOutlet ParticleSetupUILabel *loggedInUserLabel;

@end

@implementation ParticleGetReadyViewController


- (UIStatusBarStyle)preferredStatusBarStyle {
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.brandImageView.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [UIColor clearColor];
    self.brandBackgroundImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    self.brandBackgroundImageView.image = [ParticleSetupCustomization sharedInstance].brandImageBackgroundImage;

    UIColor *navBarButtonsColor = ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? [UIColor whiteColor] : [UIColor blackColor];
    [self.cancelSetupButton setTitleColor:navBarButtonsColor forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:navBarButtonsColor forState:UIControlStateNormal];

    if ([ParticleSetupCustomization sharedInstance].productImage)
        self.productImageView.image = [ParticleSetupCustomization sharedInstance].productImage;

    if ([ParticleCloud sharedInstance].loggedInUsername)
        self.loggedInLabel.text = [self.loggedInLabel.text stringByAppendingString:[ParticleCloud sharedInstance].loggedInUsername];
    else
        self.loggedInLabel.text = @"";

    self.loggedInLabel.alpha = 0.85;
    self.logoutButton.titleLabel.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.logoutButton.titleLabel.font.pointSize];
    self.cancelSetupButton.titleLabel.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.self.cancelSetupButton.titleLabel.font.pointSize];

    if ([ParticleCloud sharedInstance].isAuthenticated) {
        self.loggedInLabel.text = [ParticleCloud sharedInstance].loggedInUsername;
    } else {
        [self.logoutButton setTitle:ParticleSetupStrings_GetReady_Button_LogIn forState:UIControlStateNormal];
        self.loggedInLabel.text = @"";
    }
    if ([ParticleSetupCustomization sharedInstance].disableLogOutOption) {
        self.logoutButton.hidden = YES;
    }
}

- (IBAction)cancelSetup:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidFinishNotification object:nil userInfo:@{kParticleSetupDidFinishStateKey: @(ParticleSetupMainControllerResultUserCancel)}];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];


    if (isiPhone4) {
        self.instructionsLabel.text = [ParticleSetupStrings_GetReady_iPhone4MoreInstructions stringByReplacingOccurrencesOfString:@"{{instructions}}" withString:self.instructionsLabel.text];
        [self.view setNeedsUpdateConstraints];

        [UIView animateWithDuration:0.25f animations:^{
            [self.view layoutIfNeeded];
        }];
    }


}

- (IBAction)troubleShootingButtonTapped:(id)sender {
    ParticleSetupWebViewController* webVC = [[ParticleSetupMainController getSetupStoryboard] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [ParticleSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
}

- (void)selectSegue {
    if (@available(iOS 13.0, *)) {
        if ([CLLocationManager locationServicesEnabled] &&
                ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
            [self performSegueWithIdentifier:@"discover" sender:self];
        } else {
            [self performSegueWithIdentifier:@"corelocation" sender:self];
        }
    } else {
        [self performSegueWithIdentifier:@"discover" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"discover"]) {
        ParticleDiscoverDeviceViewController *vc = [segue destinationViewController];
        vc.claimCode = self.claimCode;
        vc.claimedDevices = self.claimedDevices;
    } else if ([[segue identifier] isEqualToString:@"corelocation"]) {
        ParticleGetLocationPermissionViewController *vc = [segue destinationViewController];
        vc.claimCode = self.claimCode;
        vc.claimedDevices = self.claimedDevices;
    }
}


- (IBAction)readyButtonTapped:(id)sender {
    [self.spinner startAnimating];
    self.readyButton.userInteractionEnabled = NO;


    void (^claimCodeCompletionBlock)(NSString *, NSArray *, NSError *) = ^void(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {

        self.readyButton.userInteractionEnabled = YES;
        [self.spinner stopAnimating];

        if (!error) {
            self.claimCode = claimCode;
            self.claimedDevices = userClaimedDeviceIDs;
            [self selectSegue];
        } else {
            if (error.code == 401)
            {
                NSString *errStr = [ParticleSetupStrings_GetReady_Error_AccessDenied_Title stringByReplacingOccurrencesOfString:@"{{brand}}" withString:[ParticleSetupCustomization sharedInstance].brandName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ParticleSetupStrings_GetReady_Error_AccessDenied_Title message:errStr delegate:self cancelButtonTitle:ParticleSetupStrings_Action_Ok otherButtonTitles:nil];
                [alert show];
                [[ParticleCloud sharedInstance] logout];
                [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidLogoutNotification object:nil userInfo:nil];
            } else {
                NSLog(@"error.code = %i", error.code);
                NSString *errStr;
                NSString *titleStr;
                if (error.code == 402) {
                    errStr = [ParticleSetupStrings_GetReady_Error_Generic_Message stringByReplacingOccurrencesOfString:@"{{error}}" withString:error.localizedDescription];
                    titleStr = ParticleSetupStrings_GetReady_Error_Generic_Title;
                } else if ([ParticleSetupCustomization sharedInstance].productMode) {

                    errStr = [ParticleSetupStrings_GetReady_Error_BadProductId_Message stringByReplacingOccurrencesOfString:@"{{error}}" withString:error.localizedDescription];
                    titleStr = ParticleSetupStrings_GetReady_Error_BadProductId_Title;
                } else {
                    errStr = [ParticleSetupStrings_GetReady_Error_NoInternet_Message stringByReplacingOccurrencesOfString:@"{{error}}" withString:error.localizedDescription];
                    titleStr = ParticleSetupStrings_GetReady_Error_NoInternet_Title;
                }

                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:errStr delegate:nil cancelButtonTitle:ParticleSetupStrings_Action_Ok otherButtonTitles:nil];
                errorAlertView.delegate = self;
                [errorAlertView show];
            }
        }
    };

    if ([ParticleCloud sharedInstance].isAuthenticated) {
        if ([ParticleSetupCustomization sharedInstance].productMode) {
            [[ParticleCloud sharedInstance] generateClaimCodeForProduct:[ParticleSetupCustomization sharedInstance].productId completion:claimCodeCompletionBlock];
        } else {
            [[ParticleCloud sharedInstance] generateClaimCode:claimCodeCompletionBlock];
        }
    } else {
        [self selectSegue];
    }


}

- (void)viewWillAppear:(BOOL)animated {
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"DeviceSetup_GetReadyScreen"];
#endif
}


- (IBAction)logoutButtonTouched:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ParticleSetupStrings_GetReady_Prompt_LogOut_Title message:ParticleSetupStrings_GetReady_Prompt_LogOut_Message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:ParticleSetupStrings_Action_Cancel style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:ParticleSetupStrings_Action_LogOut style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ParticleCloud sharedInstance] logout];
        [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidLogoutNotification object:nil userInfo:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
