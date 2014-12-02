package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class PlayStatusEvent extends Event 
	{
		public static const CHANGE:String = "adfadsfefcvrf";
		public var status:String="";
		
		public function PlayStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PlayStatusEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PlayStatusEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}