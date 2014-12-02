package skin.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class ProgressChangeEvent extends Event 
	{
		public static const CHANGE:String = "qecvsw24565";
		public var per:Number = 0;
		
		public function ProgressChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ProgressChangeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ProgressChangeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}