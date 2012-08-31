//
//  HUDLayer.h
//  bgmmo
//
//  Created by Alex Swan on 8/28/12.
//
//

#import "cocos2d.h"

@interface HUDLayer : CCLayer {
    CCLabelBMFont * _statusLabel;
    CCLabelBMFont * _scoreLabel;
    
    CCMenu *_spheroMenu;
    CCMenu *_startMenu;
}

- (void)showSpheroMenu:(bool)v;
- (void)showRestartMenu:(int)score;
- (void)setStatusString:(NSString *)string;
- (void)setScoreString:(NSString *)string;


@end