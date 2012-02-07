//
//  HelloWorldLayer.mm
//  Heads Up Hot Dogs
//
//  Created by Emmett Butler and Diego Garcia on 1/3/12.
//  Copyright Emmett and Diego 2012. All rights reserved.
//

// Import the interfaces
#import "GameplayLayer.h"
#import "TitleScene.h"

#define PTM_RATIO 32
#define FLOOR1_HT 0
#define FLOOR2_HT .4
#define FLOOR3_HT .8
#define FLOOR4_HT 1.2
#define DOG_SPAWN_MINHT 240

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

// HelloWorldLayer implementation
@implementation GameplayLayer

@synthesize person = _person;
@synthesize wiener = _wiener;
@synthesize target = _target;
@synthesize flyAction = _flyAction;
@synthesize hitAction = _hitAction;

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	GameplayLayer *layer = [GameplayLayer node];
	[scene addChild: layer];
	return scene;
}

-(void)putDog:(id)sender data:(void*)params {
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSValue *loc = (NSValue *)[incomingArray objectAtIndex: 0];
    CGPoint location = [loc CGPointValue];
    
    // Create sprite and add it to the layer
    self.wiener = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"];
    _wiener.position = ccp(location.x, location.y);
    _wiener.tag = 1;
    int floor = arc4random() % 4;
    [self addChild:_wiener];
    
    // Create wiener body and shape
    b2BodyDef wienerBodyDef;
    wienerBodyDef.type = b2_dynamicBody;
    wienerBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    wienerBodyDef.userData = _wiener;
    wienerBody = _world->CreateBody(&wienerBodyDef);
    
    b2PolygonShape wienerShape;
    wienerShape.SetAsBox(_wiener.contentSize.width/PTM_RATIO/2, _wiener.contentSize.height/PTM_RATIO/2);
    
    b2FixtureDef wienerShapeDef;
    wienerShapeDef.shape = &wienerShape;
    wienerShapeDef.density = 0.2f;
    wienerShapeDef.friction = 0.2f;
    wienerShapeDef.userData = (void *)1;
    wienerShapeDef.restitution = 0.5f;
    wienerShapeDef.filter.categoryBits = WIENER;
    //random assignment of floor to collide, ONLY FOR TESTING
    if(floor == 1){
        wienerShapeDef.filter.maskBits = PERSON | FLOOR1 | WIENER | TARGET;
    }
    else if(floor == 2){
        wienerShapeDef.filter.maskBits = PERSON | FLOOR2 | WIENER | TARGET;
    }
    else if(floor == 3){
        wienerShapeDef.filter.maskBits = PERSON | FLOOR3 | WIENER | TARGET;
    }
    else if(floor == 4){
        wienerShapeDef.filter.maskBits = PERSON | FLOOR4 | WIENER | TARGET;
    }
    _wienerFixture = wienerBody->CreateFixture(&wienerShapeDef);

    b2PolygonShape wienerGrabShape;
    wienerShape.SetAsBox((_wiener.contentSize.width+30)/PTM_RATIO/2, (_wiener.contentSize.height+30)/PTM_RATIO/2);

    b2FixtureDef wienerGrabShapeDef;
    wienerGrabShapeDef.shape = &wienerShape;
    wienerGrabShapeDef.filter.categoryBits = WIENER;
    wienerGrabShapeDef.filter.maskBits = 0x0000;
    _wienerFixture = wienerBody->CreateFixture(&wienerGrabShapeDef);
}

-(void)spawnTarget:(id)sender data:(void *)params {
    self.target = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"];
    _target.position = ccp(200, 200);
    _target.tag = 2;
    [self addChild:_target];
    
    b2BodyDef targetBodyDef;
    targetBodyDef.type = b2_staticBody;
    targetBodyDef.position.Set(150/PTM_RATIO, 270/PTM_RATIO);
    targetBodyDef.userData = _target;
    targetBody = _world->CreateBody(&targetBodyDef);
    
    b2PolygonShape targetShape;
    targetShape.SetAsBox((_target.contentSize.width+30)/PTM_RATIO/2, _target.contentSize.height/PTM_RATIO/2);
    //targetShape.SetAsBox(40/PTM_RATIO/2, 40/PTM_RATIO/2);
    
    b2FixtureDef targetShapeDef;
    targetShapeDef.shape = &targetShape;
    targetShapeDef.userData = (void *)2;
    targetShapeDef.isSensor = true;
    targetShapeDef.filter.categoryBits = TARGET;
    targetShapeDef.filter.maskBits = WIENER;
    _targetFixture = targetBody->CreateFixture(&targetShapeDef);
}

-(void)walkIn:(id)sender data:(void *)params {
    int xVel, velocityMul, zIndex, fixtureUserData;
    float hitboxHeight, hitboxWidth, hitboxCenterX, hitboxCenterY, density, restitution, friction;

    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    BOOL spawn = YES;
    NSNumber *floorBit = [floorBits objectAtIndex:arc4random() % [floorBits count]];

    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSNumber *xPos = (NSNumber *)[incomingArray objectAtIndex:0];
    NSNumber *character = (NSNumber *)[incomingArray objectAtIndex:1];
    
    switch(character.intValue){
        case 1:
            self.person = [CCSprite spriteWithSpriteFrameName:@"Business_sm.png"];
            _person.tag = 3;
            hitboxWidth = 22.0;
            hitboxHeight = 1;
            hitboxCenterX = 0;
            hitboxCenterY = 2.9;
            velocityMul = 300;
            density = 10.0f;
            restitution = .8f;
            friction = 1.5f;
            fixtureUserData = 3;
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
    }

    if( xPos.intValue == winSize.width ){
        xVel = -1*velocityMul;
    }
    else {
        _person.flipX = YES; //facing the other way
        xVel = 1*velocityMul;
    }
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
			CCSprite *sprite = (CCSprite *)body->GetUserData();
            if(sprite.tag >= 3 && sprite.tag <= 10){
                for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
                    if(f->GetFilterData().maskBits == floorBit.intValue){
                        if(body->GetLinearVelocity().x * xVel < 0){
                            spawn = NO;
                        }
                    }
                }
            }
        }
    }
    
    if(spawn){
        CCLOG(@"Spawned person with tag %d", fixtureUserData);
        if(floorBit.intValue == 1){
            zIndex = 400;
        }
        else if(floorBit.intValue == 2){
            zIndex = 300;
        }
        else if(floorBit.intValue == 4){
            zIndex = 200;
        }
        else{
            zIndex = 100;
        }
    
        _person.position = ccp(xPos.intValue, 123);
        [spriteSheet addChild:_person z:zIndex];

        b2BodyDef personBodyDef;
        personBodyDef.type = b2_dynamicBody;
        personBodyDef.position.Set(xPos.floatValue/PTM_RATIO, 123.0f/PTM_RATIO);
        personBodyDef.userData = _person;
        _personBody = _world->CreateBody(&personBodyDef);

        b2PolygonShape personShape;
        personShape.SetAsBox(hitboxWidth/PTM_RATIO, hitboxHeight/PTM_RATIO, b2Vec2(hitboxCenterX, hitboxCenterY), 0);
        b2FixtureDef personShapeDef;
        personShapeDef.shape = &personShape;
        personShapeDef.density = density;
        personShapeDef.friction = friction;
        personShapeDef.restitution = restitution;
        personShapeDef.userData = (void *)fixtureUserData;
        personShapeDef.filter.categoryBits = PERSON;
        personShapeDef.filter.maskBits = WIENER;
        _personFixture = _personBody->CreateFixture(&personShapeDef);
        
        b2PolygonShape personBodyShape;
        personBodyShape.SetAsBox(_person.contentSize.width/PTM_RATIO/2, _person.contentSize.height/PTM_RATIO/2);
        b2FixtureDef personBodyShapeDef;
        personBodyShapeDef.shape = &personBodyShape;
        personBodyShapeDef.density = 5;
        personBodyShapeDef.friction = 0;
        personBodyShapeDef.restitution = 0;
        personBodyShapeDef.filter.categoryBits = BODYBOX;
        personBodyShapeDef.filter.maskBits = floorBit.intValue;
        _personFixture = _personBody->CreateFixture(&personBodyShapeDef);
        
        b2Vec2 force = b2Vec2(xVel,0);
        _personBody->ApplyLinearImpulse(force, personBodyDef.position);
    }
}

//this seems to only work on one sprite at a time
-(void)runBoxLoop:(id)sender{
    //CCSprite *sprite = (CCSprite *)sender;
    //self.flyAction = [CCRepeatForever actionWithAction:
    //                  [CCAnimate actionWithAnimation:flyAnim restoreOriginalFrame:NO]];
    //[sprite runAction: _flyAction];
}

- (void)switchScene{
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[TitleLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

-(void)wienerCallback:(id)sender data:(void *)params {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //NSMutableArray *incomingArray = (NSMutableArray *) params;
    //NSValue *loc = (NSValue *)[incomingArray objectAtIndex:0];
    
    [self putDog:self data:params];
    
    wienerParameters = [[NSMutableArray alloc] initWithCapacity:1];
    NSValue *location = [NSValue valueWithCGPoint:CGPointMake(arc4random() % (int)winSize.width, DOG_SPAWN_MINHT+(arc4random() % (int)(winSize.height-DOG_SPAWN_MINHT)))];
    [wienerParameters addObject:location];
    
    CCLOG(@"Wiener Callback");
    
    double time = 2.0f;
    id delay = [CCDelayTime actionWithDuration:time];
    id callBackAction = [CCCallFuncND actionWithTarget: self selector: @selector(wienerCallback:data:) data:wienerParameters];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence]; 
}

-(void)spawnCallback:(id)sender data:(void *)params {    
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSNumber *xPos = (NSNumber *)[incomingArray objectAtIndex:0];
    NSNumber *characterTag = (NSNumber *)[incomingArray objectAtIndex:1];
    
    NSNumber *xPosition = [xPositions objectAtIndex:arc4random() % [xPositions count]];
    xPos = [NSNumber numberWithInt:xPosition.intValue];
    
    characterTag = [characterTags objectAtIndex:arc4random() % [characterTags count]];
    
    [self walkIn:self data:params];

    personParameters = [[NSMutableArray alloc] initWithCapacity:3];
    [personParameters addObject:xPos];
    [personParameters addObject:characterTag];
        
    double time = .7f;
    id delay = [CCDelayTime actionWithDuration:time];
    id callBackAction = [CCCallFuncND actionWithTarget: self selector: @selector(spawnCallback:data:) data:personParameters];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence];    
}

-(void)debugDraw{
    if(!m_debugDraw){
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        flags += b2DebugDraw::e_jointBit;
        flags += b2DebugDraw::e_aabbBit;
        flags += b2DebugDraw::e_pairBit;
        flags += b2DebugDraw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags); 
    } else {
        m_debugDraw = nil;
    }
    _world->SetDebugDraw(m_debugDraw);
}

-(id) init {
	if( (self=[super init])) {
		CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *background = [CCSprite spriteWithFile:@"bg_philly.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-1];
        
        scoreText = [[NSString alloc] initWithFormat:@"%d", _points];
        scoreLabel = [CCLabelTTF labelWithString:scoreText fontName:@"Marker Felt" fontSize:18];
        scoreLabel.position = ccp(winSize.width-100, 310);
        [self addChild: scoreLabel];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Title screen" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScene)];
        label = [CCLabelTTF labelWithString:@"Debug draw" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];
        CCMenu *menu = [CCMenu menuWithItems:button, debug, nil];
        [menu setPosition:ccp(40, winSize.height-30)];
        [menu alignItemsVertically];
        [self addChild:menu];
        
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        
        //initialize global arrays for possible x,y positions and charTags
        floorBits = [[NSMutableArray alloc] initWithCapacity:4];;
        for(int i = 1; i <= 8; i *= 2){
            [floorBits addObject:[NSNumber numberWithInt:i]];
        }
        xPositions = [[NSMutableArray alloc] initWithCapacity:2];
        [xPositions addObject:[NSNumber numberWithInt:winSize.width]];
        [xPositions addObject:[NSNumber numberWithInt:0]];
        characterTags = [[NSMutableArray alloc] initWithCapacity:1];
        for(int i = 1; i < 2; i++){
            [characterTags addObject:[NSNumber numberWithInt:i]];
        }
        
        b2Vec2 gravity = b2Vec2(0.0f, -30.0f);
        
        bool doSleep = true;
        _world = new b2World(gravity, doSleep);
        
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        groundBodyDef.userData = (void*)100;
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        groundBoxDef.filter.categoryBits = FLOOR1;
        groundBoxDef.userData = (void*)100;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR1_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR1_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR2;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR2_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR2_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR3;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR3_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR3_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR4;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR4_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR4_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        b2BodyDef wallsBodyDef;
        wallsBodyDef.position.Set(0,0);
        _wallsBody = _world->CreateBody(&wallsBodyDef);
        b2PolygonShape wallsBox;
        b2FixtureDef wallsBoxDef;
        wallsBoxDef.shape = &wallsBox;
        wallsBoxDef.filter.categoryBits = WALLS;
        wallsBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _wallsFixture = _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        _wallsBody->CreateFixture(&wallsBoxDef);

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spriteSheet];
        
        _points = 0;
        
        /*NSMutableArray *flyAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 3; ++i){
            [flyAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"box_%d.png", i]]];
        }
        
        NSMutableArray *hitAnimFrames = [NSMutableArray array];
        [hitAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"box_hit.png"]];
        hitAnim = [CCAnimation animationWithFrames:hitAnimFrames delay:0.1f];
        flyAnim = [CCAnimation animationWithFrames:flyAnimFrames delay:0.9f];*/

        personDogContactListener = new PersonDogContactListener();
		_world->SetContactListener(personDogContactListener);
        
        personParameters = [[NSMutableArray alloc] initWithCapacity:2];
        NSNumber *xPos = [NSNumber numberWithInt:winSize.width]; 
        NSNumber *character = [NSNumber numberWithInt:1]; 
        [personParameters addObject:xPos];
        [personParameters addObject:character];
        [self spawnCallback:self data:personParameters];
        
        NSMutableArray *wienerParams = [[NSMutableArray alloc] initWithCapacity:1];
        NSValue *location = [NSValue valueWithCGPoint:CGPointMake(200, 200)]; 
        [wienerParams addObject:location];
        [self wienerCallback:self data:wienerParams];
        
        //this takes params only as a dummy filler for now
        [self spawnTarget: self data:personParameters];
		
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw {
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	_world->DrawDebugData();
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

-(void)destroyWiener:(id)sender data:(void*)params {
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSValue *dog = (NSValue *)[incomingArray objectAtIndex:0];
    b2Body *dogBody = (b2Body *)[dog pointerValue];
    
    CCSprite *dogSprite = (CCSprite *)sender;
    
    CCLOG(@"Destroying dog...");
    
    if(dogSprite.tag == 1){
        dogBody->SetAwake(false);
        [dogSprite stopAllActions];
        [dogSprite removeFromParentAndCleanup:YES];
        _world->DestroyBody(dogBody);
        dogBody->SetUserData(NULL);
        dogBody = 0;
    }

    CCLOG(@"done.");
}

-(void) tick: (ccTime) dt {
    int32 velocityIterations = 8;
	int32 positionIterations = 1;

	_world->Step(dt, velocityIterations, positionIterations);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
	
    b2Filter filter;
    
    int floor = arc4random() % 4;
    
    for(b2Joint* j = _world->GetJointList(); j; j = j->GetNext()){
        if(j->GetType() == e_prismaticJoint){
            b2PrismaticJoint* p = (b2PrismaticJoint *)j;
            if((float32)p->GetJointTranslation() > (float32)p->GetUpperLimit() - .05 || 
               (float32)p->GetJointTranslation() < (float32)p->GetLowerLimit() + .05){
                _world->DestroyJoint(j);
                b2Body* b = j->GetBodyA();
                for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()){
                    if(f->GetUserData() == (void*)1){
                        filter = f->GetFilterData();
                        //TODO - find a way to assign this appropriately (maybe random, maybe not)
                        //TODO - replace all copypasta of this code with one single one outside of any loop in tick() (MAYBE)
                        if(floor == 1){
                            filter.maskBits = PERSON | FLOOR1 | WIENER | TARGET;
                        }
                        else if(floor == 2){
                            filter.maskBits = PERSON | FLOOR2 | WIENER | TARGET;
                        }
                        else if(floor == 3){
                            filter.maskBits = PERSON | FLOOR3 | WIENER | TARGET;
                        }
                        else{
                            filter.maskBits = PERSON | FLOOR4 | WIENER | TARGET;
                        }
                        f->SetFilterData(filter);
                    }
                }
                CCLOG(@"Prism joint destroyed");
            }
            else {
                _points += 100;
            }
        }
    }
    
    [scoreLabel setString:[NSString stringWithFormat:@"%d", _points]];

    b2Joint* prismJoint = NULL;
    PersonDogContact pdContact;
    
	std::vector<PersonDogContact>::iterator pos;
	for(pos = personDogContactListener->contacts.begin();
		pos != personDogContactListener->contacts.end(); ++pos)
	{
        b2Body *pBody, *tBody;
        b2Body *dogBody;
        pdContact = *pos;
        
        if(pdContact.fixtureA->GetBody() != NULL){
            dogBody = pdContact.fixtureA->GetBody();
        }
        
        if(dogBody){
            if(pdContact.fixtureB->GetUserData() >= (void*)3 && pdContact.fixtureB->GetUserData() <= (void*)10){
                pBody = pdContact.fixtureB->GetBody();
                CCLOG(@"Dog/Person Collision");
                _points += 10;
                CCLOG(@"Dog Y Vel: %0.2f", dogBody->GetLinearVelocity().x);
                if(dogBody->GetLinearVelocity().y < 2.0){
                    _points += 50;
                    
                    filter = pdContact.fixtureA->GetFilterData();
                    filter.maskBits = 0x0000;
                    pdContact.fixtureA->SetFilterData(filter);
            
                    b2PrismaticJointDef jointDef;
                    b2Vec2 worldAxis(1.0f, 0.0f);
                    jointDef.lowerTranslation = -.2f;
                    jointDef.upperTranslation = .2f;
                    jointDef.enableLimit = true;
                    jointDef.Initialize(dogBody, pBody, dogBody->GetWorldCenter(), worldAxis);
                    prismJoint = _world->CreateJoint(&jointDef);
                    CCLOG(@"Prism joint created");
                }
            } 
            else if (pdContact.fixtureB->GetUserData() == (void*)2){
                tBody = pdContact.fixtureB->GetBody();
                CCSprite *tSprite = (CCSprite *)tBody->GetUserData();
                CCLOG(@"Dog/Target Collision");
                _world->DestroyBody(tBody);
                [tSprite removeFromParentAndCleanup:YES];
            }
            else if (pdContact.fixtureB->GetUserData() == (void*)100){
                CCLOG(@"Dog/Ground Collision (Dog y Velocity: %0.2f)", dogBody->GetLinearVelocity().y);
                wienerParameters = [[NSMutableArray alloc] initWithCapacity:1];
                [wienerParameters addObject:[NSValue valueWithPointer:dogBody]];
                CCSprite *dogSprite = (CCSprite *)dogBody->GetUserData();
                
                //TODO - allow interrupting this action via pickup
                
                id delay = [CCDelayTime actionWithDuration:2.0f];
                id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:wienerParameters];
                id sequence = [CCSequence actions: delay, destroyAction, nil];
                [dogSprite runAction:sequence]; 
            }
        }
        /*if(sprite.tag == 2){
            [sprite stopAllActions];
            [sprite runAction:[CCSequence actions:_hitAction,
                               [CCCallFuncN actionWithTarget:self selector:@selector(runBoxLoop:)],nil]];
        }*/
	}
    personDogContactListener->contacts.clear();
    
    //Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
            if(b->GetUserData() != (void*)100){
                //Synchronize the AtlasSprites position and rotation with the corresponding body
                CCSprite *myActor = (CCSprite*)b->GetUserData();
                if(myActor.position.x > winSize.width || myActor.position.x < 0){
                    _world->DestroyBody(b);
                    [myActor removeFromParentAndCleanup:YES];
                }
                else {
                    if(myActor.tag == 1){
                        
                    }
                    else if(myActor.tag >= 3 && myActor.tag <= 10){
                        for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()){
                            
                        }
                    }
                    myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                    myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
                }
            }
		}
        else{
            //_world->DestroyBody(b);
        }
	}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint != NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _touchedDog = NO;
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            b2Fixture *fixture = body->GetFixtureList();
			CCSprite *sprite = (CCSprite *)body->GetUserData();
            if(sprite.tag == 1){
                if (fixture->TestPoint(locationWorld)) {
                    [sprite stopAllActions];
                    
                    CCLOG(@"Touching hotdog");
                    b2MouseJointDef md;
                    md.bodyA = _groundBody;
                    md.bodyB = body;
                    md.target = locationWorld;
                    md.collideConnected = true;
                    md.maxForce = 10000.0f * body->GetMass();
                    
                    _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                    body->SetAwake(true);
                    
                    _touchedDog = YES;
                    break;
                }
                else {
                    _touchedDog = NO;
                }
            }
		}
    }
    CCLOG(@"Touched Dog: %d", _touchedDog);
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_mouseJoint == NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    CCLOG(@"Mousejoint target @ %0.2f x %0.2f", location.x, location.y);
    
    _mouseJoint->SetTarget(locationWorld);
    CCSprite *sprite = (CCSprite *)_mouseJoint->GetBodyB()->GetUserData();
    [sprite stopAllActions];
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL  && body->GetUserData() != (void*)100) {
            for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
    			CCSprite *sprite = (CCSprite *)body->GetUserData();
                if(sprite.tag == 1){
                    if (fixture->TestPoint(locationWorld)) {
                        body->SetLinearVelocity(b2Vec2(0, 0));
                    }
                }
            }
		}
    }
}
 
- (void) dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures]; 
    
    self.person = nil;
    self.wiener = nil;
    self.target = nil;
	//self.flyAction = nil;
    //self.hitAction = nil;

    [scoreText release];
    [floorBits release];
    [xPositions release];
    [characterTags release];
    [wienerParameters release];
    [personParameters release];
    
    
    delete personDogContactListener;
    
    delete _world;
	_world = NULL;
    
	[super dealloc];
}
@end
