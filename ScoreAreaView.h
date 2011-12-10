//
//  ScoreAreaView.h
//  Noughts and Crosses
//
//  Created by Ashley Connor on 05/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreAreaView : UIView {
    UILabel *humanScoreLabel, *iOSScoreLabel;
}

-(void)updateHumanScoreLabel: (int)score;
-(void)updateiOSScoreLabel: (int)score;

@end
