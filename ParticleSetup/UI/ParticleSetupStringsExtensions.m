//
// Created by Raimundas Sakalauskas on 23/10/2019.
// Copyright (c) 2019 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParticleSetupMainController.h"

@implementation NSString (ParticleString)

- (NSString * _Nullable)particleLocalized {
    return NSLocalizedStringFromTableInBundle(self, @"ParticleSetupStrings", [ParticleSetupMainController getResourcesBundle], @"");
}

@end
