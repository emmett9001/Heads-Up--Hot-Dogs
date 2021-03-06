//
//  LevelSelectLayer.m
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameplayLayer.h"
#import "Clouds.h"
#import "TitleScene.h"
#import "UIDefs.h"
#import "HotDogManager.h"

@implementation LevelSelectLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
	LevelSelectLayer *layer = [LevelSelectLayer node];
	[scene addChild:layer];
	return scene;
}

+(NSMutableArray *)buildLevels:(NSNumber *)full{
    NSMutableArray *levelStructs = [[NSMutableArray alloc] init];
    
    if(full.boolValue) [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];

    // check it out - seven levels!
    [levelStructs addObject:[self philly:full]];
    [levelStructs addObject:[self nyc:full]];
    [levelStructs addObject:[self london:full]];
    [levelStructs addObject:[self chicago:full]];
    [levelStructs addObject:[self china:full]];
    [levelStructs addObject:[self space:full]];
    [levelStructs addObject:[self japan:full]];
   
    if(full.boolValue) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_common.plist"];

    DLog(@"Loading levels...");
    for(NSValue *v in levelStructs){
        levelProps *l = (levelProps *)[v pointerValue];
        l->highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", l->slug]];
        int nextIndex = [levelStructs indexOfObject:v] + 1;
        if(nextIndex == [levelStructs count])
            nextIndex--;
        int prevIndex = [levelStructs indexOfObject:v] - 1;
        if(prevIndex == -1)
            prevIndex++;
        l->next = (levelProps *)[(NSValue *)[levelStructs objectAtIndex:nextIndex] pointerValue];
        l->prev = (levelProps *)[(NSValue *)[levelStructs objectAtIndex:prevIndex] pointerValue];
        l->number = [levelStructs indexOfObject:v] + 1;
        
        l->highestTrophy = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"trophy_%@", l->slug]];
        if(l->highestTrophy < 1 || l->highestTrophy > 5)
            l->highestTrophy = 6;
        
        int unlocked = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"unlocked%@", l->slug]];
        int prevTrophyLevel = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"trophy_%@", l->prev->slug]];
        if((prevTrophyLevel && prevTrophyLevel <= 2) || l->slug == @"philly"){
            DLog(@"Level %@ unlocked", l->name);
            [standardUserDefaults setInteger:1 forKey:[NSString stringWithFormat:@"unlocked%@", l->slug]];
            unlocked = 1;
        }
        [standardUserDefaults synchronize];

        if(unlocked) l->unlocked = true;
    }
    DLog(@"Done");
    return levelStructs;
}

//#ifdef TEST
-(void)unlockAllLevels{
    for(NSValue *v in lStructs){
        levelProps *lp = (levelProps *)[v pointerValue];
        lp->unlocked = true;
    }
    unlockedCount = [lStructs count] - 1;
}
//#endif

-(id) init{
    if ((self = [super init])){
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        winSize = [[CCDirector sharedDirector] winSize];
        [[HotDogManager sharedManager] setPause:[NSNumber numberWithBool:false]];
        [[HotDogManager sharedManager] setInGame:[NSNumber numberWithBool:false]];
#ifdef DEBUG
#else
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = .4;
        if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu 2.mp3" loop:YES];
#endif
        
        // TODO: for testing only - don't lock the levels
        // this completely bypasses the storage of level unlock userDefaults and simply shows all levels as available
        NO_LEVEL_LOCKS = false;

        self.isTouchEnabled = true;

        curLevelIndex = 0;
        float largeFontSize = IPHONE_HEADER_TEXT_SIZE;

        _color_pink = ccc3(255, 62, 166);

        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spritesheet];
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self] andSpritesheet:[NSValue valueWithPointer:spritesheet]];

        background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
            largeFontSize = IPAD_HEADER_TEXT_SiZE;
        } else {
            background.scaleX = winSize.width / background.contentSize.width;
        }
        [self addChild:background z:-1];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_Band.png"];
        sprite.position = ccp(winSize.width/2, winSize.height/2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:sprite];
        
        float scale = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scale = IPAD_SCALE_FACTOR_Y;
        }
        thumb = [CCSprite spriteWithSpriteFrameName:@"Philly_Thumb.png"];
        thumb.position = ccp(winSize.width/2, winSize.height/2+(20*scale));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            thumb.scaleX = IPAD_SCALE_FACTOR_X;
            thumb.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:thumb z:20];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"SELECT LEVEL" fontName:@"LostPet.TTF" fontSize:largeFontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)-9);
        [self addChild:label];

        sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
        sprite.position = ccp(winSize.width/2, (winSize.height/5));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:sprite];
        
        float fontSize = 18.0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            fontSize = 40.0;
        }
        
        lStructs = [[LevelSelectLayer buildLevels:[NSNumber numberWithInt:0]] retain];
        level = (levelProps *)[(NSValue *)[lStructs objectAtIndex:curLevelIndex] pointerValue];
        
        BOOL allGoldTrophies = true;
        for(NSValue *v in lStructs){
            levelProps *l = (levelProps *)[v pointerValue];
            if(l->highestTrophy != 1){
                allGoldTrophies = false;
                break;
            }
        }
        
        nameLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@\nhigh score: %06d", level->name, level->highScore] dimensions:CGSizeMake(sprite.contentSize.width*sprite.scaleX, sprite.contentSize.height*sprite.scaleY) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:fontSize];
        [[nameLabel texture] setAliasTexParameters];
        nameLabel.color = _color_pink;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            nameLabel.position = ccp(sprite.position.x, sprite.position.y-4*sprite.scaleY*1.2);
        } else {
            nameLabel.position = ccp(sprite.position.x, sprite.position.y-4*sprite.scaleY);
        }
        [self addChild:nameLabel];
        
        NSInteger trophyLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"trophy_philly"];
        trophy = [CCSprite spriteWithSpriteFrameName:[self resolveTrophyLevel:trophyLevel]];
        trophy.scale = .37;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            trophy.scale *= IPAD_SCALE_FACTOR_X;
        }
        trophy.position = ccp(nameLabel.position.x-(nameLabel.contentSize.width*.38), winSize.height*.195);
        if(trophyLevel < 1 || trophyLevel > 5)
            [trophy setVisible:false];
        [self addChild:trophy z:21];

        //left
        leftArrow = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        leftArrow.position = ccp(leftArrow.contentSize.width, winSize.height/2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            leftArrow.scaleX = IPAD_SCALE_FACTOR_X;
            leftArrow.scaleY = IPAD_SCALE_FACTOR_Y;
            leftArrow.position = ccp(leftArrow.position.x + 30, leftArrow.position.y);
        }
        leftArrowOGScaleX = leftArrow.scaleX;
        leftArrowOGScaleY = leftArrow.scaleY;
        [self addChild:leftArrow];
        leftArrowRect = CGRectMake((leftArrow.position.x-(leftArrow.contentSize.width*leftArrow.scaleX)/2), (leftArrow.position.y-(leftArrow.contentSize.height*leftArrow.scaleY)/2), (leftArrow.contentSize.width*leftArrow.scaleX+20), (leftArrow.contentSize.height*leftArrow.scaleY+300));

        //right
        rightArrow = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        rightArrow.position = ccp(winSize.width-rightArrow.contentSize.width, winSize.height/2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            rightArrow.scaleX = IPAD_SCALE_FACTOR_X;
            rightArrow.scaleY = IPAD_SCALE_FACTOR_Y;
            rightArrow.position = ccp(rightArrow.position.x - 30, rightArrow.position.y);
        }
        rightArrow.flipX = true;
        rightArrowOGScaleX = rightArrow.scaleX;
        rightArrowOGScaleY = rightArrow.scaleY;
        [self addChild:rightArrow];
        rightArrowRect = CGRectMake((rightArrow.position.x-(rightArrow.contentSize.width*rightArrow.scaleX)/2), (rightArrow.position.y-(rightArrow.contentSize.height*rightArrow.scaleY)/2), (rightArrow.contentSize.width*rightArrow.scaleX+20), (rightArrow.contentSize.height*rightArrow.scaleY+300));

        helpLabel = [CCLabelTTF labelWithString:@"Tap to start" fontName:@"LostPet.TTF" fontSize:22.0];
        [[helpLabel texture] setAliasTexParameters];
        helpLabel.color = _color_pink;
        helpLabel.position = ccp(winSize.width/2, thumb.position.y-((thumb.contentSize.height*thumb.scaleY)/2)+6);
        [self addChild:helpLabel z:25];
        
        CCSprite *button4 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button4.scale = scale;
        button4.position = ccp(button4.contentSize.width/2*button4.scaleX*1.1, button4.contentSize.height*button4.scaleY*.6);
        [self addChild:button4 z:10];
        label = [CCLabelTTF labelWithString:@"Title" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(button4.position.x, button4.position.y-1);
        [self addChild:label z:11];
        _backRect = CGRectMake((button4.position.x-(button4.contentSize.width*button4.scaleX)/2), (button4.position.y-(button4.contentSize.height*button4.scaleY)/2), (button4.contentSize.width*button4.scaleX+70), (button4.contentSize.height*button4.scaleY+70));
        
        if(allGoldTrophies){
            CCSprite *button5 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
            button5.scale = scale;
            button5.position = ccp(winSize.width-button4.contentSize.width/2*button4.scaleX*1.1, button4.contentSize.height*button4.scaleY*.6);
            [self addChild:button5 z:10];
            label = [CCLabelTTF labelWithString:@"Big Heads" fontName:@"LostPet.TTF" fontSize:fontSize];
            [[label texture] setAliasTexParameters];
            label.color = _color_pink;
            label.position = ccp(button5.position.x, button5.position.y-1);
            [self addChild:label z:11];
            _headsRect = CGRectMake((button5.position.x-(button5.contentSize.width*button5.scaleX)/2), (button5.position.y-(button5.contentSize.height*button5.scaleY)/2), (button5.contentSize.width*button5.scaleX+70), (button5.contentSize.height*button5.scaleY+70));
            
            bigHeadToggleLabel = [CCLabelTTF labelWithString:@"OFF" fontName:@"LostPet.TTF" fontSize:fontSize];
            bigHeadToggleLabel.position = ccp(button5.position.x+button5.contentSize.width*button5.scaleX*.3, button5.position.y+button5.contentSize.height*button5.scaleY/2+10*scale);
            bigHeadToggleLabel.color = _color_pink;
            [self addChild:bigHeadToggleLabel];
        } else {
            _headsRect = CGRectMake(0, 0, -1, -1);
        }
        
//#ifdef TEST
        CCLabelTTF *unlockAllLevelsLabel = [CCLabelTTF labelWithString:@"Unlock all levels" fontName:@"LostPet.TTF" fontSize:25.0];
        unlockAllLevelsLabel.color = _color_pink;
        CCMenuItem *item = [CCMenuItemLabel itemWithLabel:unlockAllLevelsLabel target:self selector:@selector(unlockAllLevels)];
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        menu.position = ccp(winSize.width-unlockAllLevelsLabel.contentSize.width/2, unlockAllLevelsLabel.contentSize.height);
        //[self addChild:menu];
//#endif

        thumbnailRect = CGRectMake((thumb.position.x-((thumb.contentSize.width*thumb.scaleX))/2), (thumb.position.y-(thumb.contentSize.height*thumb.scaleY)/2), ((thumb.contentSize.width*thumb.scaleX)+10), ((thumb.contentSize.height*thumb.scaleY)+10));
        
        for(NSValue *v in lStructs){
            levelProps *lp = (levelProps *)[v pointerValue];
            if(lp->unlocked && unlockedCount < [lStructs count] - 1)
                unlockedCount++;
        }
        
        enteredSwipes = [[NSMutableArray alloc] init];
        
        firstTouch = CGPointMake(-1, -1);
        transition = [[[CCTurnOffTiles actionWithSize:ccg(16, 11) duration:.3] reverse] retain];
        vomitCheatActive = [NSNumber numberWithBool:false];
        
        [self schedule:@selector(tick:)];
    }
    return self;
}

-(void)tick:(id)sender{
    time++;
    [self processLevelUnlockCheat];
    [self processVomitCheat];
    [self processBigHeadCheat];
    if(time - lastTouchTime > 50){
        [enteredSwipes release];
        enteredSwipes = [[NSMutableArray alloc] init];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    firstTouch = location;
}

-(void)removeOldThumb{
    [thumbOld removeFromParentAndCleanup:YES];
}

-(BOOL)processCheat:(NSArray *)seq{
    BOOL cheat = true;
    for(int i = 0; i < [enteredSwipes count]; i++){
        if(enteredSwipes[i] != seq[i]){
            cheat = false;
        }
    }
    [enteredSwipes release];
    enteredSwipes = [[NSMutableArray alloc] init];
    if(cheat){
#ifdef DEBUG
#else
        [[SimpleAudioEngine sharedEngine] playEffect:@"100pts.mp3"];
#endif
    }
    return cheat;
}

-(void)processVomitCheat{
    NSArray *cheatSwipeSequence = @[@"l", @"r", @"r", @"d", @"l", @"r", @"r", @"d", @"u", @"l", @"r", @"u", @"d", @"d"];
    if([enteredSwipes count] == [cheatSwipeSequence count] && time - lastTouchTime > 30){
        if([self processCheat:cheatSwipeSequence]){
            [[HotDogManager sharedManager] customEvent:@"hell_businessman_cheat" st1:@"player_interaction" st2:NULL level:NULL value:NULL data:NULL];
            vomitCheatActive = [NSNumber numberWithBool:true];
        }
    }
}

-(void)processBigHeadCheat{
    NSArray *cheatSwipeSequence = @[@"l", @"l", @"u", @"d", @"d", @"r", @"l", @"u", @"r", @"d"];
    if([enteredSwipes count] == [cheatSwipeSequence count] && time - lastTouchTime > 30){
        if([self processCheat:cheatSwipeSequence]){
            [[HotDogManager sharedManager] customEvent:@"big_head_cheat" st1:@"player_interaction" st2:NULL level:NULL value:NULL data:NULL];
            bigHeadCheatActive = [NSNumber numberWithBool:true];
            [[HotDogManager sharedManager] setDontReportScores:[NSNumber numberWithBool:true]];
        }
    }
}

-(void)processLevelUnlockCheat{
    NSArray *cheatSwipeSequence = @[@"u", @"u", @"d", @"l", @"l", @"d", @"r", @"u"];
    if([enteredSwipes count] == [cheatSwipeSequence count] && time - lastTouchTime > 30){
        if([self processCheat:cheatSwipeSequence]){
            [[HotDogManager sharedManager] customEvent:@"unlock_all_levels_cheat" st1:@"player_interaction" st2:NULL level:NULL value:NULL data:NULL];
            [self unlockAllLevels];
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(firstTouch.x == -1) return;
    
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 2
    lastTouch = location;
    lastTouchTime = time;

    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    float swipeLenX = abs(firstTouch.x - lastTouch.x);
    float swipeLenY = abs(firstTouch.y - lastTouch.y);
    
    float scale = 1;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = IPAD_SCALE_FACTOR_Y;
    }
    thumbOld = [CCSprite spriteWithSpriteFrameName:level->thumbnail];
    if(!level->unlocked){
         thumbOld = [CCSprite spriteWithSpriteFrameName:@"NoLevel.png"];
    }
    thumbOld.position = ccp(winSize.width/2, winSize.height/2+(20*scale));
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        thumbOld.scaleX = IPAD_SCALE_FACTOR_X;
        thumbOld.scaleY = IPAD_SCALE_FACTOR_Y;
    }
    [self addChild:thumbOld z:15];

    if(CGRectContainsPoint(leftArrowRect, location) || (firstTouch.x < lastTouch.x && swipeLength > 60)){
        if(firstTouch.x < lastTouch.x && swipeLength > 60 && swipeLenX > swipeLenY){
            DLog(@"swipe right");
            [enteredSwipes addObject:@"r"];
        }
        if(curLevelIndex > 0)
            curLevelIndex--;
        else curLevelIndex = unlockedCount;
        if([thumb numberOfRunningActions] == 0)
            [thumb runAction:[CCSequence actions:transition, [CCCallFunc actionWithTarget:self selector:@selector(removeOldThumb)], nil]];
    }
    else if(CGRectContainsPoint(rightArrowRect, location) || (firstTouch.x > lastTouch.x && swipeLength > 60)){
        if(firstTouch.x > lastTouch.x && swipeLength > 60 && swipeLenX > swipeLenY){
            DLog(@"swipe left");
            [enteredSwipes addObject:@"l"];
        }
        if(curLevelIndex < unlockedCount)
            curLevelIndex++;
        else curLevelIndex = 0;
        if([thumb numberOfRunningActions] == 0)
            [thumb runAction:transition];
    }
    if(firstTouch.y > lastTouch.y && swipeLength > 60 && swipeLenX < swipeLenY){
        DLog(@"swipe down");
        [enteredSwipes addObject:@"d"];
    } else if(firstTouch.y < lastTouch.y && swipeLength > 60 && swipeLenX < swipeLenY){
        DLog(@"swipe up");
        [enteredSwipes addObject:@"u"];
    }
    for(int i = 0; i < [enteredSwipes count]; i++){
        DLog(@"swipes %@", enteredSwipes[i]);
    }
    
    level = (levelProps *)[(NSValue *)[lStructs objectAtIndex:curLevelIndex] pointerValue];
    
    if(level->unlocked){
        [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:level->thumbnail]];
        [nameLabel setString:[NSString stringWithFormat:@"%@\nhigh score: %06d", level->name, level->highScore]];
        [helpLabel setVisible:true];
        [trophy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self resolveTrophyLevel:level->highestTrophy]]];
        if(level->highestTrophy >= 1 && level->highestTrophy <= 5)
            [trophy setVisible:true];
        else
            [trophy setVisible:false];
    } else {
        [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NoLevel.png"]];
        [nameLabel setString:[NSString stringWithFormat:@"??????\nunlock: silver on %@", level->prev->name]];
        [helpLabel setVisible:false];
        [trophy setVisible:false];
    }
    
    if(swipeLength > 60) return;
    
    if(CGRectContainsPoint(thumbnailRect, location)){
        SEL levelMethod = NSSelectorFromString(level->func);
        CCSequence *seq = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(placeThumbOnTop)], [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:3 scaleX:15.0*thumb.scaleX scaleY:15.0*thumb.scaleY] rate:2.0], [CCDelayTime actionWithDuration:.001], [CCCallFunc actionWithTarget:self selector:levelMethod], nil];
        
        if(NO_LEVEL_LOCKS || level->unlocked){
            self.isTouchEnabled = false;
            [thumb runAction:seq];
        }
    }
    id action = [CCScaleBy actionWithDuration:.06 scale:.8];
    
    if(CGRectContainsPoint(leftArrowRect, location)){
        if([leftArrow numberOfRunningActions] == 0)
            [leftArrow runAction:[CCSequence actions:action, [action reverse], nil]];
    } else if(CGRectContainsPoint(rightArrowRect, location)){
        if([rightArrow numberOfRunningActions] == 0)
            [rightArrow runAction:[CCSequence actions:action, [action reverse], nil]];
    }
    
    if(CGRectContainsPoint(_backRect, location)){
        [self switchSceneTitle];
    } else if(CGRectContainsPoint(_headsRect, location)){
        if(bigHeadCheatActive.boolValue){
            [bigHeadToggleLabel setString:@"OFF"];
            bigHeadCheatActive = [NSNumber numberWithBool:false];
        } else {
            [bigHeadToggleLabel setString:@"ON"];
            bigHeadCheatActive = [NSNumber numberWithBool:true];
        }
    }
    [[nameLabel texture] setAliasTexParameters];
}

-(NSString *)resolveTrophyLevel:(NSInteger)l{
    if(l == 1)
        return @"Trophy_Gold.png";
    else if(l == 2)
        return @"Trophy_Silver.png";
    else if(l == 3)
        return @"Trophy_Bronze.png";
    else if(l == 4)
        return @"Trophy_Wood.png";
    else
        return @"Trophy_Cardboard.png";
}

-(void)placeThumbOnTop{
    [self reorderChild:thumb z:100];
}

-(void)addLoading{
    [background setColor:ccc3(160, 160, 160)];
    
    float scale = 1, fontSize = 40.0;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = IPAD_SCALE_FACTOR_X;
        fontSize *= IPAD_SCALE_FACTOR_X;
    }
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
    sprite.position = ccp(winSize.width/2, (winSize.height/2));
    sprite.scale = scale;
    //[self addChild:sprite];
    
    loading = [[CCLabelTTF labelWithString:@"Loading..." fontName:@"LostPet.TTF" fontSize:fontSize] retain];
    loading.color = _color_pink;
    loading.position = ccp(winSize.width/2, winSize.height/2);
    [[loading texture] setAliasTexParameters];
    //[self addChild:loading];
}

- (void)switchSceneTitle{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInB transitionWithDuration:.3 scene:[TitleLayer scene]]];
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

-(void)switchScreenChina{
    [self switchScreenStartWithSlug:@"china"];
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.3 scene:[GameplayLayer sceneWithSlug:slug andVomitCheat:vomitCheatActive andBigHeadCheat:bigHeadCheatActive]]];
}

-(void) dealloc{
    [lStructs release];
    [super dealloc];
}

+(NSValue *)philly:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * PHILLY LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"philly";
    lp->name = @"Philly";
    lp->unlockNextThreshold = 5000;
    lp->func = @"switchScreenPhilly";
    lp->thumbnail = @"Philly_Thumb.png";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_philly.plist"];
        lp->bg = @"bg_philly.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->spritesheet = @"sprites_philly";
        lp->highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", lp->slug]];
        lp->personSpeedMul = 1;
        
        spcDogData *dd = new spcDogData();
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
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_philly.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)nyc:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * NYC LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"nyc";
    lp->name = @"Big Apple";
    lp->unlockNextThreshold = 7000;
    lp->func = @"switchScreenNYC";
    lp->thumbnail = @"NYC_Thumb.png";
    lp->unlockTweet = @"I traveled to the Big Apple for some mischief in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_nyc.plist"];
        lp->bg = @"BG_NYC.png";
        lp->bgm = @"02 - Dances With Weenies.mp3";
        lp->introAudio = @"01 - Dances with Weenies (Intro).mp3";
        lp->gravity = -25.0f;
        lp->spritesheet = @"sprites_nyc";
        lp->personSpeedMul = .8;
        lp->maxDogs = 6;
        
        spcDogData *dd = new spcDogData();
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
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float scale = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scale = IPAD_SCALE_FACTOR_X;
        }
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_One.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.495, winSize.height*.81);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Two.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.733, winSize.height*.81);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Three.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.792, winSize.height*.48);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Three.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.179, winSize.height*.48);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_nyc.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)london:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * LONDON LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"london";
    lp->name = @"London";
    lp->unlockNextThreshold = 7000;
    lp->func = @"switchScreenLondon";
    lp->thumbnail = @"London_Thumb.png";
    lp->unlockTweet = @"I went to London to conquer some franks in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_london.plist"];
        lp->bg = @"Subway_Car.png";
        lp->bgm = @"gameplay 2.mp3";
        lp->gravity = -22.0f;
        lp->spritesheet = @"sprites_london";
        lp->personSpeedMul = 1;
        lp->restitutionMul = 1;
        lp->frictionMul = 1;
        lp->maxDogs = 6;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Pasty_Rise.png";
        dd->fallSprite = @"Pasty_Fall.png";
        dd->mainSprite = @"Pasty.png";
        dd->grabSprite = @"Pasty_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Die_2.png"]]];
        }
        for(int i = 1; i <= 10; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 7; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Shoot_%d.png", i]]];
        }
        lp->specialDog = dd;
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float scaleX = 1, scaleY = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        }
        for(int i = 1; i <= 4; i++){
            bgc = new bgComponent();
            bgc->sprite = [[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Window_%d_Start_1.png", i]] retain];
            int xPos;
            bgc->sprite.scaleX = scaleX;
            bgc->sprite.scaleY = scaleY;
            switch(i){
                case 1: xPos = winSize.width/8; break;
                case 2: xPos = 30.5*((float)winSize.width/100); break;
                case 3: xPos = 68.5*((float)winSize.width/100); break;
                case 4: xPos = winSize.width-(bgc->sprite.scaleX*(bgc->sprite.contentSize.width/1.7)); break;
                default: break;
            }
            bgc->sprite.position = CGPointMake(xPos, 2*(winSize.height/3));
            bgc->sprite.scaleX = winSize.width/BASE_X_RESOLUTION;
            bgc->anim1 = [[NSMutableArray alloc] init];
            for(int j = 1; j <= 13; j++){
                [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                       [NSString stringWithFormat:@"Window_%d_Start_%d.png", i, j]]];
            }
            CCAnimation *anim = [CCAnimation animationWithFrames:bgc->anim1 delay:.12f];
            bgc->startingAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:1] retain];
            bgc->anim2 = [[NSMutableArray alloc] init];
            for(int j = 1; j <= 7; j++){
                if(i != 4){
                    [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                           [NSString stringWithFormat:@"Window_%d_Loop_%d.png", i, j]]];
                } else {
                    [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                           [NSString stringWithFormat:@"Window_%d_Loop.png", i]]];
                }
            }
            anim = [CCAnimation animationWithFrames:bgc->anim2 delay:.12f];
            bgc->loopingAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:10] retain];
            bgc->anim3 = [[NSMutableArray alloc] init];
            for(int j = 1; j <= 10; j++){
                [bgc->anim3 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                       [NSString stringWithFormat:@"Window_%d_Stop_%d.png", i, j]]];
            }
            anim = [CCAnimation animationWithFrames:bgc->anim3 delay:.12f];
            bgc->stoppingAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:1] retain];
            [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        }
        float fontSize = 15.0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            fontSize *= IPAD_SCALE_FACTOR_X;
        }
        bgc = new bgComponent();
        bgc->label = [CCLabelTTF labelWithString:@"FRANKSBURY PARK" fontName:@"LostPet.TTF" fontSize:fontSize];
        bgc->anchorPoint = CGPointMake(winSize.width*.755, winSize.height*.68);
        bgc->label.position = bgc->anchorPoint;
        bgc->startingAction = [CCSequence actions:[CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.755, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.753, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.7463, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.7327, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.734, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.7277, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.7131, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.665, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.58, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.46, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.29, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.03, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(-50, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],nil];
        bgc->resetAction = [CCSequence actions:[CCDelayTime actionWithDuration:.12*7*10], [CCCallFuncND actionWithTarget:self selector:@selector(resetLabel:data:) data:[[NSValue valueWithPointer:bgc->label] retain]], nil];
        bgc->stoppingAction = [CCSequence actions:[CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*1.98, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*1.98, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*1.98, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*1.02, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.9, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.83, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.798, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.778, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.755, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f],
                               [CCCallFuncND actionWithTarget:self selector:@selector(labelSetPosition:data:) data:[[NSArray arrayWithObjects:[[NSValue valueWithPointer:bgc->label] retain], [[NSValue valueWithCGPoint:ccp(winSize.width*.755, winSize.height*.68)] retain], nil] retain]],
                               [CCDelayTime actionWithDuration:.12f], nil];
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_london.plist"];
    return [NSValue valueWithPointer:lp];
}

+(void)resetLabel:(id)sender data:(NSValue *)label{
    static int i = 0;
    NSArray *stationNames = @[@"RANDALL SQUARE", @"PICCALILLI CIRCUS", @"FLY PARK CORNER", @"TIGHTSBRIDGE", @"FRANKSBURY PARK"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCLabelTTF *l = (CCLabelTTF *)[label pointerValue];
    //[l setVisible:false];
    [l setString:[stationNames objectAtIndex:i]];
    [l setPosition:CGPointMake(winSize.width+l.contentSize.width*l.scaleX, winSize.height*.68)];
    //[l setVisible:true];
    if(i < [stationNames count] - 1){
        i++;
    } else {
        i = 0;
    }
}

+(void)labelSetPosition:(id)sender data:(NSArray *)array{
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    static int i = 0;
    //DLog(@"iteration %d", i);
    i++;
    CCLabelTTF *l = (CCLabelTTF *)[[array objectAtIndex:0] pointerValue];
    CGPoint pos = [[array objectAtIndex:1] CGPointValue];
    [l setPosition:pos];
}


+(NSValue *)china:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * CHINA LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"china";
    lp->name = @"Beijing";
    lp->unlockNextThreshold = 9000;
    lp->func = @"switchScreenChina";
    lp->thumbnail = @"China_Thumb.png";
    lp->unlockTweet = @"Chinese New Year is a perfect time for franks in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_china.plist"];
        lp->bg = @"China_BG.png";
        lp->bgm = @"chinatown full.mp3";
        lp->bgmVol = .6;
        lp->gravity = -22.0f;
        lp->spritesheet = @"sprites_china";
        lp->personSpeedMul = 1;
        lp->restitutionMul = 1;
        lp->frictionMul = 1;
        lp->maxDogs = 6;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Baozi_Rise.png";
        dd->fallSprite = @"Baozi_Fall.png";
        dd->mainSprite = @"Baozi.png";
        dd->grabSprite = @"Baozi_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi.png"]]];
        }
        for(int i = 1; i <= 9; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi_Shoot_%d.png", i]]];
        }
        lp->specialDog = dd;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float scaleX = 1, scaleY = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        } else {
            scaleX = winSize.width/BASE_X_RESOLUTION;
        }
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"China_LightOverlay.png"];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.652, winSize.height*.535);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"China_Lanterns.png"];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.652, winSize.height*.82);
        bgc->sprite.tag = 2;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_china.plist"];
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)japan:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * JAPAN LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"japan";
    lp->name = @"Yamanashi";
    lp->unlockNextThreshold = 10000;
    lp->func = @"switchScreenJapan";
    lp->thumbnail = @"Japan_Thumb.png";
    lp->unlockTweet = @"I was ready to relax in a calming Japanese hot spring in @HeadsUpHotDogs";
    
    if(loadFull){
        lp->bg = @"Japan_BG.png";
        lp->bgm = @"05 - Gourmet Dog Japon.mp3";
        lp->bgmVol = .3;
        lp->sfxVol = .6;
        lp->gravity = -27.0f;
        lp->spritesheet = @"sprites_japan";
        lp->dogDeathDelay = .001;
        lp->personSpeedMul = .7;
        lp->maxDogs = 5;
        lp->gravity = -17.0;
        lp->spawnInterval = 4.0;
        
        lp->dogDeathAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++){
            [lp->dogDeathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Splash_%d.png", i]]];
        }
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"YakisobaPan_Rise.png";
        dd->fallSprite = @"YakisobaPan_Fall.png";
        dd->mainSprite = @"YakisobaPan.png";
        dd->grabSprite = @"YakisobaPan_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Die_2.png"]]];
        }
        for(int i = 1; i <= 11; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 10; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Shoot_%d.png", i]]];
        }
        lp->specialDog = dd;
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_japan.plist"];
    }
    return [NSValue valueWithPointer:lp];
}
    
+(NSValue *)chicago:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * CHICAGO LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"chicago";
    lp->name = @"Chicago";
    lp->unlockNextThreshold = 8000;
    lp->thumbnail = @"Chicago_Thumb.png";
    lp->func = @"switchScreenChicago";
    lp->unlockTweet = @"I traveled to the Windy City in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_chicago.plist"];
        lp->bg = @"Chicago_BG.png";
        lp->bgm = @"04 - Chaos Dog In The Windy City.mp3";
        lp->introAudio = @"03 - Chaos Dog In The Windy City (Intro).mp3";
        lp->gravity = -27.0f;
        lp->spritesheet = @"sprites_chicago";
        lp->sfxVol = .8;
        lp->personSpeedMul = 1;
        lp->restitutionMul = .8;
        lp->frictionMul = 1.1;
        lp->maxDogs = 6;
        lp->hasShiba = true;
        
        spcDogData *dd = new spcDogData();
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
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float scaleX = 1, scaleY = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        }
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Flag_Flap_1.png"] retain];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.96, winSize.height*.765);
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
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.039, winSize.height*.834);
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
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.372, winSize.height*.062);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 6; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Dust1_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_chicago.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)space:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * SPACE LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = false;
    lp->slug = @"space";
    lp->name = @"Space Station";
    lp->unlockNextThreshold = 12000;
    lp->thumbnail = @"Space_Thumb.png";
    lp->func = @"switchScreenSpace";
    lp->unlockTweet = @"We sent a frankfurter to the moon in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_space.plist"];
        lp->bg = @"SpaceBG.png";
        lp->bgm = @"07 - Uchuu Kyoudog.mp3";
        lp->introAudio = @"06 - Uchuu Kyoudog (Intro).mp3";
        lp->gravity = -40.0f;
        lp->spritesheet = @"sprites_space";
        lp->personSpeedMul = 1.1;
        lp->restitutionMul = 1.3;
        lp->frictionMul = 100;
        lp->maxDogs = 6;
        lp->hasShiba = true;
        
        spcDogData *dd = new spcDogData();
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
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        int y = 152.5*(winSize.height/320);
        bgComponent *bgc;
        for(int i = 2; i <= 10; i++){
            bgc = new bgComponent();
            bgc->sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Grav_%d.png", i]];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                bgc->sprite.scaleX = IPAD_SCALE_FACTOR_X;
                bgc->sprite.scaleY = IPAD_SCALE_FACTOR_Y;
            } else {
                bgc->sprite.scaleX = winSize.width/BASE_X_RESOLUTION;
            }
            bgc->sprite.position = CGPointMake(219.5*((float)winSize.width/320), y+((bgc->sprite.scaleY*(bgc->sprite.contentSize.height+.8*IPAD_SCALE_FACTOR_Y))*(i-1)));
            [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        }
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_space.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

@end
