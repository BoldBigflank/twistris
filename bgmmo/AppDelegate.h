//
//  AppDelegate.h
//  bgmmo
//
//  Created by Alex Swan on 8/4/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "RobotKit/RobotKit.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
    int  packetCounter;
	CCDirectorIOS	*director_;							// weak ref
}

-(void)setupRobotConnection;

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic) BOOL robotOnline;
@property (nonatomic) BOOL hasResumed;
@property (nonatomic) float currentYaw;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
