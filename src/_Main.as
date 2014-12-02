package 
{
	import data.DispatchEvents;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetFilterEvent;
	import flash.external.ExternalInterface;
	import skin.Skin;
	import media.video.AdvVideoPlayer;
	import data.Data

	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Main extends Sprite 
	{
		private var _skin:Skin;
		private var _videoPlayer:AdvVideoPlayer;
		private var _abc:ABC;
		
		public function Main():void 
		{
			try
			{
				ExternalInterface.addCallback("v_start", v_start);
				ExternalInterface.addCallback("v_pause", v_pause);
				ExternalInterface.addCallback("v_resume", v_resume);
			}
			catch (err:Error)
			{
				
			}
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
            
			stage.scaleMode=StageScaleMode.NO_SCALE  
			stage.align = StageAlign.TOP_LEFT
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			DispatchEvents.init(this);
			
			//stage.doubleClickEnabled=true
			//stage.addEventListener(MouseEvent.DOUBLE_CLICK, aaaaa);
			
			_videoPlayer = new AdvVideoPlayer();
			
			//v_start("videoPlayerSkin.swf","video1","rtmp://localhost/vod/","","3000");
			//v_start("videoPlayerSkin.swf","video1.mp4","","","3000");
		}
		private function initSkinLoader():void
		{
			_skin = new Skin();
			_skin.addEventListener(Event.COMPLETE, skinLoadComHandler);
			_skin.addEventListener(IOErrorEvent.IO_ERROR, skinLoadErrHandler);
		}
		private function skinLoadComHandler(evn:Event):void
		{
			if (_skin.missComponent=="")
			{
				this.addChild(_videoPlayer);
				this.addChild(_skin.controlBar);
				
				_abc = new ABC();
				_abc.addObject(_videoPlayer, _skin,stage);
				_abc.play(Data.stream,Data.fms, Data.bufferTime);
				_abc.scale(false,Data.videoRatio);
			}
			else
			{
				trace(_skin.missComponent)
			}
		}
		private function skinLoadErrHandler(evn:Event):void
		{
			_abc.alertMsg1 = "皮肤加载失败";
		}
		
		private function resizeHandler(evn:Event):void
		{
			_abc.scale(false,Data.videoRatio);
		}
		private function aaaaa(evn:Event):void
		{
			v_start("videoPlayerSkin.swf","video1","rtmp://localhost/vod/","","3000");
			//v_start("videoPlayerSkin.swf","video1.mp4","","","3000");
		}
		private function getVideoRatio(videoRatio:String):void
		{
			if (videoRatio != "")
			{
				var array:Array = videoRatio.split(":");
				if (array.length == 2)
				{
					Data.videoRatio = Number(array[0]) / Number(array[1]);
				}
			}
		}
		
		/*******************************************************************************************/
		
		public function v_start(skinSrc:String,stream:String,fms:String="",videoRatio:String="",bufferTime:String="3000"):void
		{
			if (stage!=null)
			{
				getVideoRatio(videoRatio);
				Data.bufferTime = Number(bufferTime);
				Data.fms = fms;
				Data.stream = stream;
				
				if (_skin == null)
				{
					initSkinLoader();
					_skin.load(skinSrc);
				}
				else
				{
					_abc.play(Data.stream,Data.fms, Data.bufferTime);
					_abc.scale(false,Data.videoRatio);
				}
			}
		}
		public function v_pause():void
		{
			_abc.pause();
		}
		public function v_resume():void
		{
			_abc.resume();
		}
	}
}