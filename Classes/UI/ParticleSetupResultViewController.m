//
//  ParticleSetupSuccessFailureViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 spark. All rights reserved.
//


#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif
#import "ParticleSetupUIElements.h"
#import "ParticleSetupMainController.h"
#import "ParticleSetupWebViewController.h"
#import "ParticleSetupCustomization.h"
#import "ParticleSetupResultViewController.h"
#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@interface ParticleSetupResultViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *shortMessageLabel;
@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *longMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *setupResultImageView;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;

@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *nameDeviceLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameDeviceTextField;
@property (strong, nonatomic) NSArray *randomDeviceNamesArray;
@property (nonatomic) BOOL deviceNamed;
@end

@implementation ParticleSetupResultViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // set logo
    self.brandImageView.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    self.nameDeviceLabel.hidden = YES;
    self.nameDeviceTextField.hidden = YES;

    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    
    self.nameDeviceTextField.leftView = emptyView;
    self.nameDeviceTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nameDeviceTextField.delegate = self;
    self.nameDeviceTextField.returnKeyType = UIReturnKeyDone;
    self.nameDeviceTextField.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:16.0];

    // init funny random device names
    self.randomDeviceNamesArray = [NSArray arrayWithObjects:@"aardvark", @"bacon", @"badger", @"banjo", @"bobcat", @"boomer", @"captain", @"chicken", @"cowboy", @"maker", @"splendid", @"sparkling", @"dentist", @"doctor", @"green", @"easter", @"ferret", @"gerbil", @"hacker", @"hamster", @"wizard", @"hobbit", @"hoosier", @"hunter", @"jester", @"jetpack", @"kitty", @"laser", @"lawyer", @"mighty", @"monkey", @"morphing", @"mutant", @"narwhal", @"ninja", @"normal", @"penguin", @"pirate", @"pizza", @"plumber", @"power", @"puppy", @"ranger", @"raptor", @"robot", @"scraper", @"burrito", @"station", @"tasty", @"trochee", @"turkey", @"turtle", @"vampire", @"wombat", @"zombie", nil];
    
    self.deviceNamed = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{
    if ((!isiPhone4) && (!isiPhone5))
        [self disableKeyboardMovesViewUp];
    
    if (self.setupResult == ParticleSetupMainControllerResultSuccess)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.nameDeviceTextField becomeFirstResponder];
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Setup Result Screen"];
#endif

    
    [super viewWillAppear:animated];
    
    switch (self.setupResult) {
        case ParticleSetupMainControllerResultSuccess:
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"success"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultSuccess_Short;
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultSuccess_Long;
            
            self.nameDeviceLabel.hidden = NO;
            self.nameDeviceTextField.hidden = NO;
            NSString *randomDeviceName1 = self.randomDeviceNamesArray[arc4random_uniform((UInt32)self.randomDeviceNamesArray.count)];
            NSString *randomDeviceName2 = self.randomDeviceNamesArray[arc4random_uniform((UInt32)self.randomDeviceNamesArray.count)];
            self.nameDeviceTextField.text = [NSString stringWithFormat:@"%@_%@",randomDeviceName1,randomDeviceName2];
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Success"];
#endif

            break;
        }
            
        case ParticleSetupMainControllerResultSuccessDeviceOffline:
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"warning"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultOffLine_Short;
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultSuccess_Long;
            
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Success" properties:@{@"reason":@"device offline"}];
#endif
            break;
        }

        case ParticleSetupMainControllerResultSuccessNotClaimed:
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"success"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultNotClaimed_Short;
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultNotClaimed_Long;
            
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Success" properties:@{@"reason":@"not claimed"}];
#endif
            break;
            
        }
            
        case ParticleSetupMainControllerResultFailureClaiming:
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"failure"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailed_Short;
            // TODO: add customization point for custom troubleshoot texts
//            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials. If {device} LED is breathing cyan an internal cloud issue occured - please contact product support.";
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailed_Long;
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Failure" properties:@{@"reason":@"claiming failed"}];
#endif

            break;
        }
            
        case ParticleSetupMainControllerResultFailureCannotDisconnectFromDevice:
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"failure"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailedToDisconnect_Short;
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailedToDisconnect_Long;
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Failure" properties:@{@"reason":@"cannot disconnect"}];
#endif

            break;
        }
            
  
        case ParticleSetupMainControllerResultFailureConfigure:
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"failure"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailedToConfigure_Short;
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailedToConfigure_Long;
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Failure" properties:@{@"reason":@"cannot configure"}];
#endif
            break;
        }
            
        default: //ParticleSetupMainControllerResultFailureLostConnectionToDevice
        {
            self.setupResultImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"failure"];
            self.shortMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailedConnectionLost_Short;
            self.longMessageLabel.text = [ParticleSetupCustomization sharedInstance].resultFailedConnectionLost_Long;
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Failure" properties:@{@"reason":@"lost connection"}];
#endif
            
            break;
        }
            
            
    }
    
    [self.longMessageLabel setType:@"normal"];

    /*
    if ([ParticleSetupCustomization sharedInstance].tintSetupImages)
    {
        self.setupResultImageView.image = [self.setupResultImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.setupResultImageView.tintColor = [ParticleSetupCustomization sharedInstance].normalTextColor;// elementBackgroundColor;;
    }
     */

}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == self.nameDeviceTextField)
    {
        [self.device rename:self.nameDeviceTextField.text completion:^(NSError *error) {
            if (error) {
                NSLog(@"Rrror naming device %@",error.description);
            } else {
                self.deviceNamed = YES;
            }
            [textField resignFirstResponder];
            [self doneButtonTapped:self];
        }];
        
    }
    
    return YES;
    
}


- (IBAction)doneButtonTapped:(id)sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (self.device)
        userInfo[kParticleSetupDidFinishDeviceKey] = self.device;

    if (self.deviceID)
        userInfo[kParticleSetupDidFailDeviceIDKey] = self.deviceID;

    userInfo[kParticleSetupDidFinishStateKey] = @(self.setupResult);
    
    if (self.setupResult == ParticleSetupMainControllerResultSuccess)
    {
     
        if (!self.deviceNamed) {
            [self.device rename:self.nameDeviceTextField.text completion:^(NSError *error) {
                if (error) {
                    NSLog(@"error name device %@",error.description);
                } else {
                    self.deviceNamed = YES;
                }
            }];
        }

        // Update zero notice to user
        // TODO: condition message only if its really getting update zero (need event listening)
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shownUpdateZeroNotice"]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[ParticleSetupCustomization sharedInstance].alertFirmware_Title
                                        message:[ParticleSetupCustomization sharedInstance].alertFirmware_Message
                                       delegate:nil
                              cancelButtonTitle:[ParticleSetupCustomization sharedInstance].alertFirmware_CancelBtn
                              otherButtonTitles:nil];
            [alert show];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shownUpdateZeroNotice"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    // finish with success and provide device
    [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidFinishNotification
                                                        object:nil
                                                      userInfo:userInfo];

}


- (IBAction)troubleshootingButtonTouched:(id)sender
{
    
    ParticleSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:[ParticleSetupCustomization sharedInstance].appResourcesRefName
                                                                       bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]]
                                             instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [ParticleSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
    
}



@end
