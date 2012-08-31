//
//  SpriteCopter.h
//  bgmmo
//
//  Created by Alex Swan on 8/22/12.
//
//

#import "cocos2d.h"

@interface DotDude : CCSprite {
    int _hp;
    int _size;
}

+ (id)dotDudeWithSize:(int)size hp:(int)hp;

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int size;

@end