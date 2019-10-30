//
//  ParticleSetupCustomization.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import "ParticleSetupCustomization.h"
#import "ParticleSetupMainController.h"
#import "ParticleSetupStrings.h"


@interface UIColor (withDecimalRGB) // TODO: move to category in helpers
+ (UIColor *)colorWithRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b;
@end

@implementation UIColor (withDecimalRGB) // TODO: move to category in helpers
+ (UIColor *)colorWithRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b {
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
@end

@implementation ParticleSetupCustomization

+ (instancetype)sharedInstance {
    static ParticleSetupCustomization *sharedInstance = nil;
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}


- (instancetype)init {
    if (self = [super init]) {
        // set 'useAppResources' to YES if you want to supply the storyboard and asset catalog from
        // the app bundle instead of using the SDK's built-in version.  Your storyboard and asset catalog
        // must be named 'setup' or change it by setting 'appResourcesStoryboardName' to your liking.
        self.useAppResources = NO;
        self.appResourcesStoryboardName = @"setup";

        // Defaults
        //self.deviceName = ParticleSetupStrings_Default_DeviceName;
        self.brandName = @"Particle";
        //self.brandImage = [ParticleSetupMainController loadImageFromResourceBundle:@"spark-logo-head"];
        self.brandImageBackgroundColor = [UIColor colorWithRed:229 green:229 blue:237];
        self.brandImageBackgroundImage = nil;

        //self.modeButtonName = ParticleSetupStrings_Default_ModeButton;
        self.networkNamePrefix = @"Photon";
        //self.listenModeLEDColorName = ParticleSetupStrings_Default_ListenModeLEDColorName;
        self.fontSizeOffset = 0;

        self.normalTextColor = [UIColor colorWithRed:28 green:26 blue:25];
        self.pageBackgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0f];
        self.linkTextColor = [UIColor blueColor];
        self.elementBackgroundColor = [UIColor colorWithRed:0 green:165 blue:231];
        self.elementTextColor = [UIColor whiteColor];

        self.normalTextFontName = @"HelveticaNeue";
        self.boldTextFontName = @"HelveticaNeue-Bold";
        self.headerTextFontName = @"HelveticaNeue-Light";

        self.tintSetupImages = NO;
        self.lightStatusAndNavBar = YES;

        self.productId = 0;
        self.productMode = NO;
        self.productName = @"Photon";
        self.allowPasswordManager = YES;

        self.allowSkipAuthentication = NO;
        //self.skipAuthenticationMessage = ParticleSetupStrings_Default_SkipAuthenticationText;
        self.disableLogOutOption = NO;

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

- (NSString *)deviceName {
    if (_deviceName == nil){
        _deviceName = ParticleSetupStrings_Default_DeviceName;
    }
    return _deviceName;
}

- (NSString *)modeButtonName {
    if (_modeButtonName == nil) {
        _modeButtonName = ParticleSetupStrings_Default_ModeButton;
    }
    return _modeButtonName;
}

- (NSString *)listenModeLEDColorName {
    if (_listenModeLEDColorName == nil) {
        _listenModeLEDColorName = ParticleSetupStrings_Default_ListenModeLEDColorName;
    }
    return _listenModeLEDColorName;
}

- (NSURL *)termsOfServiceLinkURL {
    if (_termsOfServiceLinkURL == nil) {
        _termsOfServiceLinkURL = [NSURL URLWithString:ParticleSetupStrings_Default_TermsOfServiceLinkURL];
    }
    return _termsOfServiceLinkURL;
}

- (NSURL *)privacyPolicyLinkURL {
    if (_privacyPolicyLinkURL == nil){
        _privacyPolicyLinkURL = [NSURL URLWithString:ParticleSetupStrings_Default_PrivacyPolicyLinkURL];
    }
    return _privacyPolicyLinkURL;
}

- (NSURL *)troubleshootingLinkURL {
    if (_troubleshootingLinkURL == nil) {
        _troubleshootingLinkURL = [NSURL URLWithString:ParticleSetupStrings_Default_TroubleshootingLinkURL];
    }
    return _troubleshootingLinkURL;
}

- (NSString *)skipAuthenticationMessage {
    if (_skipAuthenticationMessage == nil) {
        _skipAuthenticationMessage = ParticleSetupStrings_Default_SkipAuthenticationText;
    }
    return _skipAuthenticationMessage;
}


@end
