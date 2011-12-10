//
//  NCGameModel.m
//  NoughtsCrosses
//
//  Created by Terry Payne on 21/10/2011.
//  Copyright 2011 University of Liverpool. All rights reserved.
//

#import "NCGameModel.h"

// We create a static element that is not part of the class, to
// allow the class to be serialised in future
static NC_ErrorType lastError = NC_Error_None;

@implementation NCGameModel 

// =======================================================================================
#pragma mark - Internal (Housekeeping) Methods
// =======================================================================================

// Simple error reporting for debugging purposes
-(void) NCLogLastError{
    
    switch (lastError) {
        case NC_Error_None:
            NSLog(@"NC_ModelError: There *was* no error, don't be paranoid");
            break;
        case NC_Error_CounterTypeIsInvalid:
            NSLog(@"NC_ModelError: An invalid counter type was just used");
            break;
        case NC_Error_CounterLocationNotEmpty:
            NSLog(@"NC_ModelError: Setting a filled location with a counter is invalid");
            break;
        case NC_Error_PositionLocationInvalid:
            NSLog(@"NC_ModelError: Access was just made to an invalid location");
            break;
            
        default:
            NSLog(@"NC_ModelError: Wierd - you shouldn't see this!  Let Terry know...");
            break;
    }    
}

// Returns YES if the position is empty, NO for *any* other condition
// even if the position is invalid!!!
-(BOOL)isPosition:(int)pos occupiedByCounter:(NC_CounterType) counter {
    if ((pos < 0) || (pos >= [numberOfPositions intValue])) {
        lastError = NC_Error_PositionLocationInvalid;
        return NO;
    }
    return ((counter == [self getCounterAtPosition:pos])?YES:NO);
}


// Returns position as a scaler, or -1 for error
-(NSInteger) checkPositionParametersAtHorizontalPosition:(int)hPos
                                   andAtVerticalPosition:(int)vPos {    
    // Check position parameters
    if ((hPos < 0) || (hPos >= [boardSize intValue]) ||
        (vPos < 0) || (vPos >= [boardSize intValue])) {
        lastError = NC_Error_PositionLocationInvalid;
        return -1; // error
    }
    
    return hPos+([boardSize intValue]*vPos);
}

// Returns YES if the position is empty, NO for *any* other condition
// even if the position is invalid!!!
-(BOOL)isEmptyAtHorizontalPosition:(int)hPos
             andAtVerticalPosition:(int)vPos {
    return [self isEmptyAtPosition:[self checkPositionParametersAtHorizontalPosition:hPos
                                                               andAtVerticalPosition:vPos]];
}

-(BOOL)isEmptyAtPosition:(int)pos {
    return [self isPosition:pos occupiedByCounter:NC_Empty];
}

// =======================================================================================
#pragma mark Internal (Optimal Move) Methods
// =======================================================================================

// This method generates a score increment for cases where there is
// a cross counter... the explanation is a long story, but essentially
// lines of noughts (increment 1) should never exceed the size of the
// board; therefore the existence of a cross should be denoted by a
// value greater than that possible with a full line of noughts.  We
// can always modulo or divide the score to then extract the number of
// noughts or crosses in a score.  Take a look at stalemate to see how
// this works...
-(NSInteger) generateCrossIncrement {
    return [boardSize intValue]+1;
}

// Generate Score Matrix, and check if the previous move was
// a winning move.  Note that the score matrix will be incomplete
// (or corrupt) if the game was won, due to the method returning
// before fully processing all the board positions.


// Note that this returns the scoreMatrix line +1 for a winning position
// or NO_CORRESPONDING_WINNING_LINE (0) otherwise.
-(NSInteger) generateScoreMatrixForPlayer:(NC_CounterType)player {
    
	int row, col, diag;
	int totalScore;
    int bs = [boardSize intValue];
    int nought_incr = 1;
    int cross_incr = [self generateCrossIncrement];
    NC_CounterType counter;
    int targetScore = (bs * ((player == NC_Nought)?nought_incr:cross_incr));
    int winningLine = NO_CORRESPONDING_WINNING_LINE;
    
	int scoreMatrixIndex=0;
	
    // NSLog(@"Game Matrix is:%@\n", gamePositionArray);

	// Test horizontal lines
	for (row=0; row < bs; row++) {
		for (col = 0, totalScore=0; col < bs; col++) {
            counter = [self getCounterAtHorizontalPosition:col
                                     andAtVerticalPosition:row];
            if (NC_Nought == counter)
                totalScore += nought_incr;
            if (NC_Cross == counter)
                totalScore += cross_incr;
        }
        if (totalScore == targetScore) {
            winningLine = (winningLine?winningLine:(row+1));   // Return horizontal line ref
        }
		
        [scoreMatrix replaceObjectAtIndex:scoreMatrixIndex++ withObject:[NSNumber numberWithInt:totalScore]];
	}
	
	// Test vertical lines
	for (col=0; col < bs; col++) {
		for (row = 0, totalScore=0; row < bs; row++) {
            counter = [self getCounterAtHorizontalPosition:col
                                     andAtVerticalPosition:row];
            if (NC_Nought == counter)
                totalScore += nought_incr;
            if (NC_Cross == counter)
                totalScore += cross_incr;
        }
        if (totalScore == targetScore) {
            // Return vertical line ref (which are greater than horizontal lines)
            winningLine = (winningLine?winningLine:((bs + col)+1));
        }
        
        [scoreMatrix replaceObjectAtIndex:scoreMatrixIndex++ withObject:[NSNumber numberWithInt:totalScore]];
	}
    
    // Test topleft-bottomright diag lines - where row=col
	for (diag=0, totalScore=0; diag < bs; diag++) {
        counter = [self getCounterAtHorizontalPosition:diag
                                 andAtVerticalPosition:diag];
        if (NC_Nought == counter)
            totalScore += nought_incr;
        if (NC_Cross == counter)
            totalScore += cross_incr;
    }
    if (totalScore == targetScore) {
        // Return vertical line ref (which are greater than horizontal lines)
        winningLine = (winningLine?winningLine:((bs * 2)+1)); // First diagonal
    }
	
    [scoreMatrix replaceObjectAtIndex:scoreMatrixIndex++ withObject:[NSNumber numberWithInt:totalScore]];
    
    
    // Test bottomleft-topright diag lines - where row=((boardSize-1)-col)
	for (diag=0, totalScore=0; diag < bs; diag++) {
        counter = [self getCounterAtHorizontalPosition:((bs-1)-diag)
                                 andAtVerticalPosition:diag];
        if (NC_Nought == counter)
            totalScore += nought_incr;
        if (NC_Cross == counter)
            totalScore += cross_incr;
    }

    if (totalScore == targetScore) {
        // Return vertical line ref (which are greater than horizontal lines)
        winningLine = (winningLine?winningLine:(((bs * 2)+1)+1)); // Second diagonal
    }
    [scoreMatrix replaceObjectAtIndex:scoreMatrixIndex++ withObject:[NSNumber numberWithInt:totalScore]];
    
	return winningLine;
}


// This solution is based on the tic-tac-toe strategy (given below),
// generalised to work across bigger boards ()i.e. where m=n>3), although
// no guarantees of success are given beyond m=n=3).  It also
// assumes that k corresponds to a line of boardSize counters (i.e. k=m=n
// in an m,n.k game (http://en.wikipedia.org/wiki/M,n,k-game).

/* Strategy
 1) Win: If the player has two in a row, play the third to get three in a row.
 2) Block: If the opponent has two in a row, play the third to block them.
 3) Fork: Create an opportunity where you can win in two ways.
 4) Block opponent's fork:
 Option 1: Create two in a row to force the opponent into defending, as long
 as it doesn't result in them creating a fork or winning. For example,
 if "X" has a corner, "O" has the center, and "X" has the opposite corner
 as well, "O" must not play a corner in order to win. (Playing a corner in
 this scenario creates a fork for "X" to win.)
 Option 2: If there is a configuration where the opponent can fork, block that fork.
 5) Center: Play the center.
 6) Opposite corner: If the opponent is in the corner, play the opposite corner.
 7) Empty corner: Play in a corner square.
 8) Empty side: Play in a middle square on any of the 4 sides.
 */


// Note that this *only* works for the 3x3 case
// Returns an optional position if available, or NO_OPTIMAL_POSITION_FOUND if not
-(NSInteger) findForkForPlayer:(NC_CounterType)player {
    
    int i, j, pos;
    int bs = [boardSize intValue];
    int nought_incr = 1;
    int cross_incr = [self generateCrossIncrement];
    int targetScore = ((bs-2) * ((player == NC_Nought)?nought_incr:cross_incr));
    int scoreMatrixSize = (bs*2)+2; // i.e. rows, cols, and 2 diags
    
    
    
	for (i=0; i<scoreMatrixSize; i++) {
		if ([[scoreMatrix objectAtIndex:i] intValue] == targetScore) {

			// Need to find an intersecting line
			for (j=(1+i); j < scoreMatrixSize; j++) {
				if ([[scoreMatrix objectAtIndex:j] intValue] == targetScore) {
					// Check for non intersecting lines
					if ((i/bs == 0) && (j/bs == 0)) {
						continue;	// Both were horizontal
                    }
					if ((i/bs == 1) && (j/bs == 1)) {
						continue;	// Both were vertical
                    }
					
					// As i always preceeds j, then the position is
					// either intersecting orthogonal axes, or the center
					// (if the lines are diagonal)
					if ((i/bs == 0) && (j/bs == 1)) {
						// Intersecting orthogonal axes
						pos = (i*bs)+(j-bs);
                        
                        if ([self isEmptyAtPosition:pos]) {
                            return pos; // Return the position
                        }
					} else if (i > (bs*2)) {
						// Diagonals; position should be center
						pos = ((bs * 2) - 1)/2;
                        
                        if ([self isEmptyAtPosition:pos]) {
                            return pos; // Return the position
                        }
                	}
				}
            }
        }
    }
	return NO_OPTIMAL_POSITION_FOUND;
}
-(NSInteger) findTwoInLineForPlayer:(NC_CounterType)player {
    return [self findNInLine:2 ForPlayer:player];
}

-(NSInteger) findOneInLineForPlayer:(NC_CounterType)player {
    return [self findNInLine:1 ForPlayer:player];
}

-(NSInteger) findNInLine:(NSInteger)nCounters ForPlayer:(NC_CounterType)player {
    
    int i, j, pos;
    int bs = [boardSize intValue];
    int nought_incr = 1;
    int cross_incr = [self generateCrossIncrement];
    int targetScore = (nCounters * ((player == NC_Nought)?nought_incr:cross_incr));
    int scoreMatrixSize = (bs*2)+2; // i.e. rows, cols, and 2 diags

    
	for (i=0; i<scoreMatrixSize; i++)
		if ([[scoreMatrix objectAtIndex:i] intValue] == targetScore) {
			// Need to find the empty cell, and make the move
			if (i/bs == 0) {
				// Horizontal line
                
				for (j=0; j<bs; j++) {
					pos = (i*bs)+j;
                    
                    if ([self isEmptyAtPosition:pos]) {
                        return pos; // Return the position
                    }
  				}
                
			} else if (i/bs == 1) {
				// Vertical line
                
				for (j=0; j<bs; j++) {
					pos = (i-bs)+(j*bs);
                    
                    if ([self isEmptyAtPosition:pos]) {
                        return pos; // Return the position
                    }                    
				}
			} else if ((i+1) == scoreMatrixSize) {
				// 2nd Diagonal line
				// [NOTE This is in a different order to the order in which
				// diagonal lines are processed in generateScoreMatrix
				for (j=0; j<bs; j++) {
					pos = (1+j) * (bs -1);
                    
                    if ([self isEmptyAtPosition:pos]) {
                        return pos; // Return the position
                    }
                }
			} else {
				// 1st Diagonal line
				for (j=0; j<bs; j++) {
					pos = j * (bs +1);
                    if ([self isEmptyAtPosition:pos]) {
                        return pos; // Return the position
                    }     
 				}
			}
			break;
		}
    
	return NO_OPTIMAL_POSITION_FOUND;
}

// This method only works when there is an odd-sized board
-(NSInteger) playCenter {
    int bs = [boardSize intValue];

	if (bs%2) {
		int center = (bs-1)/2;
		int pos = center*bs + center;
        
        if ([self isEmptyAtPosition:pos]) {
            return pos; // Return the position
        }        
	}
	return NO_OPTIMAL_POSITION_FOUND;
}

-(NSInteger) playOppositeCorner:(NC_CounterType)player {
	NC_CounterType opponentPlayer = (player == NC_Nought?NC_Cross:NC_Nought);
    int bs = [boardSize intValue];
    
	// If Top-Left set, then play Bottom-Right
    if (([self isPosition:TOPLEFT_CORNERPOS(bs) occupiedByCounter:opponentPlayer]) &&
        ([self isEmptyAtPosition:BOTTOMRIGHT_CORNERPOS(bs)]))
        return BOTTOMRIGHT_CORNERPOS(bs);
    
	// If Top-Left set, then play Bottom-Right
    if (([self isPosition:BOTTOMRIGHT_CORNERPOS(bs) occupiedByCounter:opponentPlayer]) &&
        ([self isEmptyAtPosition:TOPLEFT_CORNERPOS(bs)]))
        return TOPLEFT_CORNERPOS(bs);
    
	// If Bottom-Left set, then play Top-Right
    if (([self isPosition:BOTTOMLEFT_CORNERPOS(bs) occupiedByCounter:opponentPlayer]) &&
        ([self isEmptyAtPosition:TOPRIGHT_CORNERPOS(bs)]))
        return TOPRIGHT_CORNERPOS(bs);
    
	// If Top-Right set, then play Bottom-Left
    if (([self isPosition:TOPRIGHT_CORNERPOS(bs) occupiedByCounter:opponentPlayer]) &&
        ([self isEmptyAtPosition:BOTTOMLEFT_CORNERPOS(bs)]))
        return BOTTOMLEFT_CORNERPOS(bs);
    
    // Couldn't find any viable position
    return NO_OPTIMAL_POSITION_FOUND;
}
    
-(NSInteger) playEmptyCorner {
    
	int randomStartingPoint = arc4random() % NUMBEROFCORNERS;
    int bs = [boardSize intValue];
    
	for (int i=0; i<NUMBEROFCORNERS; i++) {
		switch ((i+randomStartingPoint)%NUMBEROFCORNERS) {
			case (0):
				if ([self isEmptyAtPosition:TOPLEFT_CORNERPOS(bs)])
                    return TOPLEFT_CORNERPOS(bs);
				break;
			case (1):
                if ([self isEmptyAtPosition:TOPRIGHT_CORNERPOS(bs)])
                    return TOPRIGHT_CORNERPOS(bs);
				break;
			case (2):
                if ([self isEmptyAtPosition:BOTTOMLEFT_CORNERPOS(bs)])
                    return BOTTOMLEFT_CORNERPOS(bs);
				break;
			case (3):
                if ([self isEmptyAtPosition:BOTTOMRIGHT_CORNERPOS(bs)])
                    return BOTTOMRIGHT_CORNERPOS(bs);
				break;
		}
	}
    
    // Couldn't find any viable position
    return NO_OPTIMAL_POSITION_FOUND;
}

// This method only works when there is an odd-sized board
-(NSInteger) playMiddleSide {

    int bs = [boardSize intValue];
	if (bs%2) {
		
		int randomStartingPoint = arc4random() % NUMBEROFSIDES;
		
		for (int i=0; i<NUMBEROFSIDES; i++) {
			switch ((i+randomStartingPoint)%NUMBEROFSIDES) {
				case (0):
                    if ([self isEmptyAtPosition:MIDLEFT_POS(bs)])
                        return MIDLEFT_POS(bs);
                    break;
				case (1):
                    if ([self isEmptyAtPosition:MIDTOP_POS(bs)])
                        return MIDTOP_POS(bs);

					break;
				case (2):
                    if ([self isEmptyAtPosition:MIDRIGHT_POS(bs)])
                        return MIDRIGHT_POS(bs);
					break;
				case (3):
                    if ([self isEmptyAtPosition:MIDBOTTOM_POS(bs)])
                        return MIDLEFT_POS(bs);
					break;
			}
		}
		
	}
    // Couldn't find any viable position
    return NO_OPTIMAL_POSITION_FOUND;
}

// =======================================================================================
#pragma mark - Optimal Move Method
// =======================================================================================

-(NSInteger)getOptimalMoveForPlayer:(NC_CounterType)player {
	NC_CounterType opponent = (player == NC_Nought?NC_Cross:NC_Nought);    
    int pos;
    
    // Rule 1 - Win: If the player has two in a row, play the third to win
    if ((pos = [self findTwoInLineForPlayer:player]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;

    // Rule 2 - Block: If the opponent has two in a row, play the third to block them.
    if ((pos = [self findTwoInLineForPlayer:opponent]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;

    // Rule 3a - Fork: Create an opportunity where you can win in two ways.
    if ((pos = [self findForkForPlayer:player]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;
    
    // Rule 3b - Force Defence: Get two in a row, and force the opponent to defend without creating a fork.
    if ((pos = [self findOneInLineForPlayer:player]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;

    // Rule 4 - Rule 4 - Block: Block opponent's fork.
    if ((pos = [self findForkForPlayer:opponent]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;
    
    // Rule 5 - Center: Play the center (works only for odd-valued boards).
    if ((pos = [self playCenter]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;
    
    // Rule 6 - Opposite corner: If the opponent is in the corner, play the opposite corner.
    if ((pos = [self playOppositeCorner:player]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;

    
    // Rule 7 - Empty corner: Play in a corner square.
    if ((pos = [self playEmptyCorner]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;
    
    // Rule 8 - Empty side: Play in a middle square on any of the 4 sides.
    if ((pos = [self playMiddleSide]) != NO_OPTIMAL_POSITION_FOUND)
        return pos;

    // Couldn't find any viable position - although this should never be reached
    NSLog(@"No optimal move could be found - THIS SHOULD NOT HAPPEN");
    return NO_OPTIMAL_POSITION_FOUND;
}

// =======================================================================================
#pragma mark - Model Query Methods
// =======================================================================================

// Getters - these simply return ints (NSIntegers), so that the caller doesn't
// have to worry about handling NSNumber objects
-(NSInteger) getBoardSize {
    return [boardSize intValue];
}

-(NSInteger) getNumberOfPositions {
    return [numberOfPositions intValue];
}

// The value that is stored in gameState corresponds to the int value of
// the enumerated type NC_GameState
-(NC_GameState)getGameState {
    return (NC_GameState) [gameState intValue];
}

// This returns line corresponding to a winning move, or 0 if the game
// hasn't been won.
// The number of possible values returned = (BoardSize*2) + 2
// Values 1..(BoardSize) correspond to winning columns from left to right
// Values (BoardSize+1)..(2*BoardSize) correspond to rows from top to bottom
// Value (2*BoardSize)+1 corresponds to the diagonal from top left to bottom right
// Value (2*BoardSize)+2 corresponds to the diagonal from top right to bottom left

-(NSInteger)getWinningLine {
    if (NC_GameWon == [gameState intValue]) {
        // If the game was won, then we should know the winning line
        return [winningLinePosition intValue];
    }
    
    // Game wasn't won
    return NO_CORRESPONDING_WINNING_LINE;
}

// Returns the type of counter from the model, or NC_Empty if empty
// Returns NC_Error if unsuccessful, if
//    1) either horizontal or vertical positions are invalid
-(NC_CounterType)getCounterAtPosition:(int)pos {
    
    if ((pos < 0) || (pos >= [numberOfPositions intValue]))
        return NC_Error;
    
    return [[gamePositionArray objectAtIndex:pos] intValue];
}

// Returns the type of counter from the model, or NC_Empty if empty
// Returns NC_Error if unsuccessful, if
//    1) either horizontal or vertical positions are invalid

-(NC_CounterType)getCounterAtHorizontalPosition:(int)hPos
                          andAtVerticalPosition:(int)vPos {
    
    return [self getCounterAtPosition:[self checkPositionParametersAtHorizontalPosition:hPos
                                                                  andAtVerticalPosition:vPos]];
}



// Inserts a counter into the model
// Returns YES if successful, or NO if
//    1) the counter is an empty counter
//    2) the counter location is already full
//    3) either horizontal or vertical positions are invalid
-(BOOL)addCounterAtPosition:(int)pos withCounter:(NC_CounterType)counterType {

    if (pos < 0)
        return NO;
    
    if ([emptyCounterObject isEqualToValue:[gamePositionArray objectAtIndex:pos]]) {
        switch (counterType) {
            case NC_Nought:
                [gamePositionArray replaceObjectAtIndex:pos withObject:noughtCounterObject];
                break;
            case NC_Cross:
                [gamePositionArray replaceObjectAtIndex:pos withObject:crossCounterObject];
                break;
            default:
                lastError = NC_Error_CounterTypeIsInvalid;
                return NO;
                break;  // technically redundant, but kept for completeness
        }
    } else {
        lastError = NC_Error_CounterLocationNotEmpty;
        return NO;
    }

    // If we are here, the the counter was successfully inserted above.
    // Update the score matrix, which is used to determine the final state
    // of the game (i.e. won or stalemate), and can be used by the AI engine.
    NSInteger winningLine = [self generateScoreMatrixForPlayer:counterType];
    
    if (winningLine) {
        // Update the game state
        [gameState release];
        gameState = [[NSNumber alloc] initWithInt:NC_GameWon];
        
        // And assert the winning line
        [winningLinePosition release];
        winningLinePosition = [[NSNumber alloc] initWithInt:winningLine];
    } else {
        // see if we have any possible winable positions
        // examine *every* row or column to see if it is winnable or blocked;
        // if every one is blocked (even with only two counters, one of each
        // type), then there can be no winner... and hence we have stalemate.
        
        // The scoreMatrix has been designed to agregate scores for each counter
        // along one of the dimensions (row/col/diag), such that nought counters
        // have a score of 1 per position (nought_incr), and cross counters
        // have a score of boardsize +1 (cross_incr).
        
        // Start by examining the board from Nought's perspective - Any score
        // that is greater than cross_incr, is blocked.  So check each dimension;
        // if every one is blocked then Nought can't win.
        
        // Then check from Cross's perspective.  If a score modulo cross_inr
        // is non-zero then there must be a nought counter, and hence is blocked.
        
        // If both conditions hold... then there is stalemate.
                
        int cross_incr = [self generateCrossIncrement];
        BOOL stalemateFound = YES;
        
        for (NSNumber *element in scoreMatrix) {
            // Start with Nought's perspective
            // Fail if a score >= cross_incr is found
            if([element intValue] < cross_incr) {
                stalemateFound = NO;
                break;
            }
            // Test from Cross's perspective
            // Fail if a score % cross_incr is zero
            if(([element intValue] % cross_incr)==0) {
                stalemateFound = NO;
                break;
            }
        }
        if (stalemateFound == YES) {
            [gameState release];
            gameState = [[NSNumber alloc] initWithInt:NC_GameStalemate];
        }
    }
    
    return YES;
}

// Inserts a counter into the model
// Returns YES if successful, or NO if
//    1) the counter is an empty counter
//    2) the counter location is already full
//    3) either horizontal or vertical positions are invalid
-(BOOL)addCounterAtHorizontalPosition:(int)hPos
                andAtVerticalPosition:(int)vPos
                          withCounter:(NC_CounterType)counterType {
    
    return [self addCounterAtPosition:[self checkPositionParametersAtHorizontalPosition:hPos
                                                                  andAtVerticalPosition:vPos]
                          withCounter:counterType];
}


// =======================================================================================
#pragma mark - Model lifecycle, Maintenance and Memory Management
// =======================================================================================

// Reset the model to contain only empty values.
-(void) resetModel {
    
    // Reset all of the entries in the game position array
    for (int pos=[numberOfPositions intValue]; pos >= 0; pos--)
        [gamePositionArray replaceObjectAtIndex:pos withObject:emptyCounterObject];
    
    // Reset the scoreMatrix, filling it with empty values
    // Note that the scoreMatrix has an entry for each
    // row, col, and the two diagonals
    int scoreMatrixSize = ([boardSize intValue]*2)+2;
    NSNumber *zero = [NSNumber numberWithInt:0];
    for (int j=0; j < scoreMatrixSize; j++)
        [scoreMatrix replaceObjectAtIndex:j withObject:zero];
    
    // Reset the Game Status
    [gameState release];
    gameState = [[NSNumber alloc] initWithInt:NC_GameInProgress];
    
    // Reset the Winning Line Position
    [winningLinePosition release];
    winningLinePosition = [[NSNumber alloc] initWithInt:NO_CORRESPONDING_WINNING_LINE];
    
}

-(NCGameModel *)initWithBoardSize:(int)newBoardSize{
    
    // If the board is less than size 3, then we just fail
    // and return nil - too many things could go wrong, especially
    // with the AI mechanism.
    
    // NOTE THIS HASN'T BEEN TESTED !!!
    
    if (newBoardSize<3) {
        NSLog(@"NCGameModel initWithBoardSize called with an illegal value!!!  Returning nil...");
        [self autorelease];
        return nil;
    }
    
    self = [super init];
    if (self) {
        int numPos = newBoardSize * newBoardSize;
        boardSize = [[NSNumber alloc] initWithInt:newBoardSize];
        numberOfPositions = [[NSNumber alloc] initWithInt:numPos];
        gameState = [[NSNumber alloc] initWithInt:NC_GameInProgress];
        winningLinePosition = [[NSNumber alloc] initWithInt:NO_CORRESPONDING_WINNING_LINE]; // No winning

        // Create the counter objects
        emptyCounterObject = [[NSNumber alloc] initWithInt:NC_Empty];
        noughtCounterObject = [[NSNumber alloc] initWithInt:NC_Nought];
        crossCounterObject = [[NSNumber alloc] initWithInt:NC_Cross];
        
        // Create position array and fill with empty tokens
        gamePositionArray = [[NSMutableArray alloc] initWithCapacity:numPos];
        for (int i=[numberOfPositions intValue]; i >= 0; i--)
            [gamePositionArray addObject:emptyCounterObject];

        // Create scoreMatrix and fill it with empty values
        // Note that the scoreMatrix has an entry for each
        // row, col, and the two diagonals
        int scoreMatrixSize = (newBoardSize*2)+2;
        NSNumber *zero = [NSNumber numberWithInt:0];
        scoreMatrix = [[NSMutableArray alloc] initWithCapacity:scoreMatrixSize];
        for (int j=0; j < scoreMatrixSize; j++)
            [scoreMatrix addObject:zero];

    }
    return self;
}

- (void)dealloc
{
    [emptyCounterObject release];
    [noughtCounterObject release];
    [crossCounterObject release];
    [boardSize release];
    [gameState release];
    [winningLinePosition release];
    [numberOfPositions release];
    [gamePositionArray release];
    [scoreMatrix release];

    [super dealloc];
}

@end
