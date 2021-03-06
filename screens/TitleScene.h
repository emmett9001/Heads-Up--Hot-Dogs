//
//  TitleScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "cocos2d.h"
#import <SimpleAudioEngine.h>
#import "Clouds.h"

@interface TitleLayer : CCLayer <CDLongAudioSourceDelegate>
{
    CCSpriteBatchNode *spriteSheet;
    CCAnimation *titleAnim;
    CCAction *titleAnimAction;
    CCSprite *background, *cloud1, *cloud2, *cloud3, *dogLogo, *swooshLogo;
    CGRect screen, _startRect, _optionsRect, _moreGamesRect, _newsRect;
    CGPoint dogLogoAnchor, swooshLogoAnchor;
    CGSize winSize;
    ccColor3B _color_pink;
    NSUserDefaults *standardUserDefaults;
    UIViewController *myController;
    float introSoundLen;
    ALuint soundId;
    CDSoundEngine *engine;
    float time;
    Clouds *clouds;
}

+(CCScene *) scene;

@property (nonatomic, retain) CCFiniteTimeAction *titleAnimAction;


@end