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

#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50

CCNode *center;
CCSprite *beeDude;
CCSprite *cloud;

int standardAcceleration = -1;
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
    _dots = [[NSMutableArray alloc] init];
    maxDots = 5;
    score = 0;
    radius = 100;
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
    // 91, 150, 239, 255
    if( (self=[super initWithColor:ccc4(0, 0, 0, 255)] )) {
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
            CCSprite *beeDude = [CCSprite spriteWithFile: @"bee.png"];
            int spawnX = winSize.width + beeDude.contentSize.width + arc4random() % (int)winSize.width;
            beeDude.position = ccp( spawnX , actualY );
            beeDude.rotation = -25;
            [self addChild:beeDude];
            [_targets addObject:beeDude];
        }
		// do the same for our cocos2d guy, reusing the app icon as its image
//        beeDude = [CCSprite spriteWithFile: @"Icon.png"];
//        beeDude.position = ccp( 450, 300 );
//        [self addChild:beeDude];

        // create and initialize our seeker sprite, and add it to this layer
        
        // The center points for the dot
        center = [CCNode node];
        center.position = CGPointMake(radius+10, winSize.height/2);
        [self addChild:center];
        
        // Create the dots
        while([_dots count] < maxDots){
            
            CCSprite *dotDude = [CCSprite spriteWithFile: @"dot.png"];
            [center addChild:dotDude];
            [_dots addObject:dotDude];
        }
        
        // Space the dots
        for (CCNode *dotDude in _dots) {
            // Radians position
            int index = [_dots indexOfObject:dotDude];
            float angle = 2 * M_PI / _dots.count * index; // Degrees
            NSLog(@"angle %f, %f, %f", angle, cos(angle) * radius, sin(angle) * radius);
            dotDude.position = ccp( cos(angle) * radius, sin(angle) * radius );
            dotDude.rotation = -1 * center.rotation;
        }
        
        // schedule a repeating callback on every frame
        //[self schedule:@selector(nextFrame:)];
        self.isTouchEnabled = YES;        
	}
    // Sphero stuff    

	return self;
}

- (void) nextFrame:(ccTime)dt {
    // Update the score
    score += dt*10;
    int vx = score/3;
    
    
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
    
    // Check for collisions

    for (CCSprite *beeDude in _targets) {
        beeDude.position = ccp(beeDude.position.x - vx *dt, beeDude.position.y);
        if(beeDude.position.x < -1 * beeDude.contentSize.width ){
            int actualY = (arc4random() % rangeY) + minY;
            int spawnX = winSize.width + beeDude.contentSize.width + arc4random() % (int)winSize.width;
            beeDude.position = ccp( spawnX , actualY );
        }
        
        CGRect beeDudeRect = CGRectMake(
            beeDude.position.x - (beeDude.contentSize.width/2) + 15,
            beeDude.position.y - (beeDude.contentSize.height/2)+5,
            beeDude.contentSize.width - 15,
            beeDude.contentSize.height - 5);
        
        if (CGRectIntersectsRect(copterRect, beeDudeRect)) {
            NSLog(@"COLLISION");
            [self unschedule:@selector(nextFrame:)];
            [self runAction:[CCSequence actions:
                            [CCCallFunc actionWithTarget:self selector:@selector(blowUpCopter)],
                             [CCDelayTime actionWithDuration:3],
                             [CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)],
                             nil]];
        }
    }
    

    // Remove old blocks/dots
    
    // (occasionally) Add new blocks
        // Narrow the gap
        // Send them across the screen
    // (occasionally) Dot the copter's path
        // Send them across the screen
    
    
}

- (void)blowUpCopter {
    sun = [[CCParticleFire alloc] initWithTotalParticles:300];
    sun.texture = [[CCTextureCache sharedTextureCache] addImage:@"copter.png"];
    sun.autoRemoveOnFinish = YES;
    sun.speed = 30.0f;
    sun.duration = 0.5f;
    sun.position = ccp(50, 50);
    sun.startSize = 5;
    sun.endSize = 80;
    sun.life = 0.6;
    [self addChild:sun];
}

- (void)gameOverDone {
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:[NSString stringWithFormat:@"Your Score: %i", (int)score]];
    [[CCDirector sharedDirector] pushScene:gameOverScene];
    
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Reverse direction of the seeker
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // Return the direction of seeker
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
}

- (void)handleRobotOnline {
    NSLog(@"handleRobotOnline");
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        /* Send commands to Sphero Here: */
        [self schedule:@selector(nextFrame:)];
        [RKBackLEDOutputCommand sendCommandWithBrightness:1.0];
        
        [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
        
        [self sendSetDataStreamingCommand];
        ////Register for asynchronise data streaming packets
        [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];
        
        [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    
    // Turn off data streaming
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:0
                                                   packetFrames:0
                                                     sensorMask:RKDataStreamingMaskOff
                                                    packetCount:0];
    // Unregister for async data packets
    [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
    
    // Restore stabilization (the control unit)
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
    
    // Close the connection
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
    
    robotOnline = NO;
}

-(void)sendSetDataStreamingCommand {
    
    // Requesting the Accelerometer X, Y, and Z filtered (in Gs)
    //            the IMU Angles roll, pitch, and yaw (in degrees)
    //            the Quaternion data q0, q1, q2, and q3 (in 1/10000) of a Q
    RKDataStreamingMask mask =  RKDataStreamingMaskAccelerometerFilteredAll |
    RKDataStreamingMaskIMUAnglesFilteredAll   |
    RKDataStreamingMaskQuaternionAll;
    
    // Note: If your ball has Firmware < 1.20 then these Quaternions
    //       will simply show up as zeros.
    
    // Sphero samples this data at 400 Hz.  The divisor sets the sample
    // rate you want it to store frames of data.  In this case 400Hz/40 = 10Hz
    uint16_t divisor = 40;
    
    // Packet frames is the number of frames Sphero will store before it sends
    // an async data packet to the iOS device
    uint16_t packetFrames = 1;
    
    // Count is the number of async data packets Sphero will send you before
    // it stops.  You want to register for a finite count and then send the command
    // again once you approach the limit.  Otherwise data streaming may be left
    // on when your app crashes, putting Sphero in a bad state.
    uint8_t count = TOTAL_PACKET_COUNT;
    
    // Reset finite packet counter
    packetCounter = 0;
    
    // Send command to Sphero
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:divisor
                                                   packetFrames:packetFrames
                                                     sensorMask:mask
                                                    packetCount:count];
    
}

- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData
{
    // Need to check which type of async data is received as this method will be called for
    // data streaming packets and sleep notification packets. We are going to ingnore the sleep
    // notifications.
    if ([asyncData isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        
        // If we are getting close to packet limit, request more
        packetCounter++;
        if( packetCounter > (TOTAL_PACKET_COUNT-PACKET_COUNT_THRESHOLD)) {
            [self sendSetDataStreamingCommand];
        }
        
        // Received sensor data, so display it to the user.
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)asyncData;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];
//        RKAccelerometerData *accelerometerData = sensorsData.accelerometerData;
        RKAttitudeData *attitudeData = sensorsData.attitudeData;
//        RKQuaternionData *quaternionData = sensorsData.quaternionData;

        NSLog(@"Yaw %f", attitudeData.yaw);
        center.rotation = -attitudeData.yaw;
        for (CCSprite *dotDude in _dots) {
            dotDude.rotation = -1 * center.rotation;
        }
        //[RKCalibrateCommand sendCommandWithHeading:0.0];
        
        // Print data to the text fields
//        self.xValueLabel.text = [NSString stringWithFormat:@"%.6f", accelerometerData.acceleration.x];
//        self.yValueLabel.text = [NSString stringWithFormat:@"%.6f", accelerometerData.acceleration.y];
//        self.zValueLabel.text = [NSString stringWithFormat:@"%.6f", accelerometerData.acceleration.z];
//        self.pitchValueLabel.text = [NSString stringWithFormat:@"%.0f", attitudeData.pitch];
//        self.rollValueLabel.text = [NSString stringWithFormat:@"%.0f", attitudeData.roll];
//        self.yawValueLabel.text = [NSString stringWithFormat:@"%.0f", attitudeData.yaw];
//        self.q0ValueLabel.text = [NSString stringWithFormat:@"%d", quaternionData.quaternions.q0];
//        self.q1ValueLabel.text = [NSString stringWithFormat:@"%d", quaternionData.quaternions.q1];
//        self.q2ValueLabel.text = [NSString stringWithFormat:@"%d", quaternionData.quaternions.q2];
//        self.q3ValueLabel.text = [NSString stringWithFormat:@"%d", quaternionData.quaternions.q3];
    }
}

@end
