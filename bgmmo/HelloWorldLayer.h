//
//  HelloWorldLayer.h
//  bgmmo
//
//  Created by Alex Swan on 8/4/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "HUDLayer.h"

#import "AppDelegate.h"

enum GameStatePP {
    kGameStatePlaying,
    kGameStatePaused
};

// Sphero stuff
#import "RobotKit/RobotKit.h"


// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    NSMutableArray *_targets;
    NSMutableArray *_dots;
    
    float score;
    HUDLayer * _hud;
    BOOL robotOnline;
    CCParticleSystem *starField;
    CCParticleSystem *emitter;
    int  packetCounter;
    int maxDots;
    int radius;
    int highScore;
    
    UIViewController *viewController;
    enum GameStatePP _state;
    
    CCLabelTTF *_label;   
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (id)initWithHUD:(HUDLayer *)hud;
- (void) resetGame;

@property(nonatomic) enum GameStatePP state;

@end