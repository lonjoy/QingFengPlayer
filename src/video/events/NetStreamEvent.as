package video.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class NetStreamEvent extends Event 
	{
        public static const CHANGE:String = "feadaadfe24";
		public var status:String;
		
		public function NetStreamEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new NetStreamEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("NetStreamEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}