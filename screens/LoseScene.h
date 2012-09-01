//
//  LoseScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"
#import <CocosDenshion/SimpleAudioEngine.h>
#import "LevelSelectLayer.h"
#import <Twitter/Twitter.h>
#import "AchievementReporter.h"

@interface LoseLayer : CCLayer
{
    int _score, _timePlayed, _peopleGrumped, _dogsSaved, _lock;
    CCLabelTTF *scoreLine, *timeLine, *dogsLine, *peopleLine, *highScoreLine;
    CCLabelTTF *scoreNotify, *timeNotify;
    CCSpriteBatchNode *spriteSheet;
    CCSprite *levelBox;
    CCLabelTTF *levelLabel1, *levelLabel2;
    NSInteger highScore;
    ALuint sting;
    AchievementReporter *reporter;
    BOOL touchLock, _setNewHighScore;
    CGRect _twitterRect;
    NSString *slug;
    NSMutableArray *tweets;
    ccColor3B _color_pink, _color_blue, _color_darkblue;
    levelProps *level;
}

+(CCScene *) sceneWithData:(void*)data;


@end