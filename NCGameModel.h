//
//  NCGameModel.h
//  NoughtsCrosses
//
//  Created by Terry Payne on 21/10/2011.
//  Copyright 2011 University of Liverpool. All rights reserved.
//

#import <Foundation/Foundation.h>

// =======================================================================================
// Internal (Housekeeping) Macros and typedefs - DO NOT USE
// =======================================================================================

#define TOPLEFT_CORNERPOS(bs) (0)
#define TOPRIGHT_CORNERPOS(bs) ((bs)-1)
#define BOTTOMLEFT_CORNERPOS(bs) (((bs)-1)*(bs))
#define BOTTOMRIGHT_CORNERPOS(bs) (((bs) * (bs))-1)
#define NUMBEROFCORNERS 4

#define MIDLEFT_POS(bs) ((((bs)-1)/2)*(bs))
#define MIDTOP_POS(bs) (((bs)-1)/2)
#define MIDRIGHT_POS(bs) (((((bs)-1)/2)*(bs))+((bs)-1))
#define MIDBOTTOM_POS(bs) ((((bs)-1) * (bs)) + (((bs)-1)/2))
#define NUMBEROFSIDES 4

typedef enum NC_ErrorType {
    NC_Error_None = 0,
    NC_Error_CounterTypeIsInvalid,
    NC_Error_CounterLocationNotEmpty,
    NC_Error_PositionLocationInvalid,
} NC_ErrorType;

// =======================================================================================
// Usefull Macros and typedefs - see below
// =======================================================================================

#define NO_CORRESPONDING_WINNING_LINE 0
#define NO_OPTIMAL_POSITION_FOUND -1

typedef enum NC_CounterType {
    NC_Error = -1,
    NC_Empty = 0,
    NC_Nought = 1,
    NC_Cross = 2,
} NC_CounterType;

typedef enum NC_GameState {
    NC_GameInProgress = 0,
    NC_GameWon = 1,
    NC_GameStalemate = 2,
} NC_GameState;


@interface NCGameModel : NSObject {
    @private
    NSNumber *boardSize;
    NSNumber *numberOfPositions;
    NSNumber *gameState;            // Based on the integer value of NC_GameStatus
    NSNumber *winningLinePosition;  // Stores the position of the winning line, or -1 if not won.
    
    // Create some objects that can populate the array.
    // These will be created in initWithBoardSize:, and retained
    // whenever added to the gameBoard.  Thus, *in theory*, one
    // can check the retain count to see the number of objects
    // (plus this) are in the board!
    NSNumber *emptyCounterObject;
    NSNumber *noughtCounterObject;
    NSNumber *crossCounterObject;
    
    NSMutableArray *gamePositionArray;
    NSMutableArray *scoreMatrix;
}

// =======================================================================================
// Internal (Housekeeping) Methods - DO NOT CALL
// =======================================================================================
-(void) NCLogLastError;
-(BOOL)isPosition:(int)pos occupiedByCounter:(NC_CounterType) counter;
-(NSInteger) checkPositionParametersAtHorizontalPosition:(int)hPos
                                   andAtVerticalPosition:(int)vPos;
-(BOOL)isEmptyAtPosition:(int)pos;
-(BOOL)isEmptyAtHorizontalPosition:(int)hPos
             andAtVerticalPosition:(int)vPos;

// =======================================================================================
// Internal (Optimal Move) Methods - DO NOT CALL
// =======================================================================================
-(NSInteger) generateCrossIncrement;
-(NSInteger) generateScoreMatrixForPlayer:(NC_CounterType)player;
-(NSInteger) findForkForPlayer:(NC_CounterType)player;
-(NSInteger) findTwoInLineForPlayer:(NC_CounterType)player;
-(NSInteger) findOneInLineForPlayer:(NC_CounterType)player;
-(NSInteger) findNInLine:(NSInteger)nCounters ForPlayer:(NC_CounterType)player;
-(NSInteger) playCenter;
-(NSInteger) playOppositeCorner:(NC_CounterType)player;
-(NSInteger) playEmptyCorner;
-(NSInteger) playMiddleSide;


// =======================================================================================
//
// The NCGameModel was developed as a Model class to support the game Noughts and Crosses
// It's design has been to be as general as possible, allowing for game boards of any
// size (greater than 3).  In addition, the AI heuristic rules for 3x3 noughts and crosses
// have been included, allowing for "hints" on the optimal move for a given player.
//
// A number of methods (above) are available externally, but THEY SHOULD NOT BE CALLED as
// they are essentially private.  In addition, a number of Enumerated Types and macros
// have been included to assist in using this model.
//
// The macro value NO_CORRESPONDING_WINNING_LINE may be returned by the method 
// -(NSInteger)getWinningLine if no winning line has yet been detected; this is typically
// only the case if the game state returned by -(NC_GameState)getGameState is not NC_GameWon
//
// Similarly, it is possible that NO_OPTIMAL_POSITION_FOUND may be returned by the method
// -(NSInteger)getOptimalMoveForPlayer:(NC_CounterType)player, however, this would suggest
// that there is an error in the code or memory corruption as this should not happen!!!
//
// The Enumerated types NC_CounterType represent counters or states in the model.  They have
// the values:
//    NC_Error - this is reserved for error conditions
//    NC_Empty - the counter is "empty"; i.e. there is no counter 
//    NC_Nought - the counter is a "nought"
//    NC_Cross - the counter is a "cross"
//
// The method -(NC_GameState)getGameState will return a enumerated value of the
// type NC_GameState, which represents the following states:
//    NC_GameInProgress - the game is in progress
//    NC_GameWon - the game has been won by one of the players
//    NC_GameStalemate - stalemate; the game cannot be won
//
// ===========================
// Setting up the Model
//
// A model should always be initialised using the following method:

-(NCGameModel *)initWithBoardSize:(int)newBoardSize;

// This initialises the new model, and specifies the size of the board.  In most cases
// (for traditional 3x3 noughts and crosses), this would be implemented as:
//
//     if ((gameModel = [[NCGameModel alloc] initWithBoardSize:3])!=nil) {
//         ...
//     }
//
// This will also ensure that all the defualt values and internal state have been
// defined. 
// To explicitly reset the model, for example when starting a new game, use:

-(void) resetModel;

// This assumes that the model has been initialised, but could (redundantly) be called
// after the model has been initialised before a new game, as well as after a game has
// commenced or is finished.
//
// ===========================
// General Model Queries
//
// The following  methods can be used make general queries about the model.

-(NSInteger) getBoardSize;

// This returns the board size - i.e. the number of squares along one side of the board;
// it corresponds to the value passed to the method initWithBoardSize:.
// In a traditional 3x3 noughts and crosses game, this would be 3.

-(NSInteger) getNumberOfPositions;

// This returns the total number of positions on the board - typically n*n where n
// corresponds to the board size.
// In a traditional 3x3 noughts and crosses game, this would be 9.

-(NC_GameState)getGameState;

// This queries the model, to determine if the the game is in progress, has been won, or
// is stalemate.  See the details on NC_GameState (above).
//

-(NSInteger)getWinningLine;

// This is really only meaningful if the game state is NC_GameWon - i.e. there is a winning
// line.  An integer will be reterned corresponding to the row, column or diagonal in which
// a winning line occurs.  There are 2n+2 values corresponding to a winning position, where
// n is the size of the board.  The values 1..n  correspond to the rows, n+1..2n to the
// columns, 2n+1 to the topleft-bottomright diagonal, and 2n+2 for the toprightbottomleft
// diagonal.
// In a traditional 3x3 noughts and crosses game, this would result in the following pattern
//
//      4   5   6   
//      v   v   v  
//        |   |    <1
//     ---+---+---
//        |   |    <2
//     ---+---+---
//        |   |    <3
//     /           \
//    8             7
//
// The value NO_CORRESPONDING_WINNING_LINE (which is equal to 0) refers to no line being
// found
//
// ===========================
// Position-based Model Queries
//
// Positions in the model start from 0 and go up to n*n, corresponding to the number
// of positions (which can be obtained from calling -getNumberOfPositions
// The positions start from the top left of the board and run across each row, moving
// down the columns accordingly.  In a traditional 3x3 noughts and crosses game, this
// would result in the following positions
//
//      0 | 1 | 2 
//     ---+---+---
//      3 | 4 | 5 
//     ---+---+---
//      6 | 7 | 8
//
// The board position can be calculated simply by knowing the row and column position,
// and the board size.  The internal method:
//     - checkPositionParametersAtHorizontalPosition:andAtVerticalPosition:
// checks that the col and row positions are valid, and then calculates the actual
// board position:
//
//    ...
//    return hPos+([boardSize intValue]*vPos);
//    ...
//
// i.e. the position is the row value * the board size, + column position.
//
// Corespondingly, the row and column can be generated from the absolute position using
// integer division and modulo maths as follows:
// 
//    column = pos % board size
//    row = (int) pos / board size
//
// For example, position 5 % 3 = column 2, wereas 5 / 3 = row 1
//
// Methods have been provided to insert counters (i.e. nought counters or cross counters)
// within an empty position, and to get the counter type at positions on the board; either
// using absolute positions or using row and column positions.
//
// To insert a counter at a position, use either of the following two methods:

-(BOOL)addCounterAtPosition:(int)pos withCounter:(NC_CounterType)counterType;
-(BOOL)addCounterAtHorizontalPosition:(int)hPos
                andAtVerticalPosition:(int)vPos
                          withCounter:(NC_CounterType)counterType;

// where counterType should be either NC_Nought or NC_Cross.  For example:
//
//    [gameModel addCounterAtHorizontalPosition:1
//                        andAtVerticalPosition:1
//                                  withCounter:NC_Cross];
//
// would insert a cross in absolute position 4 (i.e. the center) position of a 3x3 board,
// represented by an instance of the model called "gameModel".
// In contrast, 
//
// 
//    [gameModel addCounterAtPosition:6 withCounter:NC_Nought];
//
// would add a nought in the bottom left corner of the same board.

// ////////////////////////////////////////////////////////////////////// //
// HINT:    The methods above would typically be used by the              //
//          viewController when adding counters due to a move being made  //
// ////////////////////////////////////////////////////////////////////// //

//
// The existence of counters can be determined by using the following two methods;
// which may not only return NC_Nought or NC_Cross, but also NC_Empty if the position
// is empty.

-(NC_CounterType)getCounterAtPosition:(int)pos;
-(NC_CounterType)getCounterAtHorizontalPosition:(int)hPos
                          andAtVerticalPosition:(int)vPos;

// An example of this could be when developing a view class that displays the
// counters.  The code below checks the counter at a given position (i) and then
// calls the method -drawCounterAtPosition:isNought: whenever a nought or cross
// is detected (the counter type is passed as a bool in this case).
//
//      countertype = [gameModel getCounterAtPosition:i];
//      switch (countertype) {
//          case NC_Nought:
//              [self drawCounterAtPosition:i isNought:YES];
//              break;
//          case NC_Cross:
//              [self drawCounterAtPosition:i isNought:NO];
//              break;
//      default:
//              break;
//      }


// ////////////////////////////////////////////////////////////////////// //
// HINT:    The methods above would typically be used by the              //
//          view class when painting the view                             //
// ////////////////////////////////////////////////////////////////////// //


// ===========================
// Optimal Move Method
// 
// Finally, the method -getOptimalMoveForPlayer: uses the AI heuristics built
// into the model to determine the optimal move.  This then returns a position
// which can then be used by the caller, either to make recommendations, or to
// determine a computer players next move.  The optimal move may be different
// for nought vs cross; therefore to request the correct move, pass in the
// counter type as the method's argument.

-(NSInteger) getOptimalMoveForPlayer:(NC_CounterType)player;


@end
