package video.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class OnMetaDataEvent extends Event 
	{
		public static const ON_METADATA:String = "gsdfxcvasfavzxcaef";
		public var videoWidth:Number = 0;
		public var videoHeight:Number = 0;
		
		public function OnMetaDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new OnMetaDataEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("OnMetaDataEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}