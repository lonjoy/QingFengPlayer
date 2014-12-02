package skin 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Skin extends EventDispatcher
	{
		private var _loader:Loader;
		private var _missComponent:String = "";
		private var _content:MovieClip;
		private var _controlBar:MovieClip;
		
		public function Skin() :void
		{			
			initLoader();
		}
		private function initLoader():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		}
		/**
		 * 加载完毕
		 * @param	evn
		 */
		private function loadComHandler(evn:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			
			_content = MovieClip(_loader.content);
			_controlBar = _content.controlBar;
			
			_missComponent = SkinChecker.check(_content);

			dispatchEvent(new Event(Event.COMPLETE));
		}
		/**
		 * 加载失败
		 * @param	evn
		 */
		private function loadErrorHandler(evn:IOErrorEvent):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		//记载皮肤
		public function load(skinURL:String):void
		{
			_loader.load(new URLRequest(skinURL));
		}
		public function get missComponent():String
		{
			return _missComponent;
		}
		public function get controlBar():MovieClip
		{
			return _controlBar;
		}
	}

}