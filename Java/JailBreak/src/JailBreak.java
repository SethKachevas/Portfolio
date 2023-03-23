
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

// The JailBreak class implements ActionListener to receive button click events
public class JailBreak implements ActionListener
{
	// Declare class member variables to keep track of the UI controls on the JFrame
	private JFrame myFrame = null;
	private JPanel mainPanel = null;
	private JLabel playerTurnLabel = null;
	private JButton resetButton = null;
	
	// This member will contain the main game board object
	private GameBoard gameBoard = null;

	// This member will track which square (if any) is currently selected
	private GameSquare selectedSquare = null;
	
	// This flag will be set to true when the game is over, or should be false otherwise
	private boolean gameOver = false;

	// AbstractGamePiece.PLAYER_OUTLAWS or AbstractGamePiece.PLAYER_POSSE
	private int currentPlayerTurn;	
	
	// This member will hold a reference to the kingpin so we can check it later
	private AbstractGamePiece kingpinPiece = null;
	
	public static void main(String[] args)
	{
		new JailBreak();
	}
	
	public JailBreak()
	{
		// Create new JFrame and set the title. 
		myFrame = new JFrame();
		myFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		myFrame.setTitle("Jail Break!");
		myFrame.setResizable(false);	// don't let the user resize or board
		
		// The main panel will contain a vertical box layout 
		mainPanel = (JPanel)myFrame.getContentPane();
		mainPanel.setLayout(new BoxLayout(mainPanel,BoxLayout.Y_AXIS));

		// The top panel just contains the player turn label
		JPanel topPanel = new JPanel();
		topPanel.setLayout(new FlowLayout());
		playerTurnLabel = new JLabel();
		topPanel.add(playerTurnLabel);
		mainPanel.add(topPanel);

		// The middle panel contains the game board.  The GameBoard constructor
		// will build out all of the panel details, including all of the squares!
		JPanel boardPanel = new JPanel();
		gameBoard = new GameBoard(boardPanel,this);
		mainPanel.add(boardPanel);
		
		// The bottom panel will contain the reset button.
		JPanel bottomPanel = new JPanel();
		bottomPanel.setLayout(new FlowLayout());
		resetButton = new JButton("Reset");
		resetButton.addActionListener(this);
		bottomPanel.add(resetButton);
		mainPanel.add(bottomPanel);

		// reset the game to it's initial state
		reset();
		
		// we're ready, so pack and show the screen!
		myFrame.pack();
		myFrame.setVisible(true);
	}

	private void reset(){
		
		gameOver = false;
		gameBoard.reset();
		kingpinPiece = new Kingpin();
		gameBoard.setPiece(5, 5, kingpinPiece);
		
		gameBoard.setPiece(5,4,new Henchman());
		gameBoard.setPiece(5,3,new Henchman());
		gameBoard.setPiece(5,6,new Henchman());
		gameBoard.setPiece(5,7,new Henchman());
		gameBoard.setPiece(4,5,new Henchman());
		gameBoard.setPiece(3,5,new Henchman());
		gameBoard.setPiece(6,5,new Henchman());
		gameBoard.setPiece(7,5,new Henchman());
		gameBoard.setPiece(6,6,new Henchman());
		gameBoard.setPiece(4,4,new Henchman());
		gameBoard.setPiece(4,6,new Henchman());
		gameBoard.setPiece(6,4,new Henchman());
		
		gameBoard.setPiece(0, 3, new Deputy());
		gameBoard.setPiece(0, 4, new Deputy());
		gameBoard.setPiece(0, 5, new Deputy());
		gameBoard.setPiece(0, 6, new Deputy());
		gameBoard.setPiece(0, 7, new Deputy());
		gameBoard.setPiece(1, 5, new Deputy());
		
		gameBoard.setPiece(3, 0, new Deputy());
		gameBoard.setPiece(4, 0, new Deputy());
		gameBoard.setPiece(5, 1, new Deputy());
		gameBoard.setPiece(5, 0, new Deputy());
		gameBoard.setPiece(6, 0, new Deputy());
		gameBoard.setPiece(7, 0, new Deputy());
		
		gameBoard.setPiece(10, 6, new Deputy());
		gameBoard.setPiece(10, 7, new Deputy());
		gameBoard.setPiece(10, 3, new Deputy());
		gameBoard.setPiece(10, 4, new Deputy());
		gameBoard.setPiece(10, 5, new Deputy());
		gameBoard.setPiece(9, 5, new Deputy());
		
		gameBoard.setPiece(3, 10, new Deputy());
		gameBoard.setPiece(4, 10, new Deputy());
		gameBoard.setPiece(5, 9, new Deputy());
		gameBoard.setPiece(5, 10, new Deputy());
		gameBoard.setPiece(6, 10, new Deputy());
		gameBoard.setPiece(7, 10, new Deputy());
		
		currentPlayerTurn = AbstractGamePiece.PLAYER_POSSE;
		setPlayerTurnLabel();
		
	}
	
	private void changePlayerTurn()
	{
		if (currentPlayerTurn == AbstractGamePiece.PLAYER_OUTLAWS)
			currentPlayerTurn = AbstractGamePiece.PLAYER_POSSE;
		else
			currentPlayerTurn = AbstractGamePiece.PLAYER_OUTLAWS;
	}

	private void setPlayerTurnLabel()
	{
		if (currentPlayerTurn == AbstractGamePiece.PLAYER_OUTLAWS)
			playerTurnLabel.setText("Player Turn: Outlaws!");
		else
			playerTurnLabel.setText("Player Turn: Posse!");
	}

	public void actionPerformed(ActionEvent source)
	{
		// if the reset button was clicked
		if (source.getSource() == resetButton)
		{
			reset();	// reset the game
		}
		else if (!gameOver)	// else if the game is not over
		{
			// figure out which square, if any, on the game board was clicked
			GameSquare clickedSquare = gameBoard.getClickedSquare(source.getSource());
			if (clickedSquare != null)
			{
				// pass the clicked square to the main game logic function
				handleClickedSquare(clickedSquare);
				
				// update the current player's turn in case it was changed by the game logic
				setPlayerTurnLabel();
			}
				
		}
	}
	
	private void handleClickedSquare(GameSquare clickedSquare){
		
		if( selectedSquare == null ){
			
			if( clickedSquare.getPiece() != null ){
				if( currentPlayerTurn == clickedSquare.getPiece().getPlayerType() ){
					selectedSquare = clickedSquare;
					selectedSquare.select();
				}
			}
			
		} else if( selectedSquare == clickedSquare ){
			
			selectedSquare.deselect();
			selectedSquare = null;
			
		} else{
			
			AbstractGamePiece myPiece = selectedSquare.getPiece();
			List<GameSquare> myList = gameBoard.buildPath(selectedSquare, clickedSquare);
			
			if( myPiece.canMoveToLocation(myList) ){
				clickedSquare.setPiece(myPiece);
				selectedSquare.clearSquare();
				selectedSquare.deselect();
				selectedSquare = null;
				
				List<AbstractGamePiece> captured = findCapturedOpponents(myPiece.getCol(), myPiece.getRow());
				
				boolean check = false;
				
				for( AbstractGamePiece doneFor : captured ){
					
					JOptionPane.showMessageDialog(myFrame, doneFor.toString());
					
					gameBoard.removePiece(doneFor);
					
					if( doneFor == kingpinPiece ){
						check = true;
					}
					
				}
				
				
				if(check){
					gameOver = true;
					JOptionPane.showMessageDialog(myFrame, "The King has been captured and the game is over!");
				} else if( kingpinPiece.hasEscaped() ){
					gameOver = true;
					JOptionPane.showMessageDialog(myFrame, "The King has escaped and the game is over!");
				} else {
					changePlayerTurn();
				}

			}	
		}
		
	}
	
	private List<AbstractGamePiece> findCapturedOpponents(int col, int row)
	{
		// initialize an ArrayList that will hold any captured opponents
		ArrayList<AbstractGamePiece> capturedOpponents = new ArrayList<AbstractGamePiece>();
		
		// we are going to check each square up/down/left/right to see if there is a piece present.
		// If so, let the piece itself determine if it has been captured or not!
		AbstractGamePiece nearbyPiece = null;

		// get above piece
		nearbyPiece = gameBoard.getPiece(col, row - 1);	
		// if this piece exists and has been captured 
		if ((nearbyPiece != null) && (nearbyPiece.isCaptured(gameBoard)))
		{
			capturedOpponents.add(nearbyPiece);	// add captured piece to the list
		}
		
		// get below piece
		nearbyPiece = gameBoard.getPiece(col, row + 1);	
		// if this piece exists and has been captured 
		if ((nearbyPiece != null) && (nearbyPiece.isCaptured(gameBoard)))
		{
			capturedOpponents.add(nearbyPiece);	// add captured piece to the list
		}
		
		// get left piece
		nearbyPiece = gameBoard.getPiece(col - 1, row);	
		// if this piece exists and has been captured 
		if ((nearbyPiece != null) && (nearbyPiece.isCaptured(gameBoard)))
		{
			capturedOpponents.add(nearbyPiece);	// add captured piece to the list
		}
		
		// get right piece
		nearbyPiece = gameBoard.getPiece(col + 1, row);	
		// if this piece exists and has been captured 
		if ((nearbyPiece != null) && (nearbyPiece.isCaptured(gameBoard)))
		{
			capturedOpponents.add(nearbyPiece);	// add captured piece to the list
		}

		// return the list of captured opponents (may be empty!)
		return capturedOpponents;
	}
}