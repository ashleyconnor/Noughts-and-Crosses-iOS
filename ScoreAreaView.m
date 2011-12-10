//
//  ScoreAreaView.m
//  Noughts and Crosses
//
//  Created by Ashley Connor on 05/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreAreaView.h"

@implementation ScoreAreaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)updateiOSScoreLabel: (int)score {
    NSString *newScore = [NSString stringWithFormat:@"%d", score];
    [iOSScoreLabel setText:newScore];
}

-(void)updateHumanScoreLabel: (int)score {
    NSString *newScore = [NSString stringWithFormat:@"%d", score];
    [humanScoreLabel setText:newScore];
}

@end
