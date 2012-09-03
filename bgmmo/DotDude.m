//
//  SpriteCopter.m
//  bgmmo
//
//  Created by Alex Swan on 8/22/12.
//
//

#import "DotDude.h"

@implementation DotDude

@synthesize hp = _hp;
@synthesize size = _size;

+ (id)dotDudeWithSize:(int)size hp:(int)hp {
    DotDude *dotDude = nil;
    ccColor3B dotColor = {255, 255, 255};
    if((dotDude = [[self spriteWithFile:@"blank.png"] autorelease]) ){
        [dotDude setTextureRect:CGRectMake( 0, 0, size, size)];
        dotDude.hp = hp;
        dotDude.color = dotColor;
    }
    return dotDude;
    
}

@end