package kalakuh.ttt
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Board extends Sprite 
	{
		private static const P1AI : Boolean = false; // is player 1 AI
		private static const P2AI : Boolean = true; // is player 2 AI
		private var player1Turn : Boolean; // is it player 1's turn
		private var player2Turn : Boolean; // is it player 2's turn
		private var player1Starts : Boolean = true; // does the player 1 start
		
		private var grid : Sprite;
		private static const SQUARE_WIDTH : Number = 20.0; // the width of each cell in grid
		private var scrollX : Number = 320;
		private var scrollY : Number = 240;
		
		private var prevMouseX : Number; // mouseX on prev frame
		private var prevMouseY : Number; // mouseY on prev frame
		private var mouseDown : Boolean = false; // is mouse down?
		private var dragStart : Point; // the point where dragging started
		
		// array that contains the marks
		private var marks : Vector.<Mark> = new <Mark>[];
		
		// stuff for scrollTo(x, y) func
		private var scrollTimer : Timer;
		private var targetX : Number;
		private var targetY : Number;
		private var scrolling : Boolean = false;
		
		// timer for making the mark appear
		private var appearTimer : Timer;
		
		// stuff for changing the turn
		private var turnTimer : Timer;
		private var canPlay : Boolean = false;
		
		public function Board () : void {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * called after the object is added to the stage
		 * @param	e
		 */
		private function init (e : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// grid
			grid = new Sprite();
			addChild(grid);
			
			// draw grid
			grid.graphics.lineStyle(4, 0xBBBBBB);
			for (var y : int = -1; y <= (stage.stageHeight / SQUARE_WIDTH) + 1; y++) {
				grid.graphics.moveTo( -SQUARE_WIDTH, y * SQUARE_WIDTH);
				grid.graphics.lineTo(stage.stageWidth + SQUARE_WIDTH, y * SQUARE_WIDTH);
			}
			for (var x : int = -1; x <= (stage.stageWidth / SQUARE_WIDTH) + 1; x++) {
				grid.graphics.moveTo(x * SQUARE_WIDTH, -SQUARE_WIDTH);
				grid.graphics.lineTo(x * SQUARE_WIDTH, stage.stageHeight + SQUARE_WIDTH);
			}
			
			// mouse stuff
			prevMouseX = mouseX;
			prevMouseY = mouseY;
			
			// other listeners
			addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseAction);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseAction);
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		/**
		 * makes the new game start
		 */
		public function startGame () : void {
			for each (var m : Mark in marks) {
				removeChild(m);
				m = null;
			}
			marks.splice(0, marks.length);
			
			canPlay = true;
			player1Turn = player1Starts;
			player2Turn = !player1Starts;
			player1Starts = !player1Starts;
			
			Main(parent).showTurn(player1Turn ? Mark.X : Mark.O);
			
			nextTurn();
		}
		
		/**
		 * called once each frame
		 * @param	e
		 */
		private function update (e : Event) : void {
			var m : Mark;
			if (scrolling) { // if scrollTo() is doing things
				// make grid move
				grid.x = scrollX % SQUARE_WIDTH;
				grid.y = scrollY % SQUARE_WIDTH;
				// move each mark
				for each (m in marks) {
					m.setPos((m.getX() * SQUARE_WIDTH) + scrollX, (m.getY() * SQUARE_WIDTH) + scrollY);
				}
			} else if (mouseDown) { // else if mouse is down
				// scroll
				scrollX += mouseX - prevMouseX;
				scrollY += mouseY - prevMouseY;
				
				// make grid move
				grid.x = scrollX % SQUARE_WIDTH;
				grid.y = scrollY % SQUARE_WIDTH;
				
				// move each mark
				for each (m in marks) {
					m.setPos((m.getX() * SQUARE_WIDTH) + scrollX, (m.getY() * SQUARE_WIDTH) + scrollY);
				}
			}
			// set these vars for the next frame
			prevMouseX = mouseX;
			prevMouseY = mouseY;
		}
		
		// if mouse is pressed down or freed
		private function mouseAction (e : MouseEvent) : void {
			mouseDown = e.buttonDown;
			if (mouseDown) dragStart = new Point(mouseX, mouseY);
		}
		
		/**
		 * when the stage is clicked
		 * @param	e
		 */
		private function onClick (e : MouseEvent) : void {
			// can a mark be played?
			if (canPlay) {
				// is the cell our mouse is touching containing a mark, and does the mouse have moved to much while holding it down
				if (!containsMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH)) && Math.sqrt(Math.pow(mouseX - dragStart.x, 2) + Math.pow(mouseY - dragStart.y, 2)) < 10) {
					// is it player 1's turn and is he actual player
					if (player1Turn && !P1AI) {
						addMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH), Mark.X);
					} else if (player2Turn && !P2AI) { // is it player 2's turn?
						addMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH), Mark.O);
					}
				}
			}
		}
		
		/**
		 * does the cell contain a mark
		 * @param	x		x pos in grid
		 * @param	y		y pos in grid
		 * @param	type	type of mark (optional)
		 * @return
		 */
		private function containsMark (x : int, y : int, type : int = 0) : Boolean {
			for each (var m : Mark in marks) {
				if (m.getX() == x && m.getY() == y) {
					if (type == 0) {
						return true;
					} else if (m.getType() == type) {
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * get a mark at cell
		 * @param	x		x pos in grid
		 * @param	y		y pos in grid
		 * @param	type	type of mark (optional)
		 * @return	
		 */
		private function getMark (x : int, y : int, type : int = 0) : Mark {
			for each (var m : Mark in marks) {
				if (m.getX() == x && m.getY() == y) {
					if (type == 0) {
						return m;
					} else if (m.getType() == type) {
						return m;
					}
				}
			}
			return null;
		}
		
		/**
		 * adds a new mark to the grid
		 * @param	x		x pos in grid
		 * @param	y		y pos in grid
		 * @param	type	type of mark
		 */
		private function addMark (x : int, y : int, type : uint) : void {
			canPlay = false;
			
			// unhighlight the previos mark
			if (marks.length >= 1) {
				marks[marks.length - 1].unHighlight();
			}
			
			// add a new mark
			var mark : Mark = new Mark(x, y, type);
			mark.setPos((x * SQUARE_WIDTH) + scrollX, (y * SQUARE_WIDTH) + scrollY);
			mark.alpha = 0;
			addChild(mark);
			marks.push(mark);
			mark.highlight();
			
			// scroll to the point where we added the mark, and make it appear
			scrollTo(mark.getX() * SQUARE_WIDTH - (stage.stageWidth / 2), mark.getY() * SQUARE_WIDTH - (stage.stageHeight / 2));
			makeLatestMarkAppear();
		}
		
		/**
		 * scroll to given coordinates
		 * @param	x	x pos
		 * @param	y	y pos
		 */
		private function scrollTo (x : Number, y : Number) : void {
			scrollTimer = new Timer(25, 30);
			targetX = -x;
			targetY = -y;
			scrollTimer.addEventListener(TimerEvent.TIMER, move);
			scrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, scrollDone);
			scrollTimer.start();
			scrolling = true;
		}
		
		/**
		 * called by a scrollTimer
		 * @param	e
		 */
		private function move (e : TimerEvent) : void {
			scrollX += (targetX - scrollX) / 10;
			scrollY += (targetY - scrollY) / 10;
		}
		
		/**
		 * called after the scrolling is done
		 * @param	e
		 */
		private function scrollDone (e : TimerEvent) : void {
			scrollTimer.removeEventListener(TimerEvent.TIMER, move);
			scrollTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, scrollDone);
			scrollTimer = null;
			scrolling = false;
		}
		
		/**
		 * makes the last mark appear
		 */
		private function makeLatestMarkAppear () : void {
			appearTimer = new Timer(25, 40);
			appearTimer.addEventListener(TimerEvent.TIMER, fadeIn);
			appearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, appeared);
			appearTimer.start();
		}
		
		/**
		 * appear...
		 * @param	e
		 */
		private function fadeIn (e : TimerEvent) : void {
			marks[marks.length - 1].alpha += (1 / 40);
		}
		
		/**
		 * after appearing, check if anyone has one, and start next turn
		 * @param	e
		 */
		private function appeared (e : TimerEvent) : void {
			// remove listeners
			appearTimer.removeEventListener(TimerEvent.TIMER, fadeIn);
			appearTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, appeared);
			appearTimer = null;
			
			// make sure last mark is visible
			marks[marks.length - 1].alpha = 1;
			
			// is game won?
			var gameWon : Boolean;
			gameWon = gameWon || checkWin(0, 1);
			gameWon = gameWon || checkWin(1, 1);
			gameWon = gameWon || checkWin(1, 0);
			gameWon = gameWon || checkWin(1, -1);
			
			if (!gameWon) { // continue game
				Main(parent).showTurn(!player1Turn ? Mark.X : Mark.O);
				turnTimer = new Timer(1000, 1);
				turnTimer.addEventListener(TimerEvent.TIMER_COMPLETE, nextTurn);
				turnTimer.start();
			} else { // make texts appear
				Main(parent).showWinner(marks[marks.length - 1].getType());
			}
		}
		
		/**
		 * start next turn
		 * @param	e
		 */
		private function nextTurn (e : TimerEvent = null) : void {
			// remove listeners, change whose turn it is
			if (turnTimer != null) {
				turnTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextTurn);
				turnTimer = null;
				player1Turn = !player1Turn;
				player2Turn = !player2Turn;
			}
			
			canPlay = true;
			
			// if there're AI's they choose what they do
			var aiTurn : Point;
			
			if (player1Turn && P1AI) {
				aiTurn = AI.nextMove(marks, Mark.X);
				addMark(aiTurn.x, aiTurn.y, Mark.X);
			} else if (player2Turn && P2AI) {
				aiTurn = AI.nextMove(marks, Mark.O);
				addMark(aiTurn.x, aiTurn.y, Mark.O);
			}
		}
		
		/**
		 * checks if someone has won
		 * @param	xChange how much do we change x
		 * @param	yChange how much do we change y
		 * @return	has anyone won?
		 */
		private function checkWin (xChange : int, yChange : int) : Boolean {
			var found : uint = 0;
			var type : int = marks[marks.length - 1].getType();
			var x : int = marks[marks.length - 1].getX();
			var y : int = marks[marks.length - 1].getY();
			
			// go backwards while there's a mark on the line
			while (containsMark(x - xChange, y - yChange, type)) {
				x -= xChange;
				y -= yChange;
			}
			var beginX : int = x;
			var beginY : int = y;
			
			// array that cointains marks on the row
			var marksOnLine : Array = new Array();
			while (containsMark(x, y, type)) {
				marksOnLine.push(getMark(x, y, type));
				x += xChange;
				y += yChange;
				found++;
			}
			
			// if there're more than 5 marks on row, highlight them and return true
			if (found >= 5) {
				for each (var m : Mark in marksOnLine) {
					m.highlight();
				}
			}
			
			return found >= 5;
		}
	}
	
}