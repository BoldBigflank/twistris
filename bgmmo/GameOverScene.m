//
//  GameOverScene.m
//  bgmmo
//
//  Created by Alex Swan on 8/24/12.
//
//

#import "GameOverScene.h"
#import "HelloWorldLayer.h"
#import "CCTouchDispatcher.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label = _label;

-(id) init
{
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
        _label.color = ccc3(0,0,0);
        _label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_label];
        
//        [self runAction:[CCSequence actions:
//                         [CCDelayTime actionWithDuration:3],
//                         [CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)],
//                         nil]];
        self.isTouchEnabled = YES;
        
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self gameOverDone];
}

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)gameOverDone {
    //[[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    
}

- (void)dealloc {
    [_label release];
    _label = nil;
    [super dealloc];
}

@end