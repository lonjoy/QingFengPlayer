package media
{
	//20142014-9-25下午2:56:08
	//奋斗 QQ:275522479
	import flash.events.Event;
	
	public class MediaEvent extends Event
	{
		public static const BUFFER_STATUS_CHANGED:String="BUFFER_STATUS_CHANGED";
		public static const PLAY_STATUS_CHANGED:String="PLAY_STATUS_CHANGED";
		public static const TIME_CHANGED:String="TIME_CHANGED";
		public static const READY:String="READY";
		
		private var _data:Object=null;		
		
		public function MediaEvent(type:String,bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}