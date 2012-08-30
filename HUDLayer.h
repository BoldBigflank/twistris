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
}

- (void)showRestartMenu:(int)score;
- (void)setStatusString:(NSString *)string;

@end