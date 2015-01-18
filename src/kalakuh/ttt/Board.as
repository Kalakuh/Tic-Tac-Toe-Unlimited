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
		private static const P1AI : Boolean = false;
		private static const P2AI : Boolean = true;
		private var player1Turn : Boolean;
		private var player2Turn : Boolean;
		
		private var grid : Sprite;
		private static const SQUARE_WIDTH : Number = 20.0;
		private var scrollX : Number = 320;
		private var scrollY : Number = 240;
		
		private var prevMouseX : Number;
		private var prevMouseY : Number;
		private var mouseDown : Boolean = false;
		
		private var marks : Vector.<Mark> = new <Mark>[];
		private var dragStart : Point;
		
		private var scrollTimer : Timer;
		private var targetX : Number;
		private var targetY : Number;
		private var scrolling : Boolean = false;
		
		private var appearTimer : Timer;
		
		private var turnTimer : Timer;
		private var canPlay : Boolean = false;
		
		public function Board () : void {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init (e : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// grid
			grid = new Sprite();
			addChild(grid);
			
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
			
			startGame();
		}
		
		public function startGame () : void {
			for each (var m : Mark in marks) {
				removeChild(m);
				m = null;
			}
			marks.splice(0, marks.length);
			
			canPlay = true;
			player1Turn = true;
			player2Turn = false;
			nextTurn();
		}
		
		private function update (e : Event) : void {
			var m : Mark;
			if (scrolling) {
				grid.x = scrollX % SQUARE_WIDTH;
				grid.y = scrollY % SQUARE_WIDTH;
				for each (m in marks) {
					m.setPos((m.getX() * SQUARE_WIDTH) + scrollX, (m.getY() * SQUARE_WIDTH) + scrollY);
				}
			} else if (mouseDown) {
				scrollX += mouseX - prevMouseX;
				scrollY += mouseY - prevMouseY;
				grid.x = scrollX % SQUARE_WIDTH;
				grid.y = scrollY % SQUARE_WIDTH;
				for each (m in marks) {
					m.setPos((m.getX() * SQUARE_WIDTH) + scrollX, (m.getY() * SQUARE_WIDTH) + scrollY);
				}
			}
			prevMouseX = mouseX;
			prevMouseY = mouseY;
		}
		
		private function mouseAction (e : MouseEvent) : void {
			mouseDown = e.buttonDown;
			if (mouseDown) dragStart = new Point(mouseX, mouseY);
		}
		
		private function onClick (e : MouseEvent) : void {
			if (canPlay) {
				if (player1Turn && !P1AI && !containsMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH)) && Math.sqrt(Math.pow(mouseX - dragStart.x, 2) + Math.pow(mouseY - dragStart.y, 2)) < 10) {
					addMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH), Mark.X);
				} else if (player2Turn && !P2AI && !containsMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH)) && Math.sqrt(Math.pow(mouseX - dragStart.x, 2) + Math.pow(mouseY - dragStart.y, 2)) < 10) {
					addMark(Math.floor((mouseX - scrollX) / SQUARE_WIDTH), Math.floor((mouseY - scrollY) / SQUARE_WIDTH), Mark.O);
				}
			}
		}
		
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
		
		private function addMark (x : int, y : int, type : uint) : Boolean {
			for each (var m : Mark in marks) {
				if (m.getX() == x && m.getY() == y) {
					return false;
				}
			}
			
			canPlay = false;
			
			if (marks.length >= 1) {
				marks[marks.length - 1].unHighlight();
			}
			
			var mark : Mark = new Mark(x, y, type);
			mark.setPos((x * SQUARE_WIDTH) + scrollX, (y * SQUARE_WIDTH) + scrollY);
			mark.alpha = 0;
			addChild(mark);
			marks.push(mark);
			mark.highlight();
			
			scrollTo(mark.getX() * SQUARE_WIDTH - (stage.stageWidth / 2), mark.getY() * SQUARE_WIDTH - (stage.stageHeight / 2));
			makeLatestMarkAppear();
			
			return true;
		}
		
		private function scrollTo (x : Number, y : Number) : void {
			scrollTimer = new Timer(25, 30);
			targetX = -x;
			targetY = -y;
			scrollTimer.addEventListener(TimerEvent.TIMER, move);
			scrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, scrollDone);
			scrollTimer.start();
			scrolling = true;
		}
		
		private function move (e : TimerEvent) : void {
			scrollX += (targetX - scrollX) / 10;
			scrollY += (targetY - scrollY) / 10;
		}
		
		private function scrollDone (e : TimerEvent) : void {
			scrollTimer.removeEventListener(TimerEvent.TIMER, move);
			scrollTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, scrollDone);
			scrollTimer = null;
			scrolling = false;
		}
		
		private function makeLatestMarkAppear () : void {
			appearTimer = new Timer(25, 40);
			appearTimer.addEventListener(TimerEvent.TIMER, fadeIn);
			appearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, appeared);
			appearTimer.start();
		}
		
		private function fadeIn (e : TimerEvent) : void {
			marks[marks.length - 1].alpha += (1 / 40);
		}
		
		private function appeared (e : TimerEvent) : void {
			appearTimer.removeEventListener(TimerEvent.TIMER, fadeIn);
			appearTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, appeared);
			appearTimer = null;
			
			marks[marks.length - 1].alpha = 1;
			
			var gameWon : Boolean;
			gameWon = gameWon || checkWin(0, 1);
			gameWon = gameWon || checkWin(1, 1);
			gameWon = gameWon || checkWin(1, 0);
			gameWon = gameWon || checkWin(1, -1);
			if (!gameWon) {
				turnTimer = new Timer(500, 1);
				turnTimer.addEventListener(TimerEvent.TIMER_COMPLETE, nextTurn);
				turnTimer.start();
			} else {
				Main(parent).showTexts(marks[marks.length - 1].getType());
			}
		}
		
		private function nextTurn (e : TimerEvent = null) : void {
			if (turnTimer != null) {
				turnTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextTurn);
				turnTimer = null;
				player1Turn = !player1Turn;
				player2Turn = !player2Turn;
			}
			
			canPlay = true;
			
			var aiTurn : Point;
			
			if (player1Turn && P1AI) {
				aiTurn = AI.nextMove(marks, Mark.X);
				addMark(aiTurn.x, aiTurn.y, Mark.X);
			} else if (player2Turn && P2AI) {
				aiTurn = AI.nextMove(marks, Mark.O);
				addMark(aiTurn.x, aiTurn.y, Mark.O);
			}
		}
		
		private function checkWin (xChange : int, yChange : int) : Boolean {
			var found : uint = 0;
			var type : int = marks[marks.length - 1].getType();
			var x : int = marks[marks.length - 1].getX();
			var y : int = marks[marks.length - 1].getY();
			
			
			while (containsMark(x - xChange, y - yChange, type)) {
				x -= xChange;
				y -= yChange;
			}
			var beginX : int = x;
			var beginY : int = y;
			
			
			var marksOnLine : Array = new Array();
			while (containsMark(x, y, type)) {
				marksOnLine.push(getMark(x, y, type));
				x += xChange;
				y += yChange;
				found++;
			}
			
			if (found >= 5) {
				for each (var m : Mark in marksOnLine) {
					m.highlight();
				}
			}
			
			return found >= 5;
		}
	}
	
}