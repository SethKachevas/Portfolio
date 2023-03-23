import javax.swing.*;
import java.awt.GridLayout;
import java.awt.event.*;
import java.util.*;

// This class will wrap up all of the game squares and keep track of the current player turn
public class GameBoard
{
	// define the number of rows and columns as constants
	static public final int NUM_ROWS = 11;
	static public final int NUM_COLS = 11;
	
	// this 2-dimensional array will hold the 8x8 grid of GameSquare objects
	private GameSquare[][] squares;
	
	// The GameBoard constructor will build the visible 8x8 grid of game squares
	public GameBoard(JPanel boardPanel, ActionListener listener)
	{
		// create a grid layout with the 9x9 grid
		GridLayout layout = new GridLayout(NUM_COLS,NUM_ROWS);
		
		// we don't want any gap between the buttons
		layout.setHgap(0);
		layout.setVgap(0);
		
		boardPanel.setLayout(layout);

		// create new 2D array of GameSquare objects
		squares = new GameSquare[NUM_COLS][NUM_ROWS];
		
		// now iterate over every element in the array, creating a new GameSquare object
		for (int col = 0; col < NUM_COLS; col++)
		{
			for (int row = 0; row < NUM_ROWS; row++)
			{
				// create new GameSquare object for this column and row.  Pass in
				// the panel and action listener so the button can be linked up!
				squares[col][row] = new GameSquare(col,row,boardPanel,listener);
			}
		}

		// Now mark some of the squares as special (Jail or Camp)
		squares[5][5].setType(GameSquare.TYPE_JAIL);

		squares[0][3].setType(GameSquare.TYPE_CAMP);
		squares[0][4].setType(GameSquare.TYPE_CAMP);
		squares[0][5].setType(GameSquare.TYPE_CAMP);
		squares[0][6].setType(GameSquare.TYPE_CAMP);
		squares[0][7].setType(GameSquare.TYPE_CAMP);
		squares[1][5].setType(GameSquare.TYPE_CAMP);

		squares[10][3].setType(GameSquare.TYPE_CAMP);
		squares[10][4].setType(GameSquare.TYPE_CAMP);
		squares[10][5].setType(GameSquare.TYPE_CAMP);
		squares[10][6].setType(GameSquare.TYPE_CAMP);
		squares[10][7].setType(GameSquare.TYPE_CAMP);
		squares[9][5].setType(GameSquare.TYPE_CAMP);

		squares[3][0].setType(GameSquare.TYPE_CAMP);
		squares[4][0].setType(GameSquare.TYPE_CAMP);
		squares[5][0].setType(GameSquare.TYPE_CAMP);
		squares[6][0].setType(GameSquare.TYPE_CAMP);
		squares[7][0].setType(GameSquare.TYPE_CAMP);
		squares[5][1].setType(GameSquare.TYPE_CAMP);

		squares[3][10].setType(GameSquare.TYPE_CAMP);
		squares[4][10].setType(GameSquare.TYPE_CAMP);
		squares[5][10].setType(GameSquare.TYPE_CAMP);
		squares[6][10].setType(GameSquare.TYPE_CAMP);
		squares[7][10].setType(GameSquare.TYPE_CAMP);
		squares[5][9].setType(GameSquare.TYPE_CAMP);
	}

	// reset will start the game over
	public void reset()
	{
		// clear every square on the game board
		for (int col = 0; col < NUM_COLS; col++)
		{
			for (int row = 0; row < NUM_ROWS; row++)
			{
				// remove any piece and yellow selection border
				squares[col][row].clearSquare();
				squares[col][row].deselect();
			}
		}
	}
	
	// add the game piece to the GameSquare at the specified column and row
	public void setPiece(int col, int row, AbstractGamePiece piece)
	{
		// if we are given a good column and row (0-8)
		if ((col >= 0) && (col < NUM_COLS) &&
		    (row >= 0) && (row < NUM_ROWS))
		{
			squares[col][row].setPiece(piece);
		}
	}
	
	// find which game square, if any, matches the click event object (button)
	public GameSquare getClickedSquare(Object source)
	{
		// check every game square in the array
		for (int col = 0; col < NUM_COLS; col++)
		{
			for (int row = 0; row < NUM_ROWS; row++)
			{
				GameSquare square = squares[col][row];
				
				// if this square was the one that was clicked
				if (square.isClicked(source))
				{	
					return square;	// return the clicked square!
				}
			}
		}
		
		return null;	// could not find clicked square
	}	
	
	// return the game piece at the indicated column and row
	public AbstractGamePiece getPiece(int col, int row)
	{
		// if we are given a good column and row (0-8)
		if ((col >= 0) && (col < NUM_COLS) &&
		    (row >= 0) && (row < NUM_ROWS))
		{
			// return the piece that is on the valid square
			return squares[col][row].getPiece();
		}
		
		return null;	// invalid column or row provided
	}

	// remove the indicated piece from the game board
	public void removePiece(AbstractGamePiece piece)
	{
		// get the column and row of the game piece
		int col = piece.getCol();
		int row = piece.getRow();
		
		// get the game square this piece is sitting on
		GameSquare square = squares[col][row];
		
		// clear the square!
		square.clearSquare();
	}
	
	// build a list of GameSquare objects from the starting square to the targetSquare
	public List<GameSquare> buildPath(GameSquare startingSquare, GameSquare targetSquare)
	{
		// create new ArrayList that we will return.  Initially the path is empty
		List<GameSquare> path = new ArrayList<GameSquare>();
		
		// get starting and ending column and row
		int currentCol = startingSquare.getCol();
		int currentRow = startingSquare.getRow();
		
		int endCol = targetSquare.getCol();
		int endRow = targetSquare.getRow();
		
        // if destination is the same as the origin
        if ((currentCol == endCol) && (currentRow == endRow))
            return path;       // return the empty path...not valid

        // if both destination row and column are different, cannot make straight line to target
        if ((currentCol != endCol) && (currentRow != endRow))
            return path;       // return the empty path...not valid

        // if we are moving down
        if ((currentCol == endCol) && (currentRow < endRow))
        {
            // while we haven't passed by our target square yet
            while (currentRow < endRow)
            {
            	currentRow++; // move one square down
                path.add(squares[currentCol][currentRow]);
            }
        }
        // if we are moving up
        else if ((currentCol == endCol) && (currentRow > endRow))
        {
            // while we haven't passed by our target square yet
            while (currentRow > endRow)
            {
            	currentRow--; // move one square up
                path.add(squares[currentCol][currentRow]);
            }
        }
        // if we are moving left
        else if ((currentCol > endCol) && (currentRow == endRow))
        {
            // while we haven't passed by our target square yet
            while (currentCol > endCol)
            {
            	currentCol--; // move one square left
                path.add(squares[currentCol][currentRow]);
            }
        }
        // if we are moving right
        else if ((currentCol < endCol) && (currentRow == endRow))
        {
            // while we haven't passed by our target square yet
            while (currentCol < endCol)
            {
            	currentCol++; // move one square right
                path.add(squares[currentCol][currentRow]);
            }
        }

        // now return whatever we found to the calling function
        return path;
	}
}