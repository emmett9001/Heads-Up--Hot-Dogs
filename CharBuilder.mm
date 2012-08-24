//
//  CharBuilder.m
//  Heads Up
//
//  Created by Emmett Butler on 7/22/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "CharBuilder.h"
#import "GameplayLayer.h"

@implementation CharBuilder

+(NSMutableArray *)buildCharacters:(NSString *)levelSlug{
    SEL levelMethod = NSSelectorFromString(levelSlug);
    CCLOG(@"levelSlug: %@", levelSlug);
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_characters.plist"];
    NSMutableArray *characters = [[self performSelector:levelMethod] retain];
    return characters;
}

+(NSMutableArray *)philly{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];
    personStruct *s;
    
    s = [self businessman];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self youngPro];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self jogger];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    
    return levelArray;
}

+(NSMutableArray *)nyc{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    personStruct *s;
    
    s = [self crustPunk];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self youngPro];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self jogger];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self police];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    
    return levelArray;
}

+(NSMutableArray *)london{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    personStruct *s;
    
    s = [self crustPunk];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self youngPro];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self jogger];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self police];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self dogMuncher];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    
    return levelArray;
}

+(NSMutableArray *)japan{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    personStruct *s;
    
    s = [self businessman];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self youngPro];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self jogger];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self police];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self dogMuncher];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    
    return levelArray;
}

+(NSMutableArray *)chicago{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    personStruct *s;
    
    s = [self businessman];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self youngPro];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self jogger];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self police];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self dogMuncher];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    
    return levelArray;
}

+(NSMutableArray *)space{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    personStruct *s;
    
    s = [self dogMuncher];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self youngPro];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self jogger];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    s = [self police];
    [levelArray addObject:[NSValue valueWithPointer:s]];
    
    return levelArray;
}

+(personStruct *)businessman{
    personStruct *c = new personStruct();
    
    c->slug = @"busman";
    c->lowerSprite = @"BusinessMan_Walk_1.png";
    c->upperSprite = @"BusinessHead_NoDog_1.png";
    c->upperOverlaySprite = @"BusinessHead_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_BUSMAN;
    c->hitboxWidth = 21.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4;
    c->moveDelta = 3.6;
    c->sensorHeight = 2.5f;
    c->sensorWidth = 1.5f;
    c->restitution = .8f;
    c->framerate = .07f;
    c->friction = 0.3f;
    c->fTag = F_BUSHED;
    c->pointValue = 10;
    c->frequency = 5;
    c->heightOffset = 2.9f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleIdleAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 6; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 2; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Idle_%d.png", i]]];
    }
    for(int i = 1; i <= 3; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessHead_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 3; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 3; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 2; i++){
        [c->rippleIdleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Ripple_Idle_%d.png", i]]];
    }
    for(int i = 1; i <= 6; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)police{
    personStruct *c = new personStruct();

    c->slug = @"police";
    c->lowerSprite = @"Cop_Run_1.png";
    c->upperSprite = @"Cop_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Cop_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->armSprite = @"cop_arm.png";
    c->targetSprite = @"Target_NoDog.png";
    c->tag = S_POLICE;
    c->armTag = S_COPARM;
    c->hitboxWidth = 21.5;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4.1;
    c->moveDelta = 5;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .5f;
    c->friction = 4.0f;
    c->fTag = F_COPHED;
    c->heightOffset = 2.9f;
    c->pointValue = 15;
    c->frequency = 2;
    c->lowerArmAngle = 0;
    c->upperArmAngle = 55;
    c->framerate = .07f;
    c->armJointXOffset = 15;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->specialAnimFrames = [[NSMutableArray alloc] init];
    c->specialFaceAnimFrames = [[NSMutableArray alloc] init];
    c->armShootAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleIdleAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Run_%d.png", i]]];
    }
    [c->idleAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
      @"Cop_Idle.png"]];
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 2; i++){
        [c->specialAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Shoot_%d.png", i]]];
    }
    [c->specialFaceAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
      [NSString stringWithFormat:@"Cop_Head_Shoot_1.png"]]];
    [c->specialFaceAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
      [NSString stringWithFormat:@"Cop_Head_Shoot_2.png"]]];
    [c->rippleIdleAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cop_Ripple_Idle.png"]];
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)jogger{
    personStruct *c = new personStruct();
    
    c->slug = @"jogger";
    c->lowerSprite = @"Jogger_Run_1.png";
    c->upperSprite = @"Jogger_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Jogger_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_JOGGER;
    c->hitboxWidth = 22.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.7;
    c->moveDelta = 6;
    c->sensorHeight = 1.3f;
    c->sensorWidth = 1.5f;
    c->restitution = .4f;
    c->friction = 0.15f;
    c->framerate = .07f;
    c->fTag = F_JOGHED;
    c->pointValue = 25;
    c->frequency = 4;
    c->heightOffset = 2.55f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Run_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Run_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Ripple_Run_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)youngPro{
    personStruct *c = new personStruct();
    
    c->slug = @"youngpro";
    c->lowerSprite = @"YoungProfesh_Walk_1.png";
    c->upperSprite = @"YoungProfesh_Head_NoDog_1.png";
    c->upperOverlaySprite = @"YoungProfesh_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_YNGPRO;
    c->hitboxWidth = 24.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4.0;
    c->moveDelta = 3.7;
    c->sensorHeight = 1.3f;
    c->sensorWidth = 1.5f;
    c->restitution = .4f; //bounce
    c->friction = 0.15f;
    c->framerate = .06f;
    c->fTag = F_JOGHED;
    c->pointValue = 15;
    c->frequency = 5;
    c->heightOffset = 2.9f;
    c->rippleXOffset = .1;
    c->rippleYOffset = -1.325;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)crustPunk{
    personStruct *c = new personStruct();
    
    c->slug = @"crpunk";
    c->lowerSprite = @"CrustPunk_Walk_1.png";
    c->upperSprite = @"CrustPunk_Head_NoDog_1.png";
    c->upperOverlaySprite = @"YoungProfesh_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_CRPUNK;
    c->hitboxWidth = 16.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.2;
    c->moveDelta = 3;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .87f;
    c->friction = 0.15f;
    c->framerate = .06f;
    c->pointValue = 15;
    c->frequency = 4;
    c->fTag = F_PNKHED;
    c->heightOffset = 2.4f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)dogMuncher{
    personStruct *c = new personStruct();
    
    c->slug = @"muncher";
    c->lowerSprite = @"DogEater_Walk_1.png";
    c->upperSprite = @"DogEater_Head_NoDog_1.png";
    c->upperOverlaySprite = @"DogEater_Head_NoDog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_MUNCHR;
    c->flipSprites = true;
    c->hitboxWidth = 20.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4.0;
    c->moveDelta = 2;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .5f;
    c->friction = 0.15f;
    c->framerate = .06f;
    c->pointValue = 15;
    c->frequency = 2;
    c->fTag = F_PNKHED;
    c->heightOffset = 2.9f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.425;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->specialAnimFrames = [[NSMutableArray alloc] init];
    c->specialFaceAnimFrames = [[NSMutableArray alloc] init];
    c->altFaceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->altWalkAnimFrames = [[NSMutableArray alloc] init];
    c->postStopAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->specialAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Rub_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->specialFaceAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Head_Rub_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->altFaceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_DogGone_Head%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->altWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_DogGone_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 25; i++){
        [c->postStopAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_DogBack_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

@end
