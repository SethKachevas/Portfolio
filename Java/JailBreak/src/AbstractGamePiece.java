
import java.util.*;

abstract public class AbstractGamePiece
{
	// These two constants define the Outlaws and Posse teams
	static public final int PLAYER_OUTLAWS = 0;
	static public final int PLAYER_POSSE = 1;

	// These variables hold the piece's column and row index
	protected int myCol;
	protected int myRow;
	
	// This variable indicates which team the piece belongs to
	protected int myPlayerType;
	
	// These two strings contain the piece's full name and first letter abbreviation
	private String myAbbreviation;
	private String myName;

	// All derived classes will need to implement this method
	abstract public boolean hasEscaped();
	
	// The student should complete this constructor by initializing the member
	// variables with the provided data.
	public AbstractGamePiece(String name, String abbreviation, int playerType)
	{
		myName = name;
		myAbbreviation = abbreviation;
		myPlayerType = playerType;
	}
	
	public int getPlayerType(){
		return myPlayerType;
	}
	
	public void setPosition(int col, int row){
		myCol = col;
		myRow = row;
	}
	
	public int getCol(){
		return myCol;
	}

	public int getRow(){
		return myRow;
	}
	
	public String getAbbreviation(){
		return myAbbreviation;
	}
	
	public String toString(){
		
		String type = "";
		
		if( myPlayerType == AbstractGamePiece.PLAYER_OUTLAWS ){
			type = "Outlaw";
		} else{
			type = "Posse";
		}
		
		String info = type + " " +  myName + " at (" + myCol + "," + myRow + ")";
		
		return info;
		
	}
	
	abstract protected boolean isSquareRestricted(GameSquare step);
	
	public boolean canMoveToLocation(List<GameSquare> path){
		
		if( path.isEmpty() ){
			return false;
		}
		
		for( GameSquare square : path ){
			
			if( this.isSquareRestricted(square) == true ){
				return false;
			}
			
			if ( square.getPiece() != null ){
				
				return false;
				
			}
			
		}
		
		return true;
	}
	
	public boolean isCaptured(GameBoard gameBoard){
		
		AbstractGamePiece above = gameBoard.getPiece(myCol, myRow - 1);
		AbstractGamePiece below = gameBoard.getPiece(myCol, myRow + 1);
		
		if( above != null && below != null && above.getPlayerType() != myPlayerType && below.getPlayerType() != myPlayerType ){
			return true;
		}
		
		AbstractGamePiece left = gameBoard.getPiece(myCol - 1, myRow);
		AbstractGamePiece right = gameBoard.getPiece(myCol + 1, myRow);
		
		if( left != null && right != null && left.getPlayerType() != myPlayerType && right.getPlayerType() != myPlayerType ){
			return true;
		}
		
		return false;
	}
		
}