//
//  Firecracker.h
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "UIDefs.h"

@interface Firecracker : NSObject {
    b2World *world;
    CCSprite *mainSprite;
    CCAction *explodeAnimation;
    b2Body *worldBody;
    CCSpriteBatchNode *spritesheet;
    NSString *fallSprite, *riseSprite;
    b2Fixture *hitboxSensor;
    BOOL isNowExploding, hasKilledDog;
    CGSize winSize;
    float fallSpeed;
    b2Vec2 position;
}

-(Firecracker *)init:(NSValue *)w withSpritesheet:(NSValue *)s;
-(void)dropDown;
-(void)explode;
-(void)pullUp;
-(BOOL)explosionHittingDog:(NSValue *)d;
-(void)runSequence;
-(void)setHasKilledDog;

@end
