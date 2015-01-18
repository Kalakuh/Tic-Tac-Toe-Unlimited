package kalakuh.ttt
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.*;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Text extends Sprite 
	{
		[Embed(source = "../../assets/font/Nebula.ttf", fontName = "Nebula", mimeType = "application/x-font-opentype", embedAsCFF = "false")]private var fontEmbed : Class;
		private var font : Font = new fontEmbed();
		private var format : TextFormat;
		private var text : TextField;
		
		private var i : uint = 0;
		
		public function Text (scale : Number, textString : String, y : Number) : void {
			format = new TextFormat(font.fontName, 20, 0x000000, false, false, false, null, null, TextFormatAlign.CENTER);
			text = new TextField();
			
			text.text = textString;
			text.embedFonts = true;
			text.antiAliasType = AntiAliasType.ADVANCED;
			text.setTextFormat(format);
			
			text.mouseEnabled = false;
			text.x = -320;
			
			text.width = 640;
			text.height = 30;
			
			this.scaleX = scale;
			this.scaleY = scale;
			this.x = 320;
			this.y = y;
			
			addChild(text);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update (e : Event) : void {
			i += 3;
			text.alpha = (Math.sin(Math.PI / 180 * i) / 4) + 0.60;
		}
		
		public function setText (str : String) : void {
			text.text = str;
			text.setTextFormat(format);
		}
	}
	
}