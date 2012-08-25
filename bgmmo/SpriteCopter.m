//
//  SpriteCopter.m
//  bgmmo
//
//  Created by Alex Swan on 8/22/12.
//
//

#import "SpriteCopter.h"

@implementation SpriteCopter

@synthesize velocity = _velocity;
@synthesize vx = _vx;
@synthesize acceleration = _acceleration;

@end

@implementation Copter

+ (id)copter {
    
    Copter *copter = nil;
    if ((copter = [[[super alloc] initWithFile: @"copter.png"] autorelease])) {
        copter.velocity = 100;
        copter.vx = 100;
        copter.acceleration = -400;
        
    }
    return copter;
    
}

@end