package video.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class NetConnectionEvent extends Event 
	{
        public static const CHANGE:String = "145rfdsf4dsff";
		public var status:String;
		
		public function NetConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new NetConnectionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("NetConnectionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}