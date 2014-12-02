package cn.xdf.videoplayer20110704.ui 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class BlackBG extends Sprite 
	{
		
		public function BlackBG(w:Number,h:Number) :void
		{
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, w, h);
		}
		
	}

}