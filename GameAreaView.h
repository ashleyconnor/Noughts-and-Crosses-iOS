//
//  GameAreaView.h
//  Noughts and Crosses
//
//  Created by Ashley Connor on 05/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCGameModel.h"

#define BOARD_LINE_WIDTH 10.0
#define BOARD_LINE_RED 0.5
#define BOARD_LINE_GREEN 0.5
#define BOARD_LINE_BLUE 0.5
#define BOARD_LINE_ALPHA 1.0

#define WINNING_LINE_WIDTH 10.0
#define WINNING_LINE_RED 1.0
#define WINNING_LINE_GREEN 0.0
#define WINNING_LINE_BLUE 0.0
#define WINNING_LINE_ALPHA 0.5

@class NCGameModel;

@interface GameAreaView : UIView {
    NCGameModel *gameModel;
}

- (void)drawCounter:(NC_CounterType)counterType atPosition:(int)position;
- (void)drawWinningLine:(int)winngLine;

@property (nonatomic, retain) NCGameModel *gameModel;

@end
