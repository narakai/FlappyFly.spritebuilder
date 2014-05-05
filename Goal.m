//
//  Goal.m
//  FlappyFly
//
//  Created by leon on 14-5-3.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end
