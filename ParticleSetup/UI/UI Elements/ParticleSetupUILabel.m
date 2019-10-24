//
//  ParticleSetupUILabel.m
//  teacup-ios-app
//
//  Created by Ido on 1/16/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

#import "ParticleSetupUILabel.h"
#import "ParticleSetupCustomization.h"
@implementation ParticleSetupUILabel

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
//        [self replacePredefinedText];
        [self setType:self.type];
        return self;
    }
    return nil;
    
}

-(void)setType:(NSString *)type
{
    if ((type) && ([type isEqualToString:@"bold"]))
    {
        self.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].boldTextFontName size:self.font.pointSize+[ParticleSetupCustomization sharedInstance].fontSizeOffset];
        self.textColor = [ParticleSetupCustomization sharedInstance].normalTextColor;
    }
    else if ((type) && ([type isEqualToString:@"header"]))
    {
        self.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.font.pointSize+[ParticleSetupCustomization sharedInstance].fontSizeOffset];
        self.textColor = [ParticleSetupCustomization sharedInstance].normalTextColor;
    }
    else
    {
        self.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:self.font.pointSize+[ParticleSetupCustomization sharedInstance].fontSizeOffset];
        self.textColor = [ParticleSetupCustomization sharedInstance].normalTextColor;
        
    }

    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

@end
