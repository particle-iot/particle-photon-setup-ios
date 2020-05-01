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
#import <WebKit/WebKit.h>

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@interface ParticleSetupWebViewController () <WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property(weak, nonatomic) IBOutlet WKWebView *webView;
@property(weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;

@end

@implementation ParticleSetupWebViewController


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //Force light mode on iOS 13
    if (@available(iOS 13.0, *)) {
        if ([self respondsToSelector:NSSelectorFromString(@"overrideUserInterfaceStyle")]) {
            [self setValue:@(UIUserInterfaceStyleLight) forKey:@"overrideUserInterfaceStyle"];
        }
    }

    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfiguration];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.webView belowSubview:self.spinner];

    [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    [self.webView.topAnchor constraintEqualToAnchor:self.navBar.bottomAnchor].active = YES;

    self.webView.navigationDelegate = self;


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

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.spinner startAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.spinner stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.spinner stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.spinner stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"DeviceSetup_WebviewScreen"];
#endif
}


@end
