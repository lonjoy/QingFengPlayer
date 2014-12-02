package skin.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class VolChangeEvent extends Event 
	{
		public static const CHANGE:String = "adfeecaf4e";
		public var vol:Number = 0;
		
		public function VolChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new VolChangeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("VolChangeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}