
public class Deputy extends AbstractGamePiece {
	
	public Deputy(){
		super("Deputy", "D", AbstractGamePiece.PLAYER_POSSE);
	}

	@Override
	public boolean hasEscaped() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	protected boolean isSquareRestricted(GameSquare step) {
		int type = step.getType();
		
		if( type == GameSquare.TYPE_JAIL){
			return true;
		}
		
		return false;
		
	}

}