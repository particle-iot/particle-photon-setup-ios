//
//  ParticleSetupCustomization.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import "ParticleSetupCustomization.h"
#import "ParticleSetupMainController.h"



@interface UIColor(withDecimalRGB) // TODO: move to category in helpers
+(UIColor *)colorWithRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b;
@end

@implementation UIColor(withDecimalRGB) // TODO: move to category in helpers
+(UIColor *)colorWithRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b
{
    return [UIColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:1.0f];
}
@end

@implementation ParticleSetupCustomization

@synthesize brandImage = _brandImage;

+(instancetype)sharedInstance
{
    static ParticleSetupCustomization *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
        {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
  
}



-(instancetype)init
{
    if (self = [super init])
    {
        // Defaults
        self.deviceName = @"Particle device";
//        self.deviceImage = [UIImage imageNamed:@"photon" inBundle:[ParticleSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        self.brandName = @"Particle";
//        self.brandImage = [UIImage imageNamed:@"spark-logo-head" inBundle:[ParticleSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        _brandImage = nil;
//        self.brandImageBackgroundColor = [UIColor colorWithRed:0.79f green:0.79f blue:0.79f alpha:1.0f];
        self.brandImageBackgroundColor = [UIColor colorWithRed:229 green:229 blue:237];
      
        self.modeButtonName = @"Setup button";
        self.networkNamePrefix = @"Photon";
        self.listenModeLEDColorName = @"blue";
//        self.appName = self.brandName;// @"ParticleSetup";
        self.fontSizeOffset = 0;
        
        self.privacyPolicyLinkURL = [NSURL URLWithString:@"https://www.particle.io/legal/privacy"];
        self.termsOfServiceLinkURL = [NSURL URLWithString:@"https://www.particle.io/legal/terms-of-service"];
        self.forgotPasswordLinkURL = [NSURL URLWithString:@"https://login.particle.io/forgot"];
        self.troubleshootingLinkURL = [NSURL URLWithString:@"https://community.spark.io/t/spark-core-troubleshooting-guide-spark-team/696"];
        // TODO: add default HTMLs
        
//        self.normalTextColor = [UIColor blackColor];
        self.normalTextColor = [UIColor colorWithRed:28 green:26 blue:25];
        self.pageBackgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0f];
//        self.pageBackgroundColor = [UIColor colorWithRed:250 green:250 blue:250];
        self.linkTextColor = [UIColor blueColor];
//        self.linkTextColor = [UIColor colorWithRed:6 green:165 blue:226];
//        self.errorTextColor = [UIColor redColor];
//        self.errorTextColor = [UIColor colorWithRed:254 green:71 blue:71];
//        self.elementBackgroundColor = [UIColor colorWithRed:0.84f green:0.32f blue:0.07f alpha:1.0f];
        self.elementBackgroundColor = [UIColor colorWithRed:0 green:165 blue:231];
        self.elementTextColor = [UIColor whiteColor];
        
        self.normalTextFontName = @"HelveticaNeue";
        self.boldTextFontName = @"HelveticaNeue-Bold";
        self.headerTextFontName = @"HelveticaNeue-Light";
        
        self.tintSetupImages = NO;
        self.lightStatusAndNavBar = YES;
        
//        self.organization = NO;
        self.productId = 0;
        self.productMode = NO;
//        self.organizationSlug = @"particle";
//        self.organizationName = @"Particle";
//        self.productSlug = @"photon";
        self.productName = @"Photon";
        self.allowPasswordManager = YES;

        // set 'useAppResources' to YES if you want to supply the storyboard and asset catalog from
        // the app bundle instead of using the SDK's built-in version.  Your storyboard and asset catalog
        // must be named 'setup' or change it by setting 'appResourcesRefName' to your liking.
        self.useAppResources = NO;
        self.appResourcesRefName = @"setup";
      
        self.allowSkipAuthentication = NO;
        self.skipAuthenticationMessage = @"Skipping authentication will allow you to configure Wi-Fi credentials to your device but it will not be claimed to your account. Are you sure you want to skip authentication?";
        self.disableLogOutOption = NO;
      
        // translatable terms section
        self.bizAccountLabelText = @"This is a business account";
        self.personalAccountLabelText = @"This is a personal account";
      
        self.resultSuccess_Short = @"Setup completed successfully";
        self.resultSuccess_Long = @"Congrats! You've successfully set up your {device}.";
        self.resultOffLine_Short = @"Setup completed";
        self.resultOffLine_Long = @"Your device has been successfully claimed to your account, however it is offline. If the device was already claimed before this setup, then the Wi-Fi connection may have failed, and you should try setup again.";
        self.resultNotClaimed_Short = @"Setup completed";
        self.resultNotClaimed_Long = @"Setup was successful, but since you do not own this device we cannot know if the {device} has connected to the Internet. If you see the LED breathing cyan this means it worked! If not, please restart the setup process.";
        self.resultFailed_Short = @"Setup failed";
        self.resultFailed_Long = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials, please try setup process again.";

        self.resultFailedToDisconnect_Short = @"Oops!";
        self.resultFailedToDisconnect_Long = @"Setup process couldn't disconnect from the {device} Wi-fi network. This is an internal problem with the device, so please try running setup again after resetting your {device} and putting it back in listen mode (blinking blue LED) if needed.";
      
        self.resultFailedToConfigure_Short = @"Error!";
        self.resultFailedToConfigure_Long = @"Setup process couldn't configure the Wi-Fi credentials for your {device}, please try running setup again after resetting your {device} and putting it back in blinking blue listen mode if needed.";
      
        self.resultFailedConnectionLost_Short = @"Uh oh!";
        self.resultFailedConnectionLost_Long = @"Setup lost connection to the device before finalizing configuration process, please try running setup again after putting {device} back in blinking blue listen mode.";
      
        self.alertFirmware_Title = @"Firmware update";
        self.alertFirmware_Message = @"If this is the first time you are setting up this device it might blink its LED in magenta color for a while, this means the device is currently updating its firmware from the cloud to the latest version. Please be patient and do not press the reset button. Device LED will breathe cyan once update has completed and it has come online.";
        self.alertFirmware_CancelBtn = @"Understood";
      
        self.alertPassword_Title = @"Invalid password";
        self.alertPassword_Message = @"Password must be %d characters or longer";
        self.alertPassword_CancelBtn = @"OK";
      
        self.alertPwdResetWithEmail_Title = @"Reset password";
        self.alertPwdResetWithEmail_Message = @"Instuctions how to reset your password will be sent to the provided email address. Please check your email and continue according to instructions.";
        self.alertPwdResetWithEmail_CancelBtn = @"OK";
      
        self.alertPwdResetNoEmail_Title = @"Reset password";
        self.alertPwdResetNoEmail_Message = @"Could not find a user with supplied email address, please check the address supplied or create a new user via signup screen";
        self.alertPwdResetNoEmail_CancelBtn = @"OK";
      
        self.alertLoginFailed_Title = @"Cannot Sign In";
        self.alertLoginFailed_Message = @"Incorrect username and/or pasword";
        self.alertLoginFailed_OKBtn = @"OK";
      
        self.alertInvalidEmail_Title = @"Cannot Sign In";
        self.alertInvalidEmail_Message = @"Invalid email address";
        self.alertInvalidEmail_OKBtn = @"OK";
      
        self.alertPwdLengthError_Title = @"Error";
        self.alertPwdLengthError_Message = @"Password must be at least 8 characters long";
        self.alertPwdLengthError_OKBtn = @"OK";
      
        self.alertPwdMatchError_Title = @"Error";
        self.alertPwdMatchError_Message = @"Passwords do not match";
        self.alertPwdMatchError_OKBtn = @"OK";
      
        self.alertSignUpError_Title = @"Could not signup";
        self.alertSignUpError_Message = @"Make sure your user email does not already exist and that you have entered the activation code correctly and that it was not already used";
        self.alertSignUpError_OKBtn = @"OK";
      return self;
    }
    
    return nil;
}

-(UIImage *)brandImage {
  if (_brandImage == nil) {
    _brandImage = [ParticleSetupMainController loadImageFromResourceBundle:@"spark-logo-head"];
  }
  return _brandImage;
}

-(void)setBrandImage:(UIImage *)brandImage {
  if (_brandImage != brandImage)
    _brandImage = brandImage;
}
@end
