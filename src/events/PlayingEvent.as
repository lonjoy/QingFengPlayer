package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class PlayingEvent extends Event 
	{
		public static const PLAYING:String = "qeadcc zf";
		public var currentTime:Number;
		
		public function PlayingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PlayingEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PlayingEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}