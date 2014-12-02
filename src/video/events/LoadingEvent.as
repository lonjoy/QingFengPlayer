package video.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class LoadingEvent extends Event 
	{
		public static const LOADING:String = "asdfvcfnuyhrv";
		public var percent:Number;
		
		public function LoadingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new LoadingEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LoadingEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}