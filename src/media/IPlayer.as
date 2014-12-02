package media
{
	import flash.events.IEventDispatcher;
	
	public interface IPlayer extends IEventDispatcher 
	{
		function play(url:String=null):void;
		function resume():void;
		function pause():void;
		function stop():void;
		function seek(time:Number):void;
		function canSeekToTime(tm:Number):Boolean;
		
		function set mute(b:Boolean):void;
		function get mute():Boolean;
		function set volume(n:Number):void;
        function get volume():Number;
        function get isReady():Boolean;
		function get isSeeking():Boolean;
		
		function get time():Number;
		function get duration():Number;
		function get byteLoaded():Number;
		function get bufferLoad():Number;
	}
}
