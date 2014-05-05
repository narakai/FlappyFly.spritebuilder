//
//  Obstacle.m
//  FlappyFly
//
//  Created by leon on 14-5-3.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle {
    CCNode *_topPipe;
    CCNode *_bottomPipe;
}

#define ARC4RANDOM_MAX 0X100000000

static const CGFloat minimumYPositionTopPipe = 128.f;
static const CGFloat maximumYPositionBottomPipe = 440.f;
static const CGFloat pipeDistance = 142.f;
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;

-(void)setupRandomPosition{
    //between 0.f to 1.f
    CGFloat random = ((double)arc4random()/ARC4RANDOM_MAX);
    CGFloat range = maximumYPositionTopPipe - minimumYPositionTopPipe;
    // see spritebuilder for ccp
    _topPipe.position = ccp(_topPipe.position.x, minimumYPositionTopPipe+(random * range));
    _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + pipeDistance);
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    _topPipe.physicsBody.collisionType = @"level";
    _topPipe.physicsBody.sensor = TRUE;
    _bottomPipe.physicsBody.collisionType = @"level";
    _bottomPipe.physicsBody.sensor = TRUE;
}

@end
