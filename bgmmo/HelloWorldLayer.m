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
#import "DotDude.h"
#import "GameOverScene.h"
#import "RobotUIKit/RobotUIKit.h"
#import "SimpleAudioEngine.h"


// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "HUDLayer.h"

#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50

#define MAX_HP 9
#define MAX_DOTS 3
#define MAX_BEES 4
#define DOT_RATIO .2
#define RADIUS_RATIO .2

CCNode *center;
CCSprite *cloud;

float score = 0;
int lives;
int radius;
bool gameInProgress;

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	
    CCScene *scene = [CCScene node];
    
    HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    HelloWorldLayer *layer = [[[HelloWorldLayer alloc] initWithHUD:hud] autorelease];
    [scene addChild:layer];

    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];

    return scene;
}

// Replace beginning of init with the following
- (id)initWithHUD:(HUDLayer *)hud
{
    if( (self=[super initWithColor:ccc4(0, 0, 0, 255)] )) {
        self.tag = 111;
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"dreaming.wav"];
        _hud = hud;
        _targets = [[NSMutableArray alloc] init];
        _dots = [[NSMutableArray alloc] init];
        gameInProgress = NO;
        
        // always call "super" init
        // Apple recommends to re-assign "self" with the "super's" return value
        // 91, 150, 239, 255
    
        [_hud setScoreString:[NSString stringWithFormat:@""]];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        radius = winSize.width * RADIUS_RATIO;
        
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
        center.position = CGPointMake(radius +10, winSize.height/2);
        [self addChild:center];
        
        center.scale = .1;
        [center runAction:[CCScaleTo actionWithDuration:1 scale:1.0]];
        
        CCSprite *ring = [CCSprite spriteWithFile:@"ring.png"];
        [center addChild:ring];
        ring.scale = 2 * radius / ring.contentSize.width;
        //        ring.position = ccp(  ring.contentSize.width - radius, ring.scale * ring.contentSize.height/2);
        // Create the dots
        while([_dots count] < MAX_DOTS){
            
            DotDude *dotDude = [DotDude dotDudeWithSize:(int)(radius * DOT_RATIO) hp:MAX_HP];
            //DotDude *dotDude = [self rectangleSpriteWithSize:CGSizeMake(radius * DOT_RATIO, radius * DOT_RATIO) color:dotColor];
            [center addChild:dotDude];
            [_dots addObject:dotDude];
        }
        
        // Space the dots
        for (DotDude *dotDude in _dots) {
            // Radians position
            int index = [_dots indexOfObject:dotDude];
            float angle = 2 * M_PI / _dots.count * index; // Degrees
            dotDude.position = ccp( cos(angle) * radius, sin(angle) * radius );
            dotDude.rotation = -1 * center.rotation;
        }
        
        // schedule a repeating callback on every frame
        [self schedule:@selector(nextFrame:)];
        self.isTouchEnabled = YES;
        //[_hud showRestartMenu:-1];
        //[self resetGame];
        [_hud showRestartMenu:(int)score];
    }
    return self;
}

-(CCSprite *) rectangleSpriteWithSize:(CGSize)cgsize color:(ccColor3B) c
{
    CCSprite *sg = [CCSprite spriteWithFile:@"blank.png"];
    [sg setTextureRect:CGRectMake( 0, 0, cgsize.width, cgsize.height)];
    sg.color = c;
    return sg;
}

- (void)addBeeDude:(CGPoint)position{
    CCSprite *beeDude = [self addBeeDude];
    beeDude.position = position;
}

- (CCSprite *)addBeeDude
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = winSize.height/2 - radius;
    int actualY = minY + (arc4random() % (2 * radius));
    
    CCSprite *beeDude = [CCSprite spriteWithFile: @"square.png"];
    int spawnX = winSize.width + beeDude.contentSize.width + arc4random() % (int)winSize.width;
    beeDude.position = ccp( spawnX , actualY );

    beeDude.scaleX = (radius * DOT_RATIO) / beeDude.contentSize.width ;
    beeDude.scaleY = (radius * DOT_RATIO) / beeDude.contentSize.height ;

    // Give it a cool trail
    CCParticleMeteor *tail = [[CCParticleMeteor alloc] initWithTotalParticles:100];
    tail.texture = [[CCTextureCache sharedTextureCache] addImage:@"square.png"];
    tail.autoRemoveOnFinish = YES;
    tail.speed = 30.0f;
    tail.duration = -1;
    tail.position = ccp(beeDude.contentSize.width/2, beeDude.contentSize.height/2);
    tail.startSize = beeDude.contentSize.height;
    tail.endSize = 10;
    tail.life = 0.6;
    tail.lifeVar = 0.675;
    tail.angle = 0;
    tail.gravity = ccp(winSize.width, 0);
    
    
    ccColor4F startColor = {0.87f, 0.51f, 0.597f, 1.0f};
    tail.startColor = startColor;
    ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
    tail.startColorVar = startColorVar;
    ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
    tail.endColor = endColor;
    ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
    tail.endColorVar = endColorVar;
    
    
    [beeDude addChild:tail];
    [self addChild:beeDude];
    [_targets addObject:beeDude];
    return beeDude;
}

- (void) resetGame
{
    NSLog(@"resetGame");
    NSArray *beeDudesToDelete = [[NSArray alloc] initWithArray:_targets];
    
    // Reset old stuff
    for(CCSprite *beeDude in beeDudesToDelete){
        [_targets removeObject:beeDude];
        [self removeChild:beeDude cleanup:YES ];
    }
    while([_targets count] < MAX_BEES){
        [self addBeeDude];
    }
    for(DotDude *dotDude in _dots){
        ccColor3B dotColor = {204, 102, 255};
        dotDude.color = dotColor;
        dotDude.hp = MAX_HP;
    }
    
    // Start new scores
    score = 0;
    lives = MAX_HP;
    gameInProgress = YES;
    [self schedule:@selector(nextFrame:)];
}

- (void) nextFrame:(ccTime)dt {
    NSMutableArray *beeDudesToDelete = [[NSMutableArray alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    AppController *appD = (AppController *)[[UIApplication sharedApplication] delegate];
    if([appD robotOnline]) center.rotation =  -1 * [appD currentYaw];
    for (DotDude *dotDude in _dots) {
        dotDude.rotation = -1 * center.rotation;
    }
    if([appD hasResumed]){
        float red = min(1.0, 2 * (float)(MAX_HP - lives)/MAX_HP) ;
        float green = max(0.0, (float)lives/MAX_HP);
        [RKRGBLEDOutputCommand sendCommandWithRed:red green:green blue:0.0];
        appD.hasResumed = FALSE;
    }
    //[_hud showSpheroMenu:![appD robotOnline]];
    
    // Update the score
    if(gameInProgress) score += dt*10;
    [_hud setScoreString:[NSString stringWithFormat:@"Score: %i", (int)score]];
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
            [beeDudesToDelete addObject:beeDude];
        }
        
        CGRect beeDudeRect = CGRectMake(
            beeDude.position.x - (beeDude.contentSize.width/2),
            beeDude.position.y - (beeDude.contentSize.height/2),
            beeDude.contentSize.width * beeDude.scaleX,
            beeDude.contentSize.height * beeDude.scaleY);
        
        for(DotDude *dotDude in _dots){
            CGPoint position = [center convertToWorldSpace:dotDude.position];
            // Relative to center
            CGRect dotDudeRect = CGRectMake(
                position.x - (dotDude.contentSize.width/2),
                position.y - (dotDude.contentSize.height/2),
                dotDude.contentSize.width * dotDude.scaleX,
                dotDude.contentSize.height * dotDude.scaleY
            );
            if (CGRectIntersectsRect(dotDudeRect, beeDudeRect)) {
                
                [beeDudesToDelete addObject:beeDude];
                
                [self createExplosionX:position.x y:position.y];
                [dotDude setHp:dotDude.hp-1];
                if(dotDude.hp <= 0){
                    [self unschedule:@selector(nextFrame:)];
                    gameInProgress = NO;
                    [self endGame];
                }
                // Change the color of the ball
                float red = min(1.0, 2 * (float)(MAX_HP - dotDude.hp)/MAX_HP) ;
                float green = max(0.0, (float)dotDude.hp/MAX_HP);
                ccColor3B dotColor = {(int)255*red, (int)255*green, 0};
                dotDude.color = dotColor;
                [RKRGBLEDOutputCommand sendCommandWithRed:red green:green blue:0.0];
            }
            
        }

    }
    
    for(CCSprite *beeDude in beeDudesToDelete){
        [_targets removeObject:beeDude];
        [self removeChild:beeDude cleanup:YES ];
        while ([_targets count] < MAX_BEES) [self addBeeDude];
    }
    [beeDudesToDelete release];
    
}

-(void) createExplosionX:(float)x y:(float)y
{
    CCParticleRain *explosion = [[CCParticleRain alloc] initWithTotalParticles:200];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
    explosion.duration = .1;
    explosion.emissionRate = 800;
    explosion.life = .4;
    explosion.lifeVar = .3;
    explosion.startSize = 40;
    explosion.startSizeVar = 30;
    explosion.endSize = 0;
    explosion.endSizeVar = 0;
    explosion.angle = 0;
    explosion.angleVar = 360;
    explosion.rotation = 0;
    explosion.gravity = CGPointZero;
    explosion.speed = 72;
    explosion.speedVar = 0;
    explosion.radialAccel = 756.5;
    explosion.radialAccelVar = 50;
    explosion.tangentialAccel = 0;
    explosion.tangentialAccelVar = 0;
    explosion.position = ccp(x, y);
    explosion.posVar = ccp(0,0);
    ccColor4F startColor = {1.0f, 0.16f, 0.0f, 1.0f};
    explosion.startColor = startColor;
    ccColor4F startColorVar = {0.0f, 0.45f, 0.0f, 0.31f};
    explosion.startColorVar = startColorVar;
    ccColor4F endColor = {0.31f, 0.08f, 0.0f, 1.0f};
    explosion.endColor = endColor;
    ccColor4F endColorVar = {0.0f, 0.0f, 0.0f, 0.0f};
    explosion.endColorVar = endColorVar;
    explosion.autoRemoveOnFinish = YES;
    [self addChild:explosion];
}

- (void)endGame {
    // Blow up the disk
    
    // Delete the beeDudes
    
    [_hud showRestartMenu:(int)score];
//    GameOverScene *gameOverScene = [GameOverScene node];
//    [gameOverScene.layer.label setString:[NSString stringWithFormat:@"Your Score: %i", (int)score]];
//    [[CCDirector sharedDirector] pushScene:gameOverScene];

}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Save the position to calculate the angle
    NSLog(@"ccTouchBegan");
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"ccTouchEnded");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if(location.x > 0.75 * winSize.width){
        [self addBeeDude:location];
    }
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"ccTouchesEnded");
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    // ignore touches on the right half of the screen
    
    if(!gameInProgress) return;
    CGPoint touchLocation = [center convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [center convertToNodeSpace:oldTouchLocation];
        
    CGFloat rotateAngle = ccpToAngle( oldTouchLocation) - ccpToAngle(touchLocation);
    float newAngle = center.rotation + CC_RADIANS_TO_DEGREES(rotateAngle);
    
    if(!isnan(newAngle)) [center setRotation:newAngle];
    for(DotDude *dotDude in _dots){
        dotDude.rotation = -center.rotation;
    }

}

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
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
    [_label release];
    _label = nil;
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


@end
