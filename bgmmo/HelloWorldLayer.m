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

#define MAX_LIVES 9
#define MAX_DOTS 3
#define DISK_RADIUS 100

CCNode *center;
CCSprite *cloud;

int standardAcceleration = -1;
float score = 0;
int lives;


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
    
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
//    [self sendSetDataStreamingCommand];
//    ////Register for asynchronise data streaming packets
//    [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];

    _targets = [[NSMutableArray alloc] init];
    _dots = [[NSMutableArray alloc] init];
    score = 0;
    lives = MAX_LIVES;
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
    // 91, 150, 239, 255
    if( (self=[super initWithColor:ccc4(0, 0, 0, 255)] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        int minY = cloud.contentSize.height/2;
        int maxY = winSize.height - cloud.contentSize.height/2;
        
        CCParticleRain *starSplat = [[CCParticleRain alloc] initWithTotalParticles:300];
        starSplat.texture = [[CCTextureCache sharedTextureCache] addImage:@"star.png"];
        starSplat.duration = 1;
        starSplat.emissionRate = 3200;
        starSplat.life = 8;
        starSplat.lifeVar = 0;
        starSplat.startSize = 2;
        starSplat.startSizeVar = 1;
        starSplat.endSize = 2;
        starSplat.endSizeVar = 1;
        starSplat.angle = 180;
        starSplat.angleVar = 0;
        starSplat.rotation = 0;
        starSplat.gravity = ccp(0, 0);
        starSplat.speed = winSize.width/8;
        starSplat.speedVar = 5;
        starSplat.radialAccel = 0;
        starSplat.radialAccelVar = 0;
        starSplat.tangentialAccel = 0;
        starSplat.tangentialAccelVar = 0;
        starSplat.position = ccp(winSize.width/2, winSize.height/2);
        starSplat.posVar = ccp(winSize.width/2, winSize.height/2);
        ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
        starSplat.startColor = startColor;
        ccColor4F startColorVar = {0.2f, 0.25f, 0.2f, 0.29f};
        starSplat.startColorVar = startColorVar;
        ccColor4F endColor = {1.0f, 1.0f, 1.0f, 1.0f};
        starSplat.endColor = endColor;
        ccColor4F endColorVar = {0.0f, 0.0f, 0.0f, 0.0f};
        starSplat.endColorVar = endColorVar;
        starSplat.autoRemoveOnFinish = YES;
        [self addChild:starSplat];
        
        starField = [[CCParticleRain alloc] initWithTotalParticles:400];
        starField.texture = [[CCTextureCache sharedTextureCache] addImage:@"star.png"];
        starField.duration = -1;
        starField.life = 8;
        starField.lifeVar = 0;
        starField.startSize = 2;
        starField.startSizeVar = 1;
        starField.endSize = 2;
        starField.endSizeVar = 1;
        starField.angle = 180;
        starField.angleVar = 0;
        starField.rotation = 0;
        starField.gravity = ccp(0, 0);
        starField.speed = winSize.width/8;
        starField.speedVar = 5;
        starField.radialAccel = 0;
        starField.radialAccelVar = 0;
        starField.tangentialAccel = 0;
        starField.tangentialAccelVar = 0;
        starField.position = ccp(winSize.width, winSize.height/2);
        starField.posVar = ccp(0, winSize.height/2);
        starField.startColor = startColor;
        starField.startColorVar = startColorVar;
        starField.endColor = endColor;
        starField.endColorVar = endColorVar;
        [self addChild:starField];
        
        // The center points for the dot
        center = [CCNode node];
        center.position = CGPointMake(DISK_RADIUS +10, winSize.height/2);
        [self addChild:center];
        
        while([_targets count] < 4){
            int actualY = (arc4random() % (2 * DISK_RADIUS)) + minY + center.position.y - DISK_RADIUS;
            CCSprite *beeDude = [CCSprite spriteWithFile: @"dot.png"];
            int spawnX = winSize.width + beeDude.contentSize.width + arc4random() % (int)winSize.width;
            beeDude.position = ccp( spawnX , actualY );
            [self addChild:beeDude];
            
            // Give it a cool trail
            CCParticleMeteor *tail = [[CCParticleMeteor alloc] initWithTotalParticles:100];
            tail.texture = [[CCTextureCache sharedTextureCache] addImage:@"dot.png"];
            tail.autoRemoveOnFinish = YES;
            tail.speed = 30.0f;
            tail.duration = -1;
            tail.position = ccp(beeDude.contentSize.width/2, beeDude.contentSize.height/2);
            tail.startSize = beeDude.contentSize.height;
            tail.endSize = 10;
            tail.life = 0.6;
            tail.lifeVar = 0.675;
            tail.gravity = ccp(winSize.width, 0);
            tail.angle = 0;
            
            
            ccColor4F startColor = {0.87f, 0.51f, 0.597f, 1.0f};
            tail.startColor = startColor;
            ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
            tail.startColorVar = startColorVar;
            ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
            tail.endColor = endColor;
            ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
            tail.endColorVar = endColorVar;
            
            
            [beeDude addChild:tail];
            
            
            [_targets addObject:beeDude];
        }
		// do the same for our cocos2d guy, reusing the app icon as its image
//        beeDude = [CCSprite spriteWithFile: @"Icon.png"];
//        beeDude.position = ccp( 450, 300 );
//        [self addChild:beeDude];

        // create and initialize our seeker sprite, and add it to this layer
        
        CCSprite *ring = [CCSprite spriteWithFile:@"ring.png"];
        [center addChild:ring];
        ring.scale = 2 * DISK_RADIUS / ring.contentSize.width;
//        ring.position = ccp(  ring.contentSize.width - DISK_RADIUS, ring.scale * ring.contentSize.height/2);
        // Create the dots
        while([_dots count] < MAX_DOTS){
            
            CCSprite *dotDude = [CCSprite spriteWithFile: @"dot.png"];
            [center addChild:dotDude];
            [_dots addObject:dotDude];
        }
        
        // Space the dots
        for (CCNode *dotDude in _dots) {
            // Radians position
            int index = [_dots indexOfObject:dotDude];
            float angle = 2 * M_PI / _dots.count * index; // Degrees
            NSLog(@"angle %f, %f, %f", angle, cos(angle) * DISK_RADIUS, sin(angle) * DISK_RADIUS);
            dotDude.position = ccp( cos(angle) * DISK_RADIUS, sin(angle) * DISK_RADIUS );
            dotDude.rotation = -1 * center.rotation;
        }
        
        // schedule a repeating callback on every frame
        [self schedule:@selector(nextFrame:)];
        self.isTouchEnabled = YES;        
	}
    // Sphero stuff    

	return self;
}

- (void) nextFrame:(ccTime)dt {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    AppController *appD = (AppController *)[[UIApplication sharedApplication] delegate];
    center.rotation =  -1 * [appD currentYaw];
    for (CCSprite *dotDude in _dots) {
        dotDude.rotation = -1 * center.rotation;
    }
    if([appD hasResumed]){
        float red = min(1.0, 2 * (float)(MAX_LIVES - lives)/MAX_LIVES) ;
        float green = max(0.0, (float)lives/MAX_LIVES);
        [RKRGBLEDOutputCommand sendCommandWithRed:red green:green blue:0.0];
        appD.hasResumed = FALSE;
    }
    
    // Update the score
    score += dt*10;
    int vx = winSize.width/3 + score/3;
    
    
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
            int actualY = (arc4random() % (2 * DISK_RADIUS)) + minY + center.position.y - DISK_RADIUS;
            int spawnX = winSize.width + beeDude.contentSize.width + arc4random() % (int)winSize.width;
            beeDude.position = ccp( spawnX , actualY );
            beeDude.visible = true;
        }
        
        CGRect beeDudeRect = CGRectMake(
            beeDude.position.x - (beeDude.contentSize.width/2) + 15,
            beeDude.position.y - (beeDude.contentSize.height/2)+5,
            beeDude.contentSize.width - 15,
            beeDude.contentSize.height - 5);
        
        for(CCSprite *dotDude in _dots){
            CGPoint position = [center convertToWorldSpace:dotDude.position];
            // Relative to center
            CGRect dotDudeRect = CGRectMake(
                position.x - (dotDude.contentSize.width/2),
                position.y - (dotDude.contentSize.height/2),
                dotDude.contentSize.width,
                dotDude.contentSize.height
            );
            if (CGRectIntersectsRect(dotDudeRect, beeDudeRect)) {
                if(beeDude.visible){
                    [self createExplosionX:position.x y:position.y];
                    beeDude.visible = false;
                    lives--;
                    if(lives<0){
                        [self unschedule:@selector(nextFrame:)];
                        [self gameOverDone];
                    }
                    // Change the color of the ball
                    float red = min(1.0, 2 * (float)(MAX_LIVES - lives)/MAX_LIVES) ;
                    float green = max(0.0, (float)lives/MAX_LIVES);
                    NSLog(@"%f %f", red, green);
                    [RKRGBLEDOutputCommand sendCommandWithRed:red green:green blue:0.0];
                }
                    
                // Add dotDude to dotsToDelete
            }
            
        }

    }
    
}

-(void) createExplosionX:(float)x y:(float)y
{
    [emitter resetSystem];
    //	ParticleSystem *emitter = [RockExplosion node];
    self->emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:30];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"Icon.png"];
    
    // duration
    //	emitter.duration = -1; //continuous effect
    emitter.duration = 1;
    
    // gravity
    emitter.gravity = CGPointZero;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // speed of particles
    emitter.speed = 160;
    emitter.speedVar = 20;
    
    // radial
    emitter.radialAccel = -120;
    emitter.radialAccelVar = 0;
    
    // tagential
    emitter.tangentialAccel = 30;
    emitter.tangentialAccelVar = 0;
    
    // life of particles
    emitter.life = 1;
    emitter.lifeVar = 1;
    
    // spin of particles
    emitter.startSpin = 0;
    emitter.startSpinVar = 0;
    emitter.endSpin = 0;
    emitter.endSpinVar = 0;
    
    // color of particles
    
    ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColor = startColor;
    ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColorVar = startColorVar;
    ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColor = endColor;
    ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColorVar = endColorVar;
    
    // size, in pixels
    emitter.startSize = 20.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kParticleStartSizeEqualToEndSize;
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.life;
    // additive
    emitter.blendAdditive = YES;
    emitter.position = ccp(x,y);  // setting emitter position
    [self addChild: emitter]; // adding the emitter
    emitter.autoRemoveOnFinish = YES; // this removes/deallocs the emitter after its animation
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
    NSLog(@"onEnter");
    [super onEnter];
}

-(void) onExit
{
    NSLog(@"onExit");
    //[self appWillResignActive:nil];

    [super onExit];
}
-(void) onEnterTransitionDidFinish
{
    NSLog(@"onEnterTransitionDidFinish");
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

//        NSLog(@"Yaw %f", attitudeData.yaw);
        center.rotation =  -attitudeData.yaw;
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
