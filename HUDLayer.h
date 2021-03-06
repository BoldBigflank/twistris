//
//  HUDLayer.h
//  bgmmo
//
//  Created by Alex Swan on 8/28/12.
//
//

#import "cocos2d.h"


@interface HUDLayer : CCLayer {
    CCLabelBMFont * _scoreLabel;
    CCLabelBMFont * _highScoreLabel;

    CCMenu *_spheroMenu;
    CCMenu *_startMenu;
}

- (void)showSpheroMenu:(bool)v;
- (void)showRestartMenu:(int)score;
- (void)setScoreString:(NSString *)string;
- (void)setHighScoreString:(NSString *)string;


@end