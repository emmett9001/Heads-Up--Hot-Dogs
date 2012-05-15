//
//  HelloWorldLayer.h
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//

//character sprite tags will be in the range 3-10
//3: businessman
//4:

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PersonDogContactListener.h"

@interface GameplayLayer : CCLayer
{
    b2World *_world;
    GLESDebugDraw *m_debugDraw;
    b2Body *_wallsBody, *_groundBody, *wienerBody, *targetBody, *_personBody, *_policeArmBody;
    b2Fixture *_bottomFixture, *_wallsFixture, *_wienerFixture, *_targetFixture, *_personFixture, *_policeArmFixture;
    CCSprite *_wiener, *_personLower, *_personUpper, *_target, *_pauseButton;
    b2MouseJoint *_mouseJoint;
    CCAction *_walkAction, *_walkFaceAction;
    CCFiniteTimeAction *_idleAction, *_appearAction, *_hitAction, *_shotAction, *_shootAction, *_armShootAction, *_shootFaceAction, *_plusTenAction, *_plus25Action;
    CCAnimation *walkAnim, *idleAnim, *hitAnim, *dogDeathAnim, *dogAppearAnim, *walkFaceAnim, *walkDogFaceAnim;
    CCAnimation *dogShotAnim, *shootAnim, *armShootAnim, *shootFaceAnim, *plusTenAnim, *plus25Anim;
    CCSpriteBatchNode *spriteSheet;
    CCLabelTTF *scoreLabel, *droppedLabel, *tutorialLabel;
    b2Vec2 policeRayPoint1, policeRayPoint2;
    b2RevoluteJoint *policeArmJoint;
    CCLayerColor *_pauseLayer;
    CCLayer *_introLayer;
    CCMenu *_pauseMenu;
    NSMutableArray *floorBits, *xPositions, *characterTags, *wienerParameters, *headParams;
    NSMutableArray *personParameters, *wakeParameters, *movementPatterns, *movementParameters, *_touchLocations, *dogIcons;
    NSString *scoreText, *droppedText;
    int _points, _droppedCount, _spawnLimiter, time, _curPersonMaskBits, _droppedSpacing, _lastTouchTime, _firstDeathTime, lowerArmAngle, upperArmAngle;
    int _peopleGrumped, _dogsSaved;
    float _personSpawnDelayTime, _wienerSpawnDelayTime, _wienerKillDelay, _currentRayAngle;
    BOOL _moving, _touchedDog, _rayTouchingDog, _pause, _shootLock, _intro, _dogHasHitGround, _dogHasDied;
    NSString *currentAnimation;
    CGRect _pauseButtonRect;
    NSUserDefaults *standardUserDefaults;
    CCDelayTime *winUpDelay, *winDownDelay;
    CCCallFuncN *removeWindow;

    struct bodyUserData {
        CCSprite *sprite1;
        CCSprite *sprite2;
        float heightOffset2;
        float lengthOffset2;
        NSString *ogSprite2;
        NSString *altSprite2;
        NSString *altSprite3; //the 3 here has a different meaning than the 2 above - ie it's the 3rd sprite
        CCSprite *overlaySprite;
        CCAction *altAction;
        CCAction *altAction2;
        CCAction *altAction3;
        CCAnimation *defaultAnim;
        CCAnimation *altAnimation;
        CCAnimation *altWalkAnim;
        float armSpeed;
        BOOL aiming;
        BOOL aimedAt;
        BOOL animLock;
        double targetAngle;
        int dogsOnHead;
        BOOL hasTouchedHead;
        BOOL _dog_isOnHead;
        BOOL _person_hasTouchedDog;
    };

    struct fixtureUserData {
        int tag;
        int ogCollideFilters;
    };

    enum _collisionFilters {
        FLOOR1  = 0x0001,
        FLOOR2  = 0x0002,
        FLOOR3  = 0x0004,
        FLOOR4  = 0x0008,
        WALLS   = 0x0010,
        WIENER  = 0x0040,
        BODYBOX = 0x0080, // character bodies
        TARGET  = 0x0100,
        SENSOR  = 0x0200,
    };
    
    enum _spriteTags {
        S_HOTDOG    =   1,
        S_BUSMAN    =   3,
        S_POLICE    =   4,
        S_TOPPSN    =   10, // top person sprite tag, this must be TOPPSN > POLICE > BUSMAN with only person tags between
        S_COPARM    =   11,
        S_CRSHRS    =   20, // crosshairs
    };
    
    enum _fixtureTags {
        F_DOGGRB    =   0, // hotdog grab box
        F_DOGCLD    =   1, // hotdog collisions
        F_BUSHED    =   3, // businessman's head
        F_COPHED    =   4, // cop's head
        F_TOPHED    =   10, // top head fixture tag, this must be TOPHED > COPHED > BUSHED with only head tags between
        F_COPARM    =   11, 
        F_BUSBDY    =   53, // businessman's body
        F_COPBDY    =   54, // cop's body
        F_TOPBDY    =   60, // top body fixture tag, this must be TOPBDY > COPBDY > BUSBDY with only body tags between
        F_GROUND    =   100,
        F_WALLS     =   101,
        F_BUSSEN    =   103, // sensor above businessman's head
        F_COPSEN    =   104, // sensor above cop's head
        F_TOPSEN    =   110, // top head sensor tag, this must be TOPSEN > COPSEN > BUSSEN with only sensor tags between
    };
    
    PersonDogContactListener *personDogContactListener;
}

@property (nonatomic, retain) CCSprite *personLower;
@property (nonatomic, retain) CCSprite *personUpper;
@property (nonatomic, retain) CCSprite *policeArm;
@property (nonatomic, retain) CCSprite *wiener;
@property (nonatomic, retain) CCSprite *target;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *walkFaceAction;
@property (nonatomic, retain) CCAction *idleAction;
@property (nonatomic, retain) CCFiniteTimeAction *deathAction;
@property (nonatomic, retain) CCFiniteTimeAction *idleFaceAction;
@property (nonatomic, retain) CCFiniteTimeAction *shotAction;
@property (nonatomic, retain) CCFiniteTimeAction *shootAction;
@property (nonatomic, retain) CCFiniteTimeAction *shootFaceAction;
@property (nonatomic, retain) CCFiniteTimeAction *armShootAction;
@property (nonatomic, retain) CCFiniteTimeAction *plusTenAction;
@property (nonatomic, retain) CCFiniteTimeAction *plus25Action;
@property (nonatomic, retain) CCAction *appearAction;
@property (nonatomic, retain) NSString *hitFace;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
