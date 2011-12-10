//
//  NCGameViewController.m
//  Noughts and Crosses
//
//  Created by Ashley Connor on 05/11/2011.
//  Copyright (c) 2011 Merseysoft Corporation. All rights reserved.
//

#import "NCGameViewController.h"

@implementation NCGameViewController

@synthesize gameView, scoreView, gameModel, statusLabel, humanScoreLabel, iOSScoreLabel;

int humanScoreCounter, iOSScoreCounter;

bool humanFirst= YES;

#pragma mark - Buttons and stuff

- (IBAction)resetGame
{
    //reset model, update view and inform user
    [gameModel resetModel];
    [gameView setNeedsDisplay];
    NSLog(@"Reset button pushed.");
    
    //computer is first move
    //We can safely assume that the computer won't win or stalemate on first move
    if (humanFirst) {
        humanFirst = NO;    //swap for next game
        
        //Make computers first move
        int computerMove = [gameModel getOptimalMoveForPlayer:NC_Nought];
        [gameModel addCounterAtPosition:computerMove withCounter:NC_Nought];
        [gameView setNeedsDisplay];
        
        //inform player of their turn
        [statusLabel setText:@"Your turn. Please choose a square."];
    }
    //human is first move
    else
        humanFirst = YES;   //swap for next game
        [statusLabel setText:@"Your turn. Please choose a square."];
}

//Calculates board position from touch point
- (int)whichPositionIsTouchPoint: (CGPoint)touchPoint {
    int boardSize, row, column;
    float squareWidthSpacing, squareHeightSpacing, viewWidth, viewHeight;
    
    //needed to calcuate position of each square 
    boardSize = [gameModel getBoardSize];
    viewWidth = gameView.bounds.size.width;
    viewHeight = gameView.bounds.size.height;
    squareWidthSpacing = viewWidth / boardSize;
    squareHeightSpacing = viewHeight / boardSize;
    
    //find row
    for (int i = 1; i <= boardSize; i++) {
        if (touchPoint.x <= (i * squareWidthSpacing)) {
            NSLog(@"At row position: %d", i);
            row = i - 1;
            break;
        }
    }
    
    //find column
    for (int i = 1; i <= boardSize; i++) {
        if (touchPoint.y <= (i * squareHeightSpacing)) {
            NSLog(@"At column position: %d", i);
            column = i - 1;
            break;
        }
    }
    
    //return the position on the board calcuated from row and column position
    return [gameModel checkPositionParametersAtHorizontalPosition:row andAtVerticalPosition:column];
}

//Converts board position to CGPoint co-ordinate
- (CGPoint)whichTouchPointIsPosition: (int)position {
    int boardSize, row, column;
    float squareWidthSpacing, squareHeightSpacing, viewWidth, viewHeight;
    
    //needed to calcuate position of each square
    boardSize = [gameModel getBoardSize];
    viewWidth = gameView.bounds.size.width;
    viewHeight = gameView.bounds.size.height;
    squareWidthSpacing = viewWidth / boardSize;
    squareHeightSpacing = viewHeight / boardSize;
    
    //calculating column and row from position (courtesy of Terry)
    column = position % boardSize;
    row = (int) position / boardSize;
    
    //return a CGPoint of the position
    CGPoint positionPoint = CGPointMake(column * squareWidthSpacing, row * squareHeightSpacing);
    NSLog(@"Position X: %f, Position Y: %f", positionPoint.x, positionPoint.y);
    return CGPointMake(column * squareWidthSpacing, row * squareHeightSpacing);
}

#pragma mark - Touchview Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    GameAreaView *myView = [self gameView];
    
    if ([touch view] == myView) {
        
        //Get the co-ordinates of the touch point
        CGPoint touchPoint = [touch locationInView:myView];
        NC_GameState currentState = [gameModel getGameState];
        
        [statusLabel setText:@""];
        
        //game is still in progress
        //check to see if position in model is empty
        int position = [self whichPositionIsTouchPoint:touchPoint];
        NC_CounterType counterType = [gameModel getCounterAtPosition:position];
        
        if (counterType == NC_Empty) {
            
            if (currentState == NC_GameInProgress) {
                
                //get the position of touchpoint and place human counter
                
                [gameModel addCounterAtPosition:position withCounter:NC_Cross];
                
                currentState = [gameModel getGameState];    //post move game state
                
                //human move won the game
                if (currentState == NC_GameWon) {
                    [statusLabel setText:@"You won dawg!"];
                    humanScoreCounter++;
                    NSLog(@"Human player won, score: %d", humanScoreCounter);
                    NSString *humanScoreString = [NSString stringWithFormat:@"%d", humanScoreCounter];
                    [humanScoreLabel setText:humanScoreString];
                    
                }
                [gameView setNeedsDisplay];
            }
            
            if (currentState == NC_GameInProgress) {
                //query model for optimal move and place counter
                int position = [gameModel getOptimalMoveForPlayer:NC_Nought];
                [gameModel addCounterAtPosition:position withCounter:NC_Nought];
                
                currentState = [gameModel getGameState];    //post move game state
                
                //computers move won the game
                if (currentState == NC_GameWon) {
                    [statusLabel setText:@"Terry won this one"];
                    iOSScoreCounter++;
                    NSLog(@"iOS Player won, score: %d", iOSScoreCounter);
                    NSString *iOSScoreString = [NSString stringWithFormat:@"%d", iOSScoreCounter];
                    [iOSScoreLabel setText:iOSScoreString];
                    
                }
                [gameView setNeedsDisplay];
            }        
            if (currentState == NC_GameStalemate) {
                [statusLabel setText:@"Game is now stalemate"];
                NSLog(@"Game is a stalemate");
                [gameView setNeedsDisplay];
            }
        }
        else
            [statusLabel setText:@"Illegal move - try again"];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSString *statusMsg = [NSString stringWithString:@"Touch Cancelled"];
    [statusLabel setText:statusMsg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //create instance of model and create 3x3 board
    //hard coded due to AI only working with 3x3 board
    if ((gameModel = [[NCGameModel alloc] initWithBoardSize:BOARD_SIZE])!=nil) {
        [gameView setGameModel:gameModel];
    }
    
    //set initial label
    [statusLabel setText:@"New Game: T-Pain's move dawg"];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [gameModel release];
    [super dealloc];
}

@end