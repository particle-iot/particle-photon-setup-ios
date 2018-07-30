//
//  ParticleUserLoginViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/26/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import "ParticleUserLoginViewController.h"
#import "ParticleSetupWebViewController.h"
#import "ParticleSetupCustomization.h"
#import "ParticleSetupUIElements.h"

#ifdef USE_FRAMEWORKS
#import <ParticleSDK/ParticleSDK.h>
#import <OnePasswordExtension/OnePasswordExtension.h>
#else
#import "Particle-SDK.h"
#import "OnePasswordExtension.h"
//#import <1PasswordExtension/OnePasswordExtension.h>
#endif
#ifdef ANALYTICS
#import "SEGAnalytics.h"
#endif


@interface ParticleUserLoginViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (weak, nonatomic) IBOutlet UIImageView *brandBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *noAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet ParticleSetupUIButton *skipAuthButton;
@property (weak, nonatomic) IBOutlet UIButton *onePasswordButton;


@end

@implementation ParticleUserLoginViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // move to super viewdidload?
    self.brandImage.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImage.backgroundColor = [UIColor clearColor];
    self.brandBackgroundImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    self.brandBackgroundImageView.image = [ParticleSetupCustomization sharedInstance].brandImageBackgroundImage;

    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView1 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView2 = [[UIView alloc] initWithFrame:viewRect];
    
    // TODO: make a custom control from all the text fields
    self.emailTextField.leftView = emptyView1;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:16.0];

    self.passwordTextField.leftView = emptyView2;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
    self.passwordTextField.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:16.0];

    self.skipAuthButton.hidden = !([ParticleSetupCustomization sharedInstance].allowSkipAuthentication);
    [self.onePasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
    if (!self.onePasswordButton.hidden) {
        self.onePasswordButton.hidden = ![ParticleSetupCustomization sharedInstance].allowPasswordManager;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onePasswordButtonTapped:(id)sender {
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"https://login.particle.io" forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }
        
        self.emailTextField.text = loginDictionary[AppExtensionUsernameKey];
        self.passwordTextField.text = loginDictionary[AppExtensionPasswordKey];
    }];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField)
    {
        [self loginButton:self];
    }
    
    return YES;
    
}


- (IBAction)forgotPasswordButton:(id)sender
{
    [self.delegate didRequestPasswordReset:self];
}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Auth: Login Screen"];
#endif
}

- (IBAction)loginButton:(id)sender
{
    [self.view endEditing:YES];

    [self trimTextFieldValue:self.emailTextField];

    if (self.passwordTextField.text.length == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cannot Sign In" message:@"Password cannot be blank" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSString *email = self.emailTextField.text.lowercaseString;
    
    if ([self isValidEmail:email])
    {
        [self.spinner startAnimating];
         [[ParticleCloud sharedInstance] loginWithUser:email password:self.passwordTextField.text completion:^(NSError *error) {
             [self.spinner stopAnimating];
             if (!error)
             {
#ifdef ANALYTICS
                 [[SEGAnalytics sharedAnalytics] track:@"Auth: Login success"];
#endif

                 [self.delegate didFinishUserAuthentication:self loggedIn:YES];
             }
             else
             {

                 NSDictionary *responseBody = error.userInfo[ParticleSDKErrorResponseBodyKey];
                 NSString *errorCode = responseBody[@"error"];

                 if ([errorCode isEqualToString:@"mfa_required"]) {
#ifdef ANALYTICS
                 [[SEGAnalytics sharedAnalytics] track:@"Auth: MFA triggered"];
#endif

                     [self.delegate didTriggerMFA:self mfaToken:responseBody[@"mfa_token"] username:email];
                 } else {
#ifdef ANALYTICS
                     [[SEGAnalytics sharedAnalytics] track:@"Auth: Login failure"];
#endif

                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cannot Sign In" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                     [self presentViewController:alertController animated:YES completion:nil];
                 }
             }
         }];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cannot Sign In" message:@"Invalid email address" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}


- (IBAction)noAccountButton:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate didRequestUserSignup:self];
    
}


- (IBAction)skipAuthButtonTapped:(id)sender {
    
    // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
    NSString *messageStr = [ParticleSetupCustomization sharedInstance].skipAuthenticationMessage;
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Skip Authentication" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
#ifdef ANALYTICS
        [[SEGAnalytics sharedAnalytics] track:@"Auth: Auth skipped"];
#endif
        [self.delegate didFinishUserAuthentication:self loggedIn:NO];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // ???
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
