package video 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class AdvVideoPlayer extends VideoPlayer 
	{
		public function AdvVideoPlayer() :void
		{
			super();
		}
		public function scale(rect:Rectangle,b:Number=-1):void
		{			
			var areaPer:Number = rect.width / rect.height;
			var videoPer:Number
			if (b==-1)
			{
				videoPer = this.width / this.height;
			}
			else
			{
				videoPer = b;
			}

			if (videoPer >= areaPer)
			{
				this.width = rect.width;
				this.height = this.width / videoPer;
			
				this.y = (rect.height - this.height) / 2;
				this.x = 0;
				
			}
			else
			{
				this.height = rect.height;
				this.width = this.height * videoPer;
			
				this.x = (rect.width - this.width) / 2;
				this.y = 0;
			}
		}
	}

}