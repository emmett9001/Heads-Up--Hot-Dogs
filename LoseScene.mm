//
//  LoseScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LoseScene.h"
#import "GameplayLayer.h"

@implementation LoseLayer

+(CCScene *) sceneWithData:(void*)data
{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	LoseLayer *layer;
    layer = [LoseLayer node];
    
    NSInteger *score = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:0] pointerValue];
    NSInteger *timePlayed = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:1] pointerValue]; 
    layer->_score = (int)score;
    layer->_timePlayed = (int)timePlayed;
    CCLOG(@"In sceneWithData: score = %d, time = %d", layer->_score, layer->_timePlayed);
    
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"bg_philly.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Try Again?" fontName:@"Marker Felt" fontSize:32.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScene)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(size.width / 2, (size.height/2)+50)];
        [self addChild:menu];
        
        
        scoreLine = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:22.0];
        [scoreLine setPosition:ccp((size.width/2), (size.height/2))];
        [self addChild:scoreLine];
        
        timeLine = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:22.0];
        [timeLine setPosition:ccp((size.width/2), (size.height/2)-50)];
        [self addChild:timeLine];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger highScore = [standardUserDefaults integerForKey:@"highScore"];
    NSInteger bestTime = [standardUserDefaults integerForKey:@"bestTime"];
    NSInteger overallTime = [standardUserDefaults integerForKey:@"overallTime"];
    if(_score > highScore){
        [standardUserDefaults setInteger:_score forKey:@"highScore"];
        
        scoreNotify = [CCLabelTTF labelWithString:@"New high score!" fontName:@"Marker Felt" fontSize:22.0];
        [scoreNotify setPosition:ccp((size.width/2), (size.height/2)-100)];
        [self addChild:scoreNotify];
    }
    if(_timePlayed > bestTime){
        [standardUserDefaults setInteger:_timePlayed forKey:@"bestTime"];
        
        timeNotify = [CCLabelTTF labelWithString:@"New best time!" fontName:@"Marker Felt" fontSize:22.0];
        [timeNotify setPosition:ccp((size.width/2), (size.height/2)-140)];
        [self addChild:timeNotify];
    }
    [standardUserDefaults setInteger:overallTime+_timePlayed forKey:@"overallTime"];
    [standardUserDefaults synchronize];
    
    [scoreLine setString:[NSString stringWithFormat:@"%d", _score]];
    int seconds = _timePlayed/60;
    int minutes = seconds/60;
    [timeLine setString:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds%60]];
}

- (void)switchScene{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end