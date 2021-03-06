//
//  S.m
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "Shiba.h"
#import "GameplayLayer.h"
#import <SimpleAudioEngine.h>
#import "HotDogManager.h"

@implementation Shiba

-(Shiba *)init:(NSValue *)s withWorld:(NSValue *)w withFloorHeights:(NSMutableArray *)floorHeights{
    winSize = [[CCDirector sharedDirector] winSize];
    scale = 1.2;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = IPAD_SCALE_FACTOR_X;
    }

    self->world = (b2World *)[w pointerValue];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->mainSprite = [CCSprite spriteWithSpriteFrameName:@"Shiba_Walk_1.png"];
    self->mainSprite.scale = scale;
    [[self->mainSprite texture] setAliasTexParameters];
    
    self->speed = 50;
    
    NSMutableArray *animFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 10; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Shiba_Walk_%d.png", i]]];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    self->walkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]] retain];
    
    animFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 18; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Shiba_Eat_%d.png", i]]];
    }
    animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    self->eatAction = [[CCAnimate alloc] initWithAnimation:animation restoreOriginalFrame:NO];;
    
    int pick = arc4random() % [floorHeights count];
    // using this array for both floor heights and z-indices because f*ck NSDictionary
    NSNumber *floor = [floorHeights objectAtIndex:pick];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:FLOOR1_Z]];
    [array addObject:[NSNumber numberWithInt:FLOOR2_Z]];
    [array addObject:[NSNumber numberWithInt:FLOOR3_Z]];
    [array addObject:[NSNumber numberWithInt:FLOOR4_Z]];
    NSNumber *z = [array objectAtIndex:pick];
    array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithFloat:0 - self->mainSprite.contentSize.width / 2]];
    [array addObject:[NSNumber numberWithFloat:winSize.width + self->mainSprite.contentSize.width / 2]];
    NSNumber *x = [array objectAtIndex:arc4random() % [array count]];
    
    if(x.floatValue > winSize.width / 2){
        self->mainSprite.flipX = true;
    }
    
    //create the body
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(self->mainSprite.position.x/PTM_RATIO, self->mainSprite.position.y/PTM_RATIO);
    self->worldBody = self->world->CreateBody(&bodyDef);
    
    //create the grab box fixture
    b2PolygonShape sensorShape;
    sensorShape.SetAsBox((scale*20.0)/PTM_RATIO, (scale*15.0)/PTM_RATIO);
    b2FixtureDef sensorShapeDef;
    sensorShapeDef.shape = &sensorShape;
    sensorShapeDef.filter.categoryBits = 0x0000;
    sensorShapeDef.filter.maskBits = 0x0000;
    sensorShapeDef.isSensor = true;
    self->hitboxSensor = self->worldBody->CreateFixture(&sensorShapeDef);
    
    self->destination = abs(x.floatValue - (winSize.width + self->mainSprite.contentSize.width / 2));
    
    [self->mainSprite setPosition:CGPointMake(x.floatValue, floor.floatValue + (self->mainSprite.contentSize.height*self->mainSprite.scaleY) / 2)];
    [self->spritesheet addChild:self->mainSprite z:z.intValue];
    [self->mainSprite runAction:[CCSequence actions:[CCMoveTo actionWithDuration:winSize.width/self->speed position:ccp(self->destination, self->mainSprite.position.y)], [CCCallFunc actionWithTarget:self selector:@selector(removeSprite)], nil]];
    [self->mainSprite runAction:self->walkAction];
    
    return self;
}

-(void)removeSprite{
    [self->mainSprite removeFromParentAndCleanup:YES];
    self->world->DestroyBody(self->worldBody);
    self->mainSprite = NULL;
    self->worldBody = NULL;
}

-(BOOL)dogIsInHitbox:(NSValue *)d{
    b2Body *dogBody = (b2Body *)[d pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
    if(!self->worldBody || abs(dogBody->GetLinearVelocity().y) > .3) return false;
    if(self->hitboxSensor->TestPoint(dogBody->GetPosition())){
        ud->touchLock = true;
        return true;
    }
    return false;
}

-(void)updateSensorPosition{
    // TODO - destroy sprite and body when offscreen
    if(!self->mainSprite || !self->worldBody) return;
    float xPos = (float)(self->mainSprite.position.x + self->mainSprite.contentSize.width / 2)/PTM_RATIO;
    if(self->mainSprite.flipX)
        xPos = (float)(self->mainSprite.position.x - self->mainSprite.contentSize.width / 2)/PTM_RATIO;
    self->worldBody->SetTransform(b2Vec2(xPos, (self->mainSprite.position.y-10)/PTM_RATIO), self->worldBody->GetAngle());
}

-(void)destroyBody:(id)sender data:(NSValue *)b{
    b2Body *body = (b2Body *)[b pointerValue];
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    [ud->sprite1 removeFromParentAndCleanup:YES];
    [ud->howToPlaySprite removeFromParentAndCleanup:YES];
    [ud->countdownLabel removeFromParentAndCleanup:YES];
    [ud->countdownShadowLabel removeFromParentAndCleanup:YES];
    self->world->DestroyBody(body);
}

-(BOOL)eatDog:(NSValue *)d{
    self->hasEatenDog = true;
    
    b2Body *dogBody = (b2Body *)[d pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
    
    float distanceRemaining, spriteMove;
    if(self->mainSprite.flipX){
        distanceRemaining = self->mainSprite.position.x + self->mainSprite.contentSize.width / 2;
        spriteMove = -15.0*scale;
    } else {
        distanceRemaining = winSize.width - self->mainSprite.position.x + self->mainSprite.contentSize.width / 2;
        spriteMove = 15.0*scale;
    }
    
    self->offset = CGPointMake(spriteMove, 10);
    
    [self->mainSprite setPosition:CGPointMake(self->mainSprite.position.x+spriteMove, self->mainSprite.position.y+10)];
    
    [self->mainSprite stopAllActions];
    [self->mainSprite runAction:self->eatAction];
    [self->mainSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(playWalkAnim)], [CCMoveTo actionWithDuration:distanceRemaining/self->speed position:ccp(self->destination, self->mainSprite.position.y)], [CCCallFunc actionWithTarget:self selector:@selector(removeSprite)], nil]];

    [ud->sprite1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.7], [CCCallFuncND actionWithTarget:self selector:@selector(destroyBody:data:) data:[[NSValue valueWithPointer:dogBody] retain]], nil]];
    
#ifdef DEBUG
#else
    if([[HotDogManager sharedManager] sfxOn])
        [[SimpleAudioEngine sharedEngine] playEffect:@"dog bark.mp3"];
#endif
    
    return true;
}

-(void)playWalkAnim{
    [self->mainSprite setPosition:CGPointMake(self->mainSprite.position.x + (-1)*self->offset.x, self->mainSprite.position.y + (-1)*self->offset.y  )];
    [self->mainSprite runAction:self->walkAction];
}

-(BOOL)hasEatenDog{
    return self->hasEatenDog;
}

-(void)stopAllActions{
    [self->mainSprite stopAllActions];
}

@end