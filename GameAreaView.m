//
//  GameAreaView.m
//  Noughts and Crosses
//
//  Created by Ashley Connor on 05/11/2011.
//  Copyright (c) 2011 Merseysoft. All rights reserved.
//

#import "GameAreaView.h"

@implementation GameAreaView

@synthesize gameModel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int boardSize;
    float viewHeight, viewWidth;
    
    //Get the height and width of current view
    viewHeight = self.bounds.size.height;
    viewWidth = self.bounds.size.width;
    
    //Get the number number of squares horizontally/vertically
    //Doesn't feel right talking to the model from a view. Should write a method in controller to get model size?
    boardSize = [gameModel getBoardSize];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Setup line formatting
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, BOARD_LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(context, BOARD_LINE_RED, BOARD_LINE_GREEN, BOARD_LINE_BLUE, BOARD_LINE_ALPHA);
    
    //Calculate increments between each line to be drawn
    float lineHeightIncrement = viewHeight / boardSize;
    float lineWidthIncrement = viewWidth / boardSize;
    
    //Loop through drawing horizontal/vertical lines to make the grid
    for (int i = 1; i < boardSize; i++) {
        
        CGContextBeginPath(context);
        
        //Draw vertical lines
        CGContextMoveToPoint(context, i * lineWidthIncrement, BOARD_LINE_WIDTH);
        CGContextAddLineToPoint(context, i * lineWidthIncrement, viewHeight - BOARD_LINE_WIDTH);
        
        //Draw horizontal lines
        CGContextMoveToPoint(context, BOARD_LINE_WIDTH, i * lineHeightIncrement);
        CGContextAddLineToPoint(context, viewWidth - BOARD_LINE_WIDTH, i * lineHeightIncrement);
        
        CGContextStrokePath(context);
    }
    
    //Loop through model drawing nought/cross counters
    for (int i = 0; i < [gameModel getNumberOfPositions]; i++) {
        NC_CounterType counterType = [gameModel getCounterAtPosition:i];
        
        if (counterType == NC_Nought) {
            [self drawCounter:NC_Nought atPosition:i];
        }
        else if (counterType == NC_Cross) {
            [self drawCounter:NC_Cross atPosition:i];
        }
    }
    
    //If there is a winner, draw the winning line
    if ([gameModel getGameState] == NC_GameWon) {
        NSLog(@"Drawing winning line at position: %d", [gameModel getWinningLine]);
        [self drawWinningLine:[gameModel getWinningLine]];
    }
    CGContextRestoreGState(context);
}

- (void)drawCounter:(NC_CounterType)counterType atPosition:(int)position {

    int boardSize = [gameModel getBoardSize];
    int row = (int)position / boardSize;
    int column = position % boardSize;
    int viewHeight = self.bounds.size.height;
    int viewWidth = self.bounds.size.width;
    float heightIncrement = (viewHeight / boardSize) + (BOARD_LINE_WIDTH / 2);
    float widthIncrement = (viewWidth / boardSize) +  (BOARD_LINE_WIDTH / 2);
    
    //scale the image based on boardsize
    int scaleImageWidth = (int) widthIncrement - (BOARD_LINE_WIDTH * 2);
    int scaleImageHeight = (int) heightIncrement - (BOARD_LINE_WIDTH * 2);

    //if counter is nought then draw cross at position
    if (counterType == NC_Nought) {
        UIImage *noughtImage = [UIImage imageNamed:@"terry"];
        CGRect imageRect = CGRectMake(column * widthIncrement, row * heightIncrement, scaleImageWidth, scaleImageHeight);
        NSLog(@"Drawing a nought at: %d", position);
        [noughtImage drawInRect:imageRect];
        [noughtImage release];
    }
    
    //if counter is cross then draw cross at position
    if (counterType == NC_Cross) {
        UIImage *crossImage = [UIImage imageNamed:@"tpain"];
        CGRect imageRect = CGRectMake(column * widthIncrement, row * heightIncrement, scaleImageWidth, scaleImageHeight);
        NSLog(@"Drawing a cross at: %d", position);
        [crossImage drawInRect:imageRect];
        [crossImage release];
    }
}

- (void)drawWinningLine:(int)linePosition {
    
    int boardSize = [gameModel getBoardSize];
    int viewHeight = self.bounds.size.height;
    int viewWidth = self.bounds.size.width;
    float heightIncrement = (viewHeight / boardSize);
    float widthIncrement = (viewWidth / boardSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, WINNING_LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(context, WINNING_LINE_RED, WINNING_LINE_GREEN, WINNING_LINE_BLUE, WINNING_LINE_ALPHA);
    
    //This is for diagonal 2n+1 (top right bottom left)
    if ((boardSize * 2) + 1 == linePosition) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, BOARD_LINE_WIDTH , BOARD_LINE_WIDTH);
        CGContextAddLineToPoint(context, (boardSize * widthIncrement) - BOARD_LINE_WIDTH, viewHeight - BOARD_LINE_WIDTH);
        CGContextStrokePath(context);
    }
    
    //This is for diagonal positon 2n+2 (top left bottom right)
    if ((boardSize * 2) + 2 == linePosition) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, (boardSize * widthIncrement) - BOARD_LINE_WIDTH , BOARD_LINE_WIDTH);
        CGContextAddLineToPoint(context, BOARD_LINE_WIDTH, viewHeight - BOARD_LINE_WIDTH);
        CGContextStrokePath(context);
    }
    
    //line is horizontal
    if (linePosition <= boardSize) {
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, BOARD_LINE_WIDTH, (linePosition * heightIncrement) - (heightIncrement / 2));
        CGContextAddLineToPoint(context, viewWidth - BOARD_LINE_WIDTH, (linePosition * heightIncrement) - (heightIncrement / 2));
        CGContextStrokePath(context);
    }
    //line is vertical
    if (linePosition > boardSize && linePosition <= (boardSize * 2)) {

        int verticalPoint = linePosition - boardSize;
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, (verticalPoint * widthIncrement) - (widthIncrement / 2.0) , BOARD_LINE_WIDTH);
        CGContextAddLineToPoint(context, (verticalPoint * widthIncrement) - (widthIncrement / 2.0), viewHeight - BOARD_LINE_WIDTH);
        CGContextStrokePath(context);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) dealloc {
    [gameModel release];
    [super dealloc];
}

@end