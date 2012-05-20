//
//  LoseScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LoseScene.h"
#import "GameplayLayer.h"
#import "TitleScene.h"

@implementation LoseLayer

+(CCScene *) sceneWithData:(void*)data
{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	LoseLayer *layer;
    layer = [LoseLayer node];
    
    NSInteger *score = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:0] pointerValue];
    NSInteger *timePlayed = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:1] pointerValue]; 
    NSInteger *peopleGrumped = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:2] pointerValue]; 
    NSInteger *dogsSaved = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:3] pointerValue]; 
    layer->_score = (int)score;
    layer->_timePlayed = (int)timePlayed;
    layer->_peopleGrumped = (int)peopleGrumped;
    layer->_dogsSaved = (int)dogsSaved;
    CCLOG(@"In sceneWithData: score = %d, time = %d, peopleGrumped = %d, dogsSaved = %d", layer->_score, layer->_timePlayed, layer->_peopleGrumped, layer->_dogsSaved);
    
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        self.isTouchEnabled = YES;
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        _color_blue = ccc3(6, 110, 163);
        _color_darkblue = ccc3(14, 168, 248);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"end_sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"end_sprites_default.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_BG"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        scoreLine = [CCLabelTTF labelWithString:@"Total points: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [scoreLine setPosition:ccp(-10, -10)];
        scoreLine.color = _color_blue;
        [[scoreLine texture] setAliasTexParameters];
        [self addChild:scoreLine];
        
        timeLine = [CCLabelTTF labelWithString:@"Time lasted: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [timeLine setPosition:ccp(-10, -10)];
        timeLine.color = _color_blue;
        [[timeLine texture] setAliasTexParameters];
        [self addChild:timeLine];
        
        dogsLine = [CCLabelTTF labelWithString:@"Hot Dogs saved: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [dogsLine setPosition:ccp(-10, -10)];
        dogsLine.color = _color_blue;
        [[dogsLine texture] setAliasTexParameters];
        [self addChild:dogsLine];
        
        peopleLine = [CCLabelTTF labelWithString:@"People Grumped: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [peopleLine setPosition:ccp(-10, -10)];
        peopleLine.color = _color_blue;
        [[peopleLine texture] setAliasTexParameters];
        [self addChild:peopleLine];
        
        highScoreLine = [CCLabelTTF labelWithString:@"HIGH SCORE: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [highScoreLine setPosition:ccp(-10, -10)];
        highScoreLine.color = _color_darkblue;
        [[highScoreLine texture] setAliasTexParameters];
        [self addChild:highScoreLine];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 27);
        [self addChild:restartButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Try Again     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneRestart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 27);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Quit     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneQuit)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 26)];
        [self addChild:menu z:11];
        
        _OFButton = [CCSprite spriteWithSpriteFrameName:@"Icon_OpenFeint_dummy.png"];;
        _OFButton.position = ccp(20, 299);
        [self addChild:_OFButton z:70];
        _OFButtonRect = CGRectMake((_OFButton.position.x-(_OFButton.contentSize.width)/2), (_OFButton.position.y-(_OFButton.contentSize.height)/2), (_OFButton.contentSize.width+10), (_OFButton.contentSize.height+10));
        
        _lock = 0;
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    highScore = [standardUserDefaults integerForKey:@"highScore"];
    NSInteger bestTime = [standardUserDefaults integerForKey:@"bestTime"];
    NSInteger overallTime = [standardUserDefaults integerForKey:@"overallTime"];
    if(!_lock){
        _lock = 1;
        if(_score > highScore){
            [standardUserDefaults setInteger:_score forKey:@"highScore"];
            highScore = _score;
        
            scoreNotify = [CCLabelTTF labelWithString:@"New high score!" fontName:@"LostPet.TTF" fontSize:26.0];
            [scoreNotify setPosition:ccp((size.width/2), (size.height/2)-100)];
            [self addChild:scoreNotify];
            
            // this score submission code doesn't work yet
            NSMutableArray *leaderboards = [[OFLeaderboard leaderboards] mutableCopy];
            OFHighScore* score = [[[OFHighScore alloc] initForSubmissionWithScore:highScore] autorelease];
            score.displayText = @"Test display! text";
            score.customData = @"Test custom data!";
            [score submitTo:(OFLeaderboard* )[leaderboards objectAtIndex:0]];
        }
        if(_timePlayed > bestTime){
            [standardUserDefaults setInteger:_timePlayed forKey:@"bestTime"];
            
            timeNotify = [CCLabelTTF labelWithString:@"New best time!" fontName:@"LostPet.TTF" fontSize:26.0];
            [timeNotify setPosition:ccp((size.width/2), (size.height/2)-140)];
            [self addChild:timeNotify];
        }
        CCLOG(@"OverallTime + _timePlayed/60 --> %d + %d = %d", overallTime, _timePlayed/60, overallTime+(_timePlayed/60));
        [standardUserDefaults setInteger:overallTime+(_timePlayed/60) forKey:@"overallTime"];
        [standardUserDefaults synchronize];
    }
    
    [scoreLine setString:[NSString stringWithFormat:@"Total points: %06d", _score]];
    
    int seconds = _timePlayed/60;
    int minutes = seconds/60;
    [timeLine setString:[NSString stringWithFormat:@"Time lasted: %02d:%02d", minutes, seconds%60]];
    [dogsLine setString:[NSString stringWithFormat:@"Dogs saved: %d", _dogsSaved]];
    [peopleLine setString:[NSString stringWithFormat:@"People grumped: %d", _peopleGrumped]];
    [highScoreLine setString:[NSString stringWithFormat:@"HIGH SCORE: %d", highScore]];
    
    [scoreLine setPosition:ccp(62+(scoreLine.contentSize.width/2), 225)];
    [timeLine setPosition:ccp(62+(timeLine.contentSize.width/2), 195)];
    [dogsLine setPosition:ccp(62+(dogsLine.contentSize.width/2), 165)];
    [peopleLine setPosition:ccp(62+(peopleLine.contentSize.width/2), 135)];
    [highScoreLine setPosition:ccp(389-(highScoreLine.contentSize.width/2), 70)];
}

- (void)switchSceneRestart{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
}

- (void)switchSceneQuit{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

- (void)OFButtonCallback{
    NSLog(@"Callback hit");
    [OpenFeint launchDashboard];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if(CGRectContainsPoint(_OFButtonRect, location)){
        [self OFButtonCallback];
    } else {
        NSLog(@"Got touch");
    }
}

-(void) dealloc{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    //[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [super dealloc];
}

@end