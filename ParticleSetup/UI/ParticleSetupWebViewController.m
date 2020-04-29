//
//  ParticleSetupWebViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import "ParticleSetupWebViewController.h"
#import "ParticleSetupCustomization.h"
#import "ParticleSetupUIElements.h"

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@property(weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;

@end

@implementation ParticleSetupWebViewController


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    if (self.link) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.link cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0f]];
    } else {
        if (self.htmlFilename) {
            NSString *path = [[NSBundle mainBundle] pathForResource:self.htmlFilename ofType:@"html" inDirectory:self.htmlFileDirectory];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            [self.webView loadHTMLString:htmlString baseURL:baseURL];
        }
    }

    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


    [self.spinner stopAnimating];
}

}

    [self.spinner stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"DeviceSetup_WebviewScreen"];
#endif
}


@end
