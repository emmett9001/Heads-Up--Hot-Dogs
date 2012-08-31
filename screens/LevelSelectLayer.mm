//
//  LevelSelectLayer.m
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameplayLayer.h"

#define NUM_LEVELS 6

@implementation LevelSelectLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
	LevelSelectLayer *layer = [LevelSelectLayer node];
	[scene addChild:layer];
	return scene;
}

+(NSMutableArray *)buildLevels:(NSNumber *)full{
    levelStructs = [[NSMutableArray alloc] initWithCapacity:NUM_LEVELS];
    levelProps *lp;
    spcDogData *dd;
    bgComponent *bgc;
    BOOL loadFull = [full intValue];
    CGSize winSize = [CCDirector sharedDirector].winSize;

    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_nyc.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_philly.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_chicago.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_space.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_london.plist"];
    }

    /********************************************************************************
     * PHILLY LEVEL SETTINGS
     *******************************************************************************/

    lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"philly";
    lp->name = @"Philly";
    lp->unlockThreshold = -1;
    lp->func = @"switchScreenPhilly";
    lp->thumbnail = @"Philly_Thumb.png";

    if(loadFull){
        lp->bg = @"bg_philly.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->spritesheet = @"sprites_philly";
        lp->highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", lp->slug]];
        lp->personSpeedMul = 1;

        dd = new spcDogData();
        dd->riseSprite = @"Steak_Rise.png";
        dd->fallSprite = @"Steak_Fall.png";
        dd->mainSprite = @"Steak.png";
        dd->grabSprite = @"Steak_Grabbed.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Steak_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Steak_Die_2.png"]]];
        }
        for(int i = 1; i <= 7; i++){
            [dd->deathAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Steak_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 9; i++){
            [dd->shotAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Steak_Shot_%d.png", i]]];
        }
        lp->specialDog = dd;
    }

    [levelStructs addObject:[NSValue valueWithPointer:lp]];


    /********************************************************************************
     * NYC LEVEL SETTINGS
     *******************************************************************************/

    lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"nyc";
    lp->name = @"Big Apple";
    lp->unlockThreshold = 15000;
    lp->func = @"switchScreenNYC";
    lp->thumbnail = @"NYC_Thumb.png";
    lp->unlockTweet = @"I traveled to the Big Apple for some mischief in @HeadsUpHotDogs";

    if(loadFull){
        lp->bg = @"BG_NYC.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -24.0f;
        lp->spritesheet = @"sprites_nyc";
        lp->personSpeedMul = .8;
        lp->vent1X = 140;
        lp->vent2X = 360;

        dd = new spcDogData();
        dd->riseSprite = @"Bagel_Rise.png";
        dd->fallSprite = @"Bagel_Fall.png";
        dd->mainSprite = @"Bagel.png";
        dd->grabSprite = @"Bagel_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Bagel_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Bagel_Die_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Bagel_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bagel_Shot_%d.png", i]]];
        }

        lp->specialDog = dd;
        
        CGPoint vent1Pos = CGPointMake(lp->vent1X, 37);
        CGPoint vent2Pos = CGPointMake(lp->vent2X, 37);

        lp->bgComponents = [[NSMutableArray alloc] init];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_One.png"];
        bgc->sprite.position = CGPointMake(238, 262);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Two.png"];
        bgc->sprite.position = CGPointMake(352, 262);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Three.png"];
        bgc->sprite.position = CGPointMake(380, 156);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Three.png"];
        bgc->sprite.position = CGPointMake(86, 156);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"SteamVent.png"];
        bgc->sprite.position = vent1Pos;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"SteamVent.png"];
        bgc->sprite.position = vent2Pos;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        
        lp->activeComponents = [[NSMutableArray alloc] init];
        steamVent *vent = new steamVent();
        vent->steamSprite = [CCSprite spriteWithSpriteFrameName:@"Steam_Whole_1.png"];
        vent->steamSprite.position = CGPointMake(vent1Pos.x-3, vent1Pos.y+110);
        vent->startAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++){
            [vent->startAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
        }
        vent->loopingAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 11; i <= 14; i++){
            [vent->loopingAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                              [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
        }
        vent->stopAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 15; i <= 18; i++){
            [vent->stopAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                                [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
        }
        [lp->activeComponents addObject:[NSValue valueWithPointer:vent]];
        
        steamVent *vent2 = new steamVent();
        vent2->steamSprite = [CCSprite spriteWithSpriteFrameName:@"Steam_Whole_1.png"];
        vent2->steamSprite.position = CGPointMake(vent2Pos.x-3, vent2Pos.y+110);
        vent2->startAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++){
            [vent2->startAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                              [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
        }
        vent2->loopingAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 11; i <= 14; i++){
            [vent2->loopingAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                                [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
        }
        vent2->stopAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 15; i <= 18; i++){
            [vent2->stopAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                             [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
        }
        [lp->activeComponents addObject:[NSValue valueWithPointer:vent2]];
    }

    [levelStructs addObject:[NSValue valueWithPointer:lp]];
    
    /********************************************************************************
     * LONDON LEVEL SETTINGS
     *******************************************************************************/
    
    lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"london";
    lp->name = @"London";
    lp->unlockThreshold = 12000;
    lp->func = @"switchScreenLondon";
    lp->thumbnail = @"NYC_Thumb.png";
    lp->unlockTweet = @"I went to London to conquer some franks in @HeadsUpHotDogs";
    
    if(loadFull){
        lp->bg = @"BG_NYC.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -22.0f;
        lp->spritesheet = @"sprites_nyc";
        lp->personSpeedMul = 1.2;
        lp->restitutionMul = 1.2;
        lp->frictionMul = .95;
        
        dd = new spcDogData();
        dd->riseSprite = @"Bagel_Rise.png";
        dd->fallSprite = @"Bagel_Fall.png";
        dd->mainSprite = @"Bagel.png";
        dd->grabSprite = @"Bagel_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Shot_%d.png", i]]];
        }
        
        lp->specialDog = dd;
    }
    
    [levelStructs addObject:[NSValue valueWithPointer:lp]];

    /********************************************************************************
     * JAPAN LEVEL SETTINGS
     *******************************************************************************/
    
    lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"japan";
    lp->name = @"Hot Spring";
    lp->unlockThreshold = 13500;
    lp->func = @"switchScreenJapan";
    lp->thumbnail = @"Japan_Thumb.png";
    lp->unlockTweet = @"I was ready to relax in a calming Japanese hot spring in @HeadsUpHotDogs";
    
    if(loadFull){
        lp->bg = @"Japan_BG.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->gravity = -28.0f;
        lp->spritesheet = @"sprites_japan";
        lp->dogDeathDelay = .001;
        lp->personSpeedMul = .7;
        lp->maxDogs = 7;
        lp->gravity = -17.0;
        lp->spawnInterval = 4.0;
        
        lp->dogDeathAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++){
            [lp->dogDeathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Splash_%d.png", i]]];
        }
        
        dd = new spcDogData();
        dd->riseSprite = @"Bagel_Rise.png";
        dd->fallSprite = @"Bagel_Fall.png";
        dd->mainSprite = @"Bagel.png";
        dd->grabSprite = @"Bagel_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Shot_%d.png", i]]];
        }
        
        lp->specialDog = dd;
    }
    
    [levelStructs addObject:[NSValue valueWithPointer:lp]];

    /********************************************************************************
     * CHICAGO LEVEL SETTINGS
     *******************************************************************************/

    lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"chicago";
    lp->name = @"Windy City";
    lp->unlockThreshold = 6500;
    lp->thumbnail = @"Chicago_Thumb.png";
    lp->func = @"switchScreenChicago";
    lp->unlockTweet = @"I traveled to the Windy City in @HeadsUpHotDogs";

    if(loadFull){
        lp->bg = @"Chicago_BG.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->gravity = -27.0f;
        lp->spritesheet = @"sprites_chicago";
        lp->personSpeedMul = .85;
        lp->restitutionMul = 1.3;
        lp->frictionMul = 1.1;
        lp->maxDogs = 5;
        lp->hasShiba = true;

        dd = new spcDogData();
        dd->riseSprite = @"ChiDog_Rise.png";
        dd->fallSprite = @"ChiDog_Fall.png";
        dd->mainSprite = @"ChiDog.png";
        dd->grabSprite = @"ChiDog_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"ChiDog_Death_1.png"]]];
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"ChiDog_Death_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"ChiDog_Death_%d.png", i]]];
        }
        for(int i = 1; i <= 5; i++){
            [dd->shotAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"ChiDog_Shot_%d.png", i]]];
        }

        lp->specialDog = dd;
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Flag_Flap_1.png"] retain];
        bgc->sprite.position = CGPointMake(winSize.width-17, 245);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 4; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        bgc->anim2 = [[NSMutableArray alloc] init];
        for(int i = 8; i <= 11; i++){
            [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                    [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Flag_Flap_1.png"] retain];
        bgc->sprite.position = CGPointMake(19, 267);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 4; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        bgc->anim2 = [[NSMutableArray alloc] init];
        for(int i = 8; i <= 11; i++){
            [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Dust1_1.png"] retain];
        bgc->sprite.position = CGPointMake(179, 20);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 6; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Dust1_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
    }

    [levelStructs addObject:[NSValue valueWithPointer:lp]];


    /********************************************************************************
     * SPACE LEVEL SETTINGS
     *******************************************************************************/

    lp = new levelProps();
    lp->enabled = false;
    lp->slug = @"space";
    lp->name = @"Space Station";
    lp->unlockThreshold = 16000;
    lp->thumbnail = @"Space_Thumb.png";
    lp->func = @"switchScreenSpace";
    lp->unlockTweet = @"We sent a frankfurter to the moon in @HeadsUpHotDogs";

    if(loadFull){
        lp->bg = @"SpaceBG.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -40.0f;
        lp->spritesheet = @"sprites_space";
        lp->personSpeedMul = 1.1;
        lp->restitutionMul = 1.7;
        lp->frictionMul = 100;
        lp->hasShiba = true;

        dd = new spcDogData();
        dd->riseSprite = @"Chips_Rise.png";
        dd->fallSprite = @"Chips_Fall.png";
        dd->mainSprite = @"Chips.png";
        dd->grabSprite = @"Chips_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Chips_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Chips_Die_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Chips_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Chips_Shoot%d.png", i]]];
        }
        lp->specialDog = dd;

        lp->bgComponents = [[NSMutableArray alloc] init];
        int y = 152;
        for(int i = 2; i <= 10; i++){
            bgc = new bgComponent();
            bgc->sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Grav_%d.png", i]];
            bgc->sprite.position = CGPointMake(329, y+(6*(i-1)));
            [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        }
    }

    [levelStructs addObject:[NSValue valueWithPointer:lp]];

    /////////////////////////////////////////////////////////////////////////////

    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_common.plist"];
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_nyc.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_philly.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_chicago.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_space.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_japan.plist"];
    }

    for(NSValue *v in levelStructs){
        levelProps *l = (levelProps *)[v pointerValue];
        l->highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", l->slug]];
        int nextIndex = [levelStructs indexOfObject:v] + 1;
        if(nextIndex == [levelStructs count])
            nextIndex--;
        int prevIndex = [levelStructs indexOfObject:v] - 1;
        if(prevIndex == -1)
            prevIndex++;
        levelProps *nextLevel = (levelProps *)[(NSValue *)[levelStructs objectAtIndex:nextIndex] pointerValue];
        l->next = nextLevel;
        levelProps *prevLevel = (levelProps *)[(NSValue *)[levelStructs objectAtIndex:prevIndex] pointerValue];
        l->prev = prevLevel;
        l->characters = [CharBuilder buildCharacters:l->slug];

        l->characterProbSum = 0;
        for(NSValue *v in l->characters){
            personStruct *p = (personStruct *)[v pointerValue];
            l->characterProbSum += p->frequency;
        }

        int prevHighScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", l->prev->slug]];
        if(prevHighScore > l->unlockThreshold){
            [standardUserDefaults setInteger:1 forKey:[NSString stringWithFormat:@"unlocked%@", l->slug]];
        }
        [standardUserDefaults synchronize];

        int unlocked = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"unlocked%@", l->slug]];
        if(unlocked) l->unlocked = true;
        else l->unlocked = false;
    }

    return levelStructs;
}

-(id) init{
    if ((self = [super init])){
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        // TODO: for testing only - don't lock the levels
        // this completely bypasses the storage of level unlock userDefaults and simply shows all levels as available
        NO_LEVEL_LOCKS = true;

        self.isTouchEnabled = true;

        curLevelIndex = 0;

        _color_pink = ccc3(255, 62, 166);

        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spritesheet];

        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"LvlBG.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"SELECT LEVEL" fontName:@"LostPet.TTF" fontSize:50.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)-9);
        [self addChild:label];

        sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
        sprite.position = ccp(winSize.width/2, (sprite.contentSize.height/2)+40);
        [self addChild:sprite];

        nameLabel = [CCLabelTTF labelWithString:@"philadelphia" fontName:@"LostPet.TTF" fontSize:20.0];
        [[nameLabel texture] setAliasTexParameters];
        nameLabel.color = _color_pink;
        nameLabel.position = ccp(winSize.width/2, sprite.position.y+(label.contentSize.height/2)-17);
        [self addChild:nameLabel];

        scoreLabel = [CCLabelTTF labelWithString:@"high score: ######" fontName:@"LostPet.TTF" fontSize:20.0];
        [[scoreLabel texture] setAliasTexParameters];
        scoreLabel.color = _color_pink;
        scoreLabel.position = ccp(winSize.width/2, sprite.position.y+(label.contentSize.height/2)-35);
        [self addChild:scoreLabel];

        //left
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(52, winSize.height/2);
        [self addChild:sprite];

        leftArrowRect = CGRectMake((sprite.position.x-(sprite.contentSize.width)/2), (sprite.position.y-(sprite.contentSize.height)/2), (sprite.contentSize.width+10), (sprite.contentSize.height+10));

        //right
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(winSize.width-52, winSize.height/2);
        sprite.flipX = true;
        [self addChild:sprite];

        rightArrowRect = CGRectMake((sprite.position.x-(sprite.contentSize.width)/2), (sprite.position.y-(sprite.contentSize.height)/2), (sprite.contentSize.width+10), (sprite.contentSize.height+10));

        thumb = [CCSprite spriteWithSpriteFrameName:@"Philly_Thumb.png"];
        thumb.position = ccp(winSize.width/2, winSize.height/2+20);
        [self addChild:thumb];

        helpLabel = [CCLabelTTF labelWithString:@"Tap to start" fontName:@"LostPet.TTF" fontSize:22.0];
        [[helpLabel texture] setAliasTexParameters];
        helpLabel.color = _color_pink;
        helpLabel.position = ccp(winSize.width/2, thumb.position.y-(thumb.contentSize.height/2)+6);
        [self addChild:helpLabel];

        thumbnailRect = CGRectMake((thumb.position.x-(thumb.contentSize.width)/2), (thumb.position.y-(thumb.contentSize.height)/2), (thumb.contentSize.width+10), (thumb.contentSize.height+10));

        lStructs = [LevelSelectLayer buildLevels:[NSNumber numberWithInt:0]];

        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
    level = (levelProps *)[(NSValue *)[lStructs objectAtIndex:curLevelIndex] pointerValue];

    if(NO_LEVEL_LOCKS || level->unlocked || level->unlockThreshold < 0){
        [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:level->thumbnail]];
        [nameLabel setString:[NSString stringWithFormat:@"%@", level->name]];
        [scoreLabel setString:[NSString stringWithFormat:@"high score: %06d", level->highScore]];
        [helpLabel setVisible:true];
    } else {
        [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NoLevel.png"]];
        [nameLabel setString:@"??????"];
        [scoreLabel setString:[NSString stringWithFormat:@"Unlock with %d points", level->unlockThreshold]];
        [helpLabel setVisible:false];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    firstTouch = location;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    //Swipe Detection Part 2
    lastTouch = location;

    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);

    if(CGRectContainsPoint(leftArrowRect, location) || (firstTouch.x < lastTouch.x && swipeLength > 60)){
        if(curLevelIndex > 0)
            curLevelIndex--;
        else curLevelIndex = [lStructs count] - 1;
    }
    else if(CGRectContainsPoint(rightArrowRect, location) || (firstTouch.x > lastTouch.x && swipeLength > 60)){
        if(curLevelIndex < [lStructs count] - 1)
            curLevelIndex++;
        else curLevelIndex = 0;
    }
    else if(CGRectContainsPoint(thumbnailRect, location)){
        SEL levelMethod = NSSelectorFromString(level->func);
        if(NO_LEVEL_LOCKS || level->unlocked)
            [self performSelector:levelMethod];
    }
}

-(void)switchScreenPhilly{
    [self switchScreenStartWithSlug:@"philly"];
}

-(void)switchScreenNYC{
    [self switchScreenStartWithSlug:@"nyc"];
}

-(void)switchScreenLondon{
    [self switchScreenStartWithSlug:@"london"];
}

-(void)switchScreenChicago{
    [self switchScreenStartWithSlug:@"chicago"];
}

-(void)switchScreenJapan{
    [self switchScreenStartWithSlug:@"japan"];
}

-(void)switchScreenSpace{
    [self switchScreenStartWithSlug:@"space"];
}

-(void)switchScreenStartWithSlug:(NSString *)slug{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithSlug:slug]];
}

-(void) dealloc{
    free(lStructs);
    [super dealloc];
}

@end
