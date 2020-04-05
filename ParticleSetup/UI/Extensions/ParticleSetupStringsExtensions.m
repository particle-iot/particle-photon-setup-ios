//
// Created by Raimundas Sakalauskas on 23/10/2019.
// Copyright (c) 2019 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParticleSetupMainController.h"
#import "ParticleCloud.h"

@implementation NSString (ParticleString)

- (NSString *_Nullable)particleLocalized {
    return [NSString replaceVariablesInStrings:NSLocalizedStringFromTableInBundle(self, @"ParticleSetupStrings", [ParticleSetupMainController getResourcesBundle], @"")];
}

- (NSString *_Nullable)variablesReplaced {
    return [NSString replaceVariablesInStrings:self];
}

+ (NSString *)replaceVariablesInStrings:(NSString *)value {
    value = [value stringByReplacingOccurrencesOfString:@"{{deviceName}}" withString:[ParticleSetupCustomization sharedInstance].deviceName];
    value = [value stringByReplacingOccurrencesOfString:@"{{device}}" withString:[ParticleSetupCustomization sharedInstance].deviceName];
    value = [value stringByReplacingOccurrencesOfString:@"{{brand}}" withString:[ParticleSetupCustomization sharedInstance].brandName];
    value = [value stringByReplacingOccurrencesOfString:@"{{color}}" withString:[ParticleSetupCustomization sharedInstance].listenModeLEDColorName];
    value = [value stringByReplacingOccurrencesOfString:@"{{mode button}}" withString:[ParticleSetupCustomization sharedInstance].modeButtonName];
    value = [value stringByReplacingOccurrencesOfString:@"{{network prefix}}" withString:[ParticleSetupCustomization sharedInstance].networkNamePrefix];
    value = [value stringByReplacingOccurrencesOfString:@"{{product}}" withString:[ParticleSetupCustomization sharedInstance].productName];

    value = [value stringByReplacingOccurrencesOfString:@"{deviceName}" withString:[ParticleSetupCustomization sharedInstance].deviceName];
    value = [value stringByReplacingOccurrencesOfString:@"{device}" withString:[ParticleSetupCustomization sharedInstance].deviceName];
    value = [value stringByReplacingOccurrencesOfString:@"{brand}" withString:[ParticleSetupCustomization sharedInstance].brandName];
    value = [value stringByReplacingOccurrencesOfString:@"{color}" withString:[ParticleSetupCustomization sharedInstance].listenModeLEDColorName];
    value = [value stringByReplacingOccurrencesOfString:@"{mode button}" withString:[ParticleSetupCustomization sharedInstance].modeButtonName];
    value = [value stringByReplacingOccurrencesOfString:@"{network prefix}" withString:[ParticleSetupCustomization sharedInstance].networkNamePrefix];
    value = [value stringByReplacingOccurrencesOfString:@"{product}" withString:[ParticleSetupCustomization sharedInstance].productName];

    if ([ParticleCloud sharedInstance].loggedInUsername) {
        value = [value stringByReplacingOccurrencesOfString:@"{{userName}}" withString:[ParticleCloud sharedInstance].loggedInUsername];
        value = [value stringByReplacingOccurrencesOfString:@"{userName}" withString:[ParticleCloud sharedInstance].loggedInUsername];
    }


    return value;
}

@end
