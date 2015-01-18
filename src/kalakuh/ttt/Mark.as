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
		
		private function changeAlpha (e : Event) : void {
			highlightSprite.alpha += (highlightAlpha - highlightSprite.alpha) / 20;
		}
		
		public function highlight () : void {
			highlightAlpha = 1;
		}
		
		public function unHighlight () : void {
			highlightAlpha = 0;
		}
		
		public function setPos (x : Number, y : Number) : void {
			this.x = x;
			this.y = y;
		}
		
		public function getX () : int {
			return myX;
		}
		
		public function getY () : int {
			return myY;
		}
		
		public function getType () : int {
			return myType;
		}
	}
	
}