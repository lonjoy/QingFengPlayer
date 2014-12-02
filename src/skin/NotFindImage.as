package cn.xdf.videoplayer20110704.ui 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class NotFindImage extends Sprite 
	{
		
		public function NotFindImage(w:Number,h:Number):void 
		{			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xffff);
			sprite.graphics.drawRect(0, 0, w, h);
			addChild(sprite);
			
			var text:TextField = new TextField();
			text.width = w;
			text.height = 20;
			text.multiline = false;
			text.wordWrap = true;
			text.text = "没有找到图片";
			text.x = 5;
			text.y = (h - text.height) / 2;
			//text.autoSize = TextFieldAutoSize.LEFT;
			addChild(text);
		}
		
	}

}