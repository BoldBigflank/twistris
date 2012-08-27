//
//  HelloWorldLayer.m
//  bgmmo
//
//  Created by Alex Swan on 8/4/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCTouchDispatcher.h"
#import "SpriteCopter.h"
#import "GameOverScene.h"
#import "RobotUIKit/RobotUIKit.h"


// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

Copter *seeker1;
CCSprite *cocosGuy;
CCSprite *cloud;

int seekerDirection = -1;
float score = 0;


#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
    
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    _targets = [[NSMutableArray alloc] init];
    
    score = 0;
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
    // 91, 150, 239, 255
    if( (self=[super initWithColor:ccc4(91, 150, 239, 255)] )) {
        // A happy cloud
        cloud = [CCSprite spriteWithFile: @"cloud.png"];
        cloud.position = ccp( 700, 200 );
        [self addChild:cloud];

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        int minY = cloud.contentSize.height/2;
        int maxY = winSize.height - cloud.contentSize.height/2;
        int rangeY = maxY - minY;

        while([_targets count] < 4){
            int actualY = (arc4random() % rangeY) + minY;
            CCSprite *cocosGuy = [CCSprite spriteWithFile: @"Icon.png"];
            int spawnX = winSize.width + cocosGuy.contentSize.width + arc4random() % (int)winSize.width;
            cocosGuy.position = ccp( spawnX , actualY );
            [self addChild:cocosGuy];
            [_targets addObject:cocosGuy];
        }
		// do the same for our cocos2d guy, reusing the app icon as its image
//        cocosGuy = [CCSprite spriteWithFile: @"Icon.png"];
//        cocosGuy.position = ccp( 450, 300 );
//        [self addChild:cocosGuy];

        // create and initialize our seeker sprite, and add it to this layer
        seeker1 = [Copter copter];
        seeker1.position = ccp( 50, 100 );
        [self addChild:seeker1];
        

        // schedule a repeating callback on every frame
        [self schedule:@selector(nextFrame:)];
        self.isTouchEnabled = YES;        
	}
    // Sphero stuff    

	return self;
}

- (void) nextFrame:(ccTime)dt {
    // Update the score
    score += dt*10;
    int vx = seeker1.vx + score/10;
    
    
    // Send the cocos guy left
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = cloud.contentSize.height/2;
    int maxY = winSize.height - cloud.contentSize.height/2;
    int rangeY = maxY - minY;



    // Send the cloud guy left
    cloud.position = ccp(cloud.position.x - vx * dt* .8 , cloud.position.y);
    if(cloud.position.x < -1 * cloud.contentSize.width){
        int actualY = (arc4random() % rangeY) + minY;
        cloud.position = ccp(winSize.width + (cloud.contentSize.width/2), actualY);
    }
    
    // Update the copter
    seeker1.velocity = seeker1.velocity + (int)seeker1.acceleration*dt;
    if (seeker1.velocity < -640) seeker1.velocity = -640;
    seeker1.position = ccp( seeker1.position.x, seeker1.position.y + seeker1.velocity *dt);
    if (seeker1.position.y < -32 ) {
        seeker1.position = ccp( seeker1.position.x, winSize.height + seeker1.contentSize.height );
    }
    seeker1.rotation = 2 * M_PI * atan( -seeker1.velocity / vx);
    
    // Check for collisions
    CGRect copterRect = CGRectMake(
       seeker1.position.x - (seeker1.contentSize.width/2),
       seeker1.position.y - (seeker1.contentSize.height/2),
       seeker1.contentSize.width,
       seeker1.contentSize.height);

    for (CCSprite *cocosGuy in _targets) {
        cocosGuy.position = ccp(cocosGuy.position.x - vx *dt, cocosGuy.position.y);
        if(cocosGuy.position.x < -1 * cocosGuy.contentSize.width ){
            int actualY = (arc4random() % rangeY) + minY;
            int spawnX = winSize.width + cocosGuy.contentSize.width + arc4random() % (int)winSize.width;
            cocosGuy.position = ccp( spawnX , actualY );
        }
        
        CGRect cocosGuyRect = CGRectMake(
            cocosGuy.position.x - (cocosGuy.contentSize.width/2),
            cocosGuy.position.y - (cocosGuy.contentSize.height/2),
            cocosGuy.contentSize.width,
            cocosGuy.contentSize.height);
        
        if (CGRectIntersectsRect(copterRect, cocosGuyRect)) {
            NSLog(@"COLLISION");
            GameOverScene *gameOverScene = [GameOverScene node];
            [gameOverScene.layer.label setString:[NSString stringWithFormat:@"Your Score: %i", (int)score]];
            [[CCDirector sharedDirector] pushScene:gameOverScene];
        }
    }
    

    // Remove old blocks/dots
    
    // (occasionally) Add new blocks
        // Narrow the gap
        // Send them across the screen
    // (occasionally) Dot the copter's path
        // Send them across the screen
    
    
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Reverse direction of the seeker
    seeker1.acceleration = abs(seeker1.acceleration);
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // Return the direction of seeker
    seeker1.acceleration = -1 * abs(seeker1.acceleration);
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [_targets release];
    _targets = nil;
	[super dealloc];
}

-(void) onEnter
{
    [super onEnter];
    robotOnline = NO;
    [self appDidBecomeActive:nil];

}

-(void) onExit
{
    [super onExit];
    [self appWillResignActive:nil];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

// Sphero functions
-(void)setupRobotConnection {
    NSLog(@"setupRobotConnection");
    /*Try to connect to the robot*/
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
}

- (void)handleRobotOnline {
    NSLog(@"handleRobotOnline");
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        /* Send commands to Sphero Here: */
        
    }
    robotOnline = YES;
}

-(void)appDidBecomeActive:(NSNotification*)notification {
    NSLog(@"appDidBecomeActive");
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
}
-(void)appWillResignActive:(NSNotification*)notification {
    NSLog(@"appWillResignActive");
    /*When the application is entering the background we need to close the connection to the robot*/
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

@end
