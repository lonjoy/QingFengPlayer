package data 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Data
	{
		public static const PLAY:String = "_play";
		public static const PAUSE:String = "_pause";
		public static const COMPLETE:String = "_playComplete";
		
		public static var videoRatio:Number = 0;
		public static var bufferTime:Number = 3000;
		public static var fms:String = "";
		public static var stream:String="";
		
		public static var isFullScreen:Boolean = false;		
		
	}

}