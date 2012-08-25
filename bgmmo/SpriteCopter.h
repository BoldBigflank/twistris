//
//  SpriteCopter.h
//  bgmmo
//
//  Created by Alex Swan on 8/22/12.
//
//

#import "cocos2d.h"

@interface SpriteCopter : CCSprite {
    float _velocity;
    float _vx;
    float _acceleration;
}

@property (nonatomic, assign) float velocity;
@property (nonatomic, assign) float vx;
@property (nonatomic, assign) float acceleration;

@end

@interface Copter : SpriteCopter {
}
+(id)copter;
@end
