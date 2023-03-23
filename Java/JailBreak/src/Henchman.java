
public class Henchman extends AbstractGamePiece {

	public Henchman(){
		super("Henchman", "H", AbstractGamePiece.PLAYER_OUTLAWS);
	}
	
	@Override
	public boolean hasEscaped() {
		// TODO Auto-generated method stub
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


}