//
//  ParticleSetupVideoViewController.m
//  Pods
//
//  Created by Ido on 6/15/15.
//
//

#import "ParticleSetupVideoViewController.h"
#import "ParticleSetupCustomization.h"

#import <AVFoundation/AVFoundation.h>

@interface ParticleSetupVideoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation ParticleSetupVideoViewController {
    AVPlayerLayer *_layer;
    AVPlayer *_player;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Device Setup: How-To video screen activity"];
#endif
    
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissPlayer];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Device Setup: How-To video screen activity"];
#endif
   
    
    if (self.videoFilePath)
    {

        NSArray *videoFilenameArr = [self.videoFilePath componentsSeparatedByString:@"."];
        NSString *path = [[NSBundle mainBundle] pathForResource:videoFilenameArr[0] ofType:videoFilenameArr[1]];

        NSURL *url = [NSURL fileURLWithPath:path];
        _player = [AVPlayer playerWithURL:url];

        _layer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;

        _layer.affineTransform = CGAffineTransformConcat(_layer.affineTransform, CGAffineTransformMakeRotation(M_PI_2));
        _layer.frame = self.view.bounds;
        [self.view.layer addSublayer:_layer];


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_player.currentItem];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFail:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:_player.currentItem];


        [self.view bringSubviewToFront:self.closeButton];
        [_player play];
    }
}

- (void)itemDidFail:(NSNotification *)notification {
    NSLog(@"Failed to play video");
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    [self dismissPlayer];
}

- (void)enterBackground:(NSNotification *)notification {
    [_player pause];
}

- (void)enterForeground:(NSNotification *)notification {
    [_player play];
}



-(void)dismissPlayer {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    [_player pause];
    [_layer removeFromSuperlayer];

    _player = nil;
    _layer = nil;

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
