//
//  NCGameViewController.h
//  Noughts and Crosses
//
//  Created by Ashley Connor on 05/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameAreaView.h"
#import "ScoreAreaView.h"
#import "NCGameModel.h"

#define BOARD_SIZE 3

@class NCGameModel;

@interface NCGameViewController : UIViewController {
    GameAreaView *gameView;
    ScoreAreaView *scoreView;
    UILabel *statusLabel, *humanScoreLabel, *iOSScoreLabel;
    NCGameModel *gameModel;
}

- (IBAction)resetGame;

- (int)whichPositionIsTouchPoint: (CGPoint)touchPoint;
- (CGPoint)whichTouchPointIsPosition: (int)position;


@property (nonatomic, retain) IBOutlet GameAreaView *gameView;
@property (nonatomic, retain) IBOutlet ScoreAreaView *scoreView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *humanScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *iOSScoreLabel;
@property (nonatomic, retain) NCGameModel *gameModel;

@end
