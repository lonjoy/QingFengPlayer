package  
{
	import com.greensock.motionPaths.RectanglePath2D;
	import data.Data;
	import data.DispatchEvents;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import skin.ControlBarManager;
	import skin.events.ProgressChangeEvent;
	import skin.events.VolChangeEvent;
	import media.video.AdvVideoPlayer
	import skin.Skin;
	import events.LoadingEvent;
	import events.NetConnectionEvent;
	import events.NetStreamEvent;
	import events.OnMetaDataEvent;
	import events.PlayingEvent;
	import events.PlayStatusEvent;
	import media.video.VideoPlayer;
	
	/**
	 * ...
	 * @author t
	 */
	public class ABC extends EventDispatcher 
	{
	    private var _skin:Skin;
		private var _videoPlayer:AdvVideoPlayer;
		private var _controlBarManager:ControlBarManager
		private var _stage:Stage;
		
		public function ABC() :void
		{
			
		}
		private function setVideoPlayer(v:AdvVideoPlayer):void
		{
			_videoPlayer = v;
			_videoPlayer.addEventListener(PlayStatusEvent.CHANGE, playStatusChangeHandler);
			_videoPlayer.addEventListener(PlayingEvent.PLAYING, playingHandler);
			_videoPlayer.addEventListener(NetStreamEvent.CHANGE, netStreamChangeHandler);
			_videoPlayer.addEventListener(NetConnectionEvent.CHANGE, netConnectionChangeHandler);
			_videoPlayer.addEventListener(LoadingEvent.LOADING, loadingHandler);
			_videoPlayer.addEventListener(OnMetaDataEvent.ON_METADATA, onMetaDataHandler);
			_videoPlayer.addEventListener("streamNotFound", streamNotFoundHandler);
		}
		private function playStatusChangeHandler(evn:PlayStatusEvent):void
		{
			_controlBarManager.setVideoStatus = evn.status;
			switch(evn.status)
			{
				case Data.PLAY:
					break;
				case Data.COMPLETE:
					_videoPlayer.visible = false;
					_controlBarManager.progressBarEnabled = false;
					DispatchEvents.STREAM_PLAY_COMPLETE();
					break;
			}
		}
		private function playingHandler(evn:PlayingEvent):void
		{
			_controlBarManager.setTime(evn.currentTime, _videoPlayer.totalTime);
		}
		private function loadingHandler(evn:LoadingEvent):void
		{
			_controlBarManager.loadPer = evn.percent;
		}
		private function onMetaDataHandler(evn:OnMetaDataEvent):void
		{
			if (Data.videoRatio == 0)
			{
				Data.videoRatio = evn.videoWidth / evn.videoHeight;
			}
			scale(Data.isFullScreen,Data.videoRatio);
		}
		private function streamNotFoundHandler(evn:Event):void
		{
			this.alertMsg1 = "视频加载失败";
			DispatchEvents.STREAM_NOT_FOUND();
		}
		private function netStreamChangeHandler(evn:NetStreamEvent)
		{
			switch(evn.status)
			{
				case "NetStream.Buffer.Full":
					_videoPlayer.visible = true;
					_controlBarManager.progressBarEnabled = true;
					break;
			}
		}
		private function netConnectionChangeHandler(evn:NetConnectionEvent)
		{
			switch(evn.status)
			{
				case "NetConnection.Connect.Failed":
					this.alertMsg1 = "服务器连接失败"
					DispatchEvents.CONNECT_FAILED();
					break;
			}
		}
		private function setSkin(s:Skin):void
		{
			_skin = s;
			
			_controlBarManager = new ControlBarManager();
			_controlBarManager.addEventListener("fullscreenBtnClick", fullscreenBtnClickHandler);
		    _controlBarManager.addEventListener("playBtnClick", playBtnClickHandler);
			_controlBarManager.addEventListener("pauseBtnClick", pauseBtnClickHandler);
			_controlBarManager.addEventListener(VolChangeEvent.CHANGE, volChangeHandler);
			_controlBarManager.addEventListener(ProgressChangeEvent.CHANGE, progressChangeHandler);
			_controlBarManager.add(_skin.controlBar);
		}
		private function fullscreenBtnClickHandler(evn:Event):void
		{
			switch(_stage.displayState) 
			{
				case "normal":
					_stage.displayState = "fullScreen";  
					scale(true,Data.videoRatio);
					break;
				case "fullScreen":
					default:
					_stage.displayState = "normal";    	
					scale(false,Data.videoRatio);
					break;
			}
		}
		private function playBtnClickHandler(evn:Event):void
		{
			_videoPlayer.resume();
		}
		private function pauseBtnClickHandler(evn:Event):void
		{
			_videoPlayer.pause();
		}
		private function volChangeHandler(evn:VolChangeEvent):void
		{
			_videoPlayer.setVol(evn.vol);
		}
		private function progressChangeHandler(evn:ProgressChangeEvent):void
		{
			_videoPlayer.seek(evn.per*_videoPlayer.totalTime/1000);
		}
		public function addObject(v:AdvVideoPlayer,s:Skin,sta:Stage):void
		{
			_stage = sta;
			setSkin(s);
			setVideoPlayer(v);
		}
		public function scale(isFullScreen:Boolean,xx:Number):void
		{
			if (isFullScreen)
			{
				_videoPlayer.scale(new Rectangle(0,0,_stage.stageWidth,_stage.stageHeight),xx);
			}
			else
			{
				_videoPlayer.scale(new Rectangle(0,0,_stage.stageWidth,_stage.stageHeight-_skin.controlBar.height),xx);
			}
			_controlBarManager.scale();
			_controlBarManager.isFullScreen = isFullScreen;
		}
		public function pause():void
		{
			_videoPlayer.pause();
		}
		public function resume():void
		{
			_videoPlayer.resume();
		}
		public function play(stream:String,fms:String,bufferTime:Number=3000):void
		{
			this.alertMsg1 = "";
			_videoPlayer.play(stream,fms,bufferTime);
		}
		public function set alertMsg1(msg:String):void
		{
			_controlBarManager.alertMsg = msg;
		}
	}

}