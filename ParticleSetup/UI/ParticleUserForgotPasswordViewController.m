//
//  ParticleUserForgotPasswordViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/13/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

#import "ParticleUserForgotPasswordViewController.h"
#import "ParticleSetupCustomization.h"

#ifdef USE_FRAMEWORKS
#import <ParticleSDK/ParticleSDK.h>
#else

#import "Particle-SDK.h"

#endif

#import "ParticleSetupWebViewController.h"
#import "ParticleUserLoginViewController.h"
#import "ParticleSetupUIElements.h"

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@interface ParticleUserForgotPasswordViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property(weak, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property(weak, nonatomic) IBOutlet UIImageView *brandBackgroundImageView;
@property(weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;
@property(weak, nonatomic) IBOutlet ParticleSetupUIButton *resetPasswordButton;

@end

@implementation ParticleUserForgotPasswordViewController


- (UIStatusBarStyle)preferredStatusBarStyle {
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.brandImageView.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [UIColor clearColor];
    self.brandBackgroundImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    self.brandBackgroundImageView.image = [ParticleSetupCustomization sharedInstance].brandImageBackgroundImage;



    // Trick to add an inset from the left of the text fields
    CGRect viewRect = CGRectMake(0, 0, 10, 32);
    UIView *emptyView = [[UIView alloc] initWithFrame:viewRect];

    self.emailTextField.leftView = emptyView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyGo;
    self.emailTextField.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:16.0];

}

- (IBAction)resetPasswordButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [self trimTextFieldValue:self.emailTextField];
    [self.spinner startAnimating];

    void (^passwordResetCallback)(NSError *) = ^void(NSError *error) {

        [self.spinner stopAnimating];
        self.resetPasswordButton.userInteractionEnabled = YES;

        if (!error) {
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Auth_RequestPasswordReset"];
#endif

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ParticleSetupStrings_ForgotPassword_Prompt_EmailSent_Title message:ParticleSetupStrings_ForgotPassword_Prompt_EmailSent_Message delegate:nil cancelButtonTitle:ParticleSetupStrings_Action_Ok otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ParticleSetupStrings_ForgotPassword_Error_InvalidCredentials_Title message:ParticleSetupStrings_ForgotPassword_Error_InvalidCredentials_Message delegate:nil cancelButtonTitle:ParticleSetupStrings_Action_Ok otherButtonTitles:nil];
            [alert show];

        }
    };

    if ([self isValidEmail:self.emailTextField.text]) {
        self.resetPasswordButton.userInteractionEnabled = NO;
        if ([ParticleSetupCustomization sharedInstance].productMode) // TODO: fix that so it'll work for non-org too
        {
            [[ParticleCloud sharedInstance] requestPasswordResetForCustomer:self.emailTextField.text productId:[ParticleSetupCustomization sharedInstance].productId completion:passwordResetCallback];
        } else {
            [[ParticleCloud sharedInstance] requestPasswordResetForUser:self.emailTextField.text completion:passwordResetCallback];
        }
    } else {
        [self.spinner stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: ParticleSetupStrings_ForgotPassword_Error_InvalidEmail_Title message:ParticleSetupStrings_ForgotPassword_Error_InvalidEmail_Message delegate:nil cancelButtonTitle:ParticleSetupStrings_Action_Ok otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Auth_ForgotPasswordScreen"];
#endif
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self resetPasswordButtonTapped:self];
        return YES;

    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.delegate didRequestUserLogin:self];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate didRequestUserLogin:self];

}
@end
