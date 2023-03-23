
public class Kingpin extends AbstractGamePiece {
	
	public Kingpin(){
		super("Kingpin", "KP", AbstractGamePiece.PLAYER_OUTLAWS);
	}

	@Override
	public boolean isCaptured(GameBoard gameBoard) {

		AbstractGamePiece above = gameBoard.getPiece(myCol, myRow - 1);
		AbstractGamePiece below = gameBoard.getPiece(myCol, myRow + 1);
		AbstractGamePiece left = gameBoard.getPiece(myCol - 1, myRow);
		AbstractGamePiece right = gameBoard.getPiece(myCol + 1, myRow);
		
		if( above != null && below != null && above.getPlayerType() != myPlayerType && below.getPlayerType() != myPlayerType && left != null && right != null && left.getPlayerType() != myPlayerType && right.getPlayerType() != myPlayerType ){
			return true;
		}
		
		return false;
	}
	
	@Override
	protected boolean isSquareRestricted(GameSquare step) {
		int type = step.getType();
		
		if( type == GameSquare.TYPE_JAIL || type == GameSquare.TYPE_CAMP){
			return true;
		}
		
		return false;
		
	}

	@Override
	public boolean hasEscaped() {

		if( this.getRow() == 0 && this.getCol() == 0 ){
			return true;
		}
		
		if( this.getRow() == 10 && this.getCol() == 0 ){
			return true;
		}
		
		if( this.getCol() == 10 && this.getRow() == 0){
			return true;
		}
		
		if( this.getCol() == 10 && this.getRow() == 10 ){
			return true;
		}
		
		return false;
	}

}