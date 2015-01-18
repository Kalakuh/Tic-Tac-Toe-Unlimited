package kalakuh.ttt
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Main extends Sprite 
	{
		private var board : Board;
		
		private var playAgain : Text;
		private var winner : Text;
		private var textAlpha : Number = 0;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			board = new Board();
			addChild(board);
			
			playAgain = new Text(3, "Press space to play again".toUpperCase(), 200);
			winner = new Text(10, "", 50);
			
			playAgain.alpha = 0;
			winner.alpha = 0;
			
			addChild(winner);
			addChild(playAgain);
			
			addEventListener(Event.ENTER_FRAME, updateAlpha);
		}
		
		public function showTexts (winner : int) : void {
			textAlpha = 1;
			this.winner.setText(winner == Mark.X ? "YOU WON" : "AI WON");
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		}
		
		private function onKeyPress (e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.SPACE) {
				hideTexts();
				board.startGame();
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			}
		}
		
		public function hideTexts () : void {
			textAlpha = 0;
		}
		
		private function updateAlpha (e : Event) : void {
			winner.alpha += (textAlpha - winner.alpha) / 10;
			playAgain.alpha += (textAlpha - playAgain.alpha) / 10;
		}
	}
	
}