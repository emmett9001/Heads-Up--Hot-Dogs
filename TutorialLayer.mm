//
//  TutorialLayer.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "GameplayLayer.h"
#import "TitleScene.h"
#import "TutorialLayer.h"

@implementation TutorialLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	TutorialLayer *layer;
    layer = [TutorialLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        //CGSize size = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"end_sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"end_sprites_default.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_BG"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 27);
        [self addChild:restartButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Start     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneStart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 27);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Title Screen     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneTitleScreen)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 26)];
        [self addChild:menu z:11];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
}

- (void)switchSceneStart{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
}

- (void)switchSceneTitleScreen{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    //[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [super dealloc];
}

@end