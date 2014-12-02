package data 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author t
	 */
	public class DispatchEvents 
	{
		private static var _obj:Sprite;
		
		public function DispatchEvents() :void
		{
			
		}
		public static function init(obj:Sprite)
		{
			DispatchEvents._obj = obj;
		}
		public static function CONNECT_FAILED():void
		{
			DispatchEvents._obj.dispatchEvent(new Event("connectFailed"));
			try
			{
				ExternalInterface.call("connectFailed");
			}
			catch (err:Error)
			{
				
			}
		}
		public static function STREAM_NOT_FOUND():void
		{
			DispatchEvents._obj.dispatchEvent(new Event("streamNotFound"));
			try
			{
				ExternalInterface.call("streamNotFound");
			}
			catch (err:Error)
			{
				
			}
		}
		public static function STREAM_PLAY_COMPLETE():void
		{
			DispatchEvents._obj.dispatchEvent(new Event("streamPlayComplete"));
			try
			{
				ExternalInterface.call("streamPlayComplete");
			}
			catch (err:Error)
			{
				
			}
		}
	}

}