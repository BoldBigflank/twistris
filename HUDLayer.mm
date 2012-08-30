//
//  HUDLayer.mm
//  bgmmo
//
//  Created by Alex Swan on 8/28/12.
//
//

#import "HUDLayer.h"
#import "HelloWorldLayer.h"

@implementation HUDLayer

- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _statusLabel = [CCLabelTTF labelWithString:@"Lives" fontName:@"Arial" fontSize:32];
        _statusLabel.position = ccp(winSize.width* 0.85, winSize.height * 0.9);
        [self addChild:_statusLabel];
    }
    return self;
}

- (void)setStatusString:(NSString *)string {
    _statusLabel.string = string;
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [HelloWorldLayer scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:0.5 scene:scene]];
    
}

- (void)showRestartMenu:(int)score {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    message = [NSString stringWithFormat:@"Score: %i", score];
    
    CCLabelBMFont *label;
        label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:32];
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
        restartLabel = [CCLabelTTF labelWithString:@"Restart" fontName:@"Arial" fontSize:32];
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

@end
