package kalakuh.ttt
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Mark extends Sprite 
	{
		public static const O : int = -1;
		public static const X : int = -2;
		private var myX : int;
		private var myY : int;
		private var myType : int;
		
		[Embed(source = "../../assets/O.svg")]private var oImg : Class;
		[Embed(source = "../../assets/X.svg")]private var xImg : Class;
		private var mark : Sprite;
		
		private var highlightSprite : Sprite = new Sprite();
		private var highlightAlpha : Number = 0;
		
		/**
		 * 
		 * @param	x		x position in grid
		 * @param	y		y position in grid
		 * @param	type	type of the mark - O or X
		 */
		public function Mark (x : int, y : int, type : int) : void {
			myX = x;
			myY = y;
			myType = type;
			
			if (type == X) {
				mark = new xImg();
			} else {
				mark = new oImg();
			}
			addChild(mark);
			
			highlightSprite.graphics.beginFill(0xFFCC00);
			highlightSprite.graphics.drawRect(2, 2, 16, 16);
			highlightSprite.graphics.endFill();
			
			addChildAt(highlightSprite, 0);
			addEventListener(Event.ENTER_FRAME, changeAlpha);
		}
		
		/**
		 * changes the alpha value of the highlighting depending on the highlightAlpha variable
		 * @param	e
		 */
		private function changeAlpha (e : Event) : void {
			highlightSprite.alpha += (highlightAlpha - highlightSprite.alpha) / 20;
		}
		
		/**
		 * add the highlighting effect
		 */
		public function highlight () : void {
			highlightAlpha = 1;
		}
		
		/**
		 * removes the highlighting effect
		 */
		public function unHighlight () : void {
			highlightAlpha = 0;
		}
		
		/**
		 * sets the position of the mark
		 * @param	x	new x position (in pixels)
		 * @param	y	new y position (in pixels)
		 */
		public function setPos (x : Number, y : Number) : void {
			this.x = x;
			this.y = y;
		}
		
		/**
		 * returns the x position of the mark
		 * @return x position (in grid)
		 */
		public function getX () : int {
			return myX;
		}
		
		/**
		 * returns the y position of the mark
		 * @return y position (in grid)
		 */
		public function getY () : int {
			return myY;
		}
		
		/**
		 * returns the type of the mark
		 * @return type of the mark
		 */
		public function getType () : int {
			return myType;
		}
	}
	
}