//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"

//static const CGFloat scrollSpeed = 80.f;

@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    CCButton *_restartButton;
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    NSInteger _points;
    CCLabelTTF *_scoreLable;
}

//x position of the first obstacle and the distance between two obstacles
static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f;

//define drawing order
typedef NS_ENUM(NSInteger, DrawingOrder){
  DrawingOrderPipes,
  DrawingOrderGround,
  DrawingOrderHero
};

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    
    _scrollSpeed = 80.f;
    _grounds = @[_ground1,_ground2];
    self.userInteractionEnabled = TRUE;
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    for (CCNode *ground in _grounds) {
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    _physicsNode.collisionDelegate = self;
    
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrderHero;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if (!_gameOver) {
    //speed
    [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
    //turning speed
    [_hero.physicsBody applyAngularImpulse:10000.f];
    _sinceTouch = 0.f;
    }
}

-(void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (delta * _scrollSpeed), _physicsNode.position.y);
    
    //loop the ground
    for (CCNode *ground in _grounds) {
        // see spritebuilder to find the detail
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        CGPoint groundScreenPosotion = [self convertToNodeSpace:groundWorldPosition];
        if (groundScreenPosotion.x <= (-1*ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2*ground.contentSize.width, ground.position.y);
        }
    }
    
    //change y speed
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1*MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0,yVelocity);
    
    _sinceTouch += delta;
    //rotation
    _hero.rotation = clampf(_hero.rotation, -30.f, 90.f);
    //rotation speed
    if (_hero.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
    }
    
    //increase speed if _sinceTouch increased
    if ((_sinceTouch > 0.5f)) {
        [_hero.physicsBody applyAngularImpulse:-40000.f*delta];
    }
    
    //endless obstacle
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            //if no offScreenObstacles then create an array to store offScreenObstacles
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    
    //remove list
    for (CCNode *obstacleToMove in offScreenObstacles) {
        [obstacleToMove removeFromParent];
        [_obstacles removeObject:obstacleToMove];
        [self spawnNewObstacle];
    }
    
}
    -(void)spawnNewObstacle {
        CCNode *previousObstacle = [_obstacles lastObject];
        CGFloat previousObstacleXPosition = previousObstacle.position.x;
        if (!previousObstacle) {
            previousObstacleXPosition = firstObstaclePosition;
        }
        Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
        obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
        [obstacle setupRandomPosition];
        [_physicsNode addChild:obstacle];
        [_obstacles addObject:obstacle];
        obstacle.zOrder = DrawingOrderPipes;
}

//-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
//    CCLOG(@"GAME OVER");
//    _restartButton.visible = TRUE;
//}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level
{
//    CCLOG(@"GAME OVER");
    [self gameOver];
//    _restartButton.visible = TRUE;
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal{
    [goal removeFromParent];
    _points++;
    _scoreLable.string = [NSString stringWithFormat:@"%d", _points];
    return TRUE;
}

-(void)restart{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)gameOver{
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}

@end