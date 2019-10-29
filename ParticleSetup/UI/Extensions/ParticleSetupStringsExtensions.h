//
// Created by Raimundas Sakalauskas on 22/10/2019.
// Copyright (c) 2019 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ParticleString)

- (NSString *_Nullable)particleLocalized;

+ (NSString *)replaceVariablesInStrings:(NSString *)value;

@end