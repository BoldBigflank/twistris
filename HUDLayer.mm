//
//  HUDLayer.mm
//  bgmmo
//
//  Created by Alex Swan on 8/28/12.
//
//

#import "HUDLayer.h"
#import "HelloWorldLayer.h"
#import "AppDelegate.h"

@class AppController;

@implementation HUDLayer

- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        _scoreLabel = [CCLabelTTF labelWithString:@"Score" fontName:@"Arial" fontSize:32];
        _scoreLabel.position = ccp(winSize.width * 0.15, winSize.height * 0.9);
        [self addChild:_scoreLabel];
        
        // Sphero button
        CCMenuItem *spheroMenuItem = [CCMenuItemImage
                                      itemWithNormalImage:@"sphero.png" selectedImage:@"sphero-sel.png"
                                      target:self selector:@selector(spheroButtonTapped:)];
        spheroMenuItem.contentSize = CGSizeMake(30.0, 30.0);
        spheroMenuItem.position = ccp(15, winSize.height-15);
                
        _spheroMenu = [CCMenu menuWithItems:spheroMenuItem, nil];
        _spheroMenu.position = CGPointZero;
        //_spheroMenu.visible = false;
        [self addChild:_spheroMenu];
        
    }
    return self;
}

-(void)showSpheroMenu:(bool)v {
    _spheroMenu.visible = v;
    
}

- (void)spheroButtonTapped:(id)sender {
    AppController *appD = (AppController *)[[UIApplication sharedApplication] delegate];
    if( [appD robotOnline] == NO ) [appD setupRobotConnection];
}

- (void)setScoreString:(NSString *)string {
    _scoreLabel.string = string;
}

- (void)restartTapped:(id)sender {
    // Reload the current scene
//    CCScene *scene = [HelloWorldLayer scene];
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:0.5 scene:scene]];
    [[[[CCDirector sharedDirector] runningScene]getChildByTag:111]performSelector:@selector(resetGame)];
    [self removeChild:_startMenu cleanup:YES];
    
}

- (void)showRestartMenu:(int)score {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    message = (score > 0) ? [NSString stringWithFormat:@"Score: %i", score] : @"";
    
    CCLabelBMFont *label;
    label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:32];
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    CCMenuItemLabel *labelItem = [CCMenuItemLabel itemWithLabel:label];
//    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
        restartLabel = [CCLabelTTF labelWithString:@"New Game" fontName:@"Arial" fontSize:32];
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    _startMenu = [CCMenu menuWithItems:restartItem, labelItem, nil];
    _startMenu.position = CGPointZero;
    [self addChild:_startMenu z:10];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

@end
