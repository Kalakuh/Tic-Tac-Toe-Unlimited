package kalakuh.ttt
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Kongregate extends Sprite
	{
		private var apiPath : String;
		private var kongregate : *;
		private var loader : Loader;
		
		public function Kongregate () {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init (e : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			Security.allowDomain(apiPath);
			
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(new URLRequest(LoaderInfo(root.loaderInfo).parameters.api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf"));
			this.addChild(loader);
		}
		
		private function loadComplete (e : Event) : void {
			kongregate = e.target.content;
			
			kongregate.services.connect();
		}
		
		public function addWinningStats (winner : int) : void {
			kongregate.stats.submit("GamesPlayed", 1);
			kongregate.stats.submit(winner == Mark.O ? "AIWins" : "PlayerWins", 1);
		}
	}
}