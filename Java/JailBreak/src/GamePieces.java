
import javax.swing.*;

import java.awt.*;

public class GamePieces
{
	// The main() method simply creates a new GamePieces object.
	public static void main(String[] args)
	{
		new GamePieces();
	}
	
	// The GamePieces constructor will build the GUI based on
	// one instance of each concrete game piece
	public GamePieces()
	{
		// Create new window frame
	    JFrame myFrame = new JFrame();       
	    myFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    myFrame.setTitle("Game Piece Verification");

	    // set layout and border for main panel...we will have a 
	    // grid with 3 rows and 5 columns.
	    JPanel myPanel = (JPanel)myFrame.getContentPane();
	    myPanel.setLayout(new GridLayout(3,5,5,5));
	    myPanel.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

	    // create one instance of each class (Deputy, Henchman, Kingpin)
	    AbstractGamePiece[] gamePieces = new AbstractGamePiece[3];
	    gamePieces[0] = new Deputy();
	    gamePieces[1] = new Henchman();
	    gamePieces[2] = new Kingpin();

	    // for each game piece class
	    for (int i=0; i<gamePieces.length; i++)
	    {
	    	// get reference and store in base class reference
	    	AbstractGamePiece piece = gamePieces[i];
	    	
	    	// set the piece's position to some values using the current index
	    	piece.setPosition(i, i + 1);

	    	// add a new label to each column in the grid row by calling
	    	// many of the public methods on the AbstractGamePiece
	    	myPanel.add(new JLabel(piece.toString()));
	    	myPanel.add(new JLabel("Col: " + piece.getCol() + ", Row: " + piece.getRow() + ", Abbrev: " + piece.getAbbreviation()));
	    	myPanel.add(new JLabel("CanMove: " + piece.canMoveToLocation(null)));
	    	myPanel.add(new JLabel("isCaptured: " + piece.isCaptured(null)));
	    	myPanel.add(new JLabel("hasEscaped: " + piece.hasEscaped()));
	    }

	    // pack the frame and make it visible!
	    myFrame.pack();
	    myFrame.setVisible(true);                
	}
}