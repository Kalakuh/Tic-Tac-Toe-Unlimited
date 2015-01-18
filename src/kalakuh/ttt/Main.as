package kalakuh.ttt
{
	import flash.display.Bitmap;
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
		
		[Embed(source = "../../assets/instructions.png")]private var img : Class;
		private var instructions : Bitmap = new img();
		
		private var playAgain : Text;
		private var winner : Text;
		private var textAlpha : Number = 0;
		
		private var turn : Text;
		private var turnAlpha : Number = 0;
		
		private var instructionAlpha : Number = 1;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			board = new Board();
			
			playAgain = new Text(3, "Press space to play again".toUpperCase(), 200, true);
			winner = new Text(10, "", 50, true);
			turn = new Text(7, "", 50, false);
			
			playAgain.alpha = 0;
			winner.alpha = 0;
			turn.alpha = 0;
			instructions.alpha = 0;
			
			addChild(winner);
			addChild(playAgain);
			addChild(turn);
			
			addChildAt(board, 0);
			
			addChild(instructions);
			
			addEventListener(Event.ENTER_FRAME, updateAlpha);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		}
		
		public function showTexts (winner : int) : void {
			textAlpha = 1;
			this.winner.setText(winner == Mark.X ? "YOU WON" : "AI WON");
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		}
		
		private function onKeyPress (e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.SPACE) {
				instructionAlpha = 0;
				hideTexts();
				board.startGame();
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			}
		}
		
		public function showTurn (mark : int) : void {
			turnAlpha = 1;
			turn.setText(mark == Mark.X ? "YOUR TURN" : "AI'S TURN");
		}
		
		public function hideTexts () : void {
			textAlpha = 0;
		}
		
		private function updateAlpha (e : Event) : void {
			winner.alpha += (textAlpha - winner.alpha) / 10;
			playAgain.alpha += (textAlpha - playAgain.alpha) / 10;
			turn.alpha += (turnAlpha - turn.alpha) / 10;
			if (turn.alpha > 0.95) {
				turnAlpha = 0;
			}
			instructions.alpha += (instructionAlpha - instructions.alpha) / 10;
		}
	}
	
}