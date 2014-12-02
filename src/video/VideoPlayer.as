package video
{
	import data.Data;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	import video.events.LoadingEvent;
	import video.events.NetConnectionEvent;
	import video.events.NetStreamEvent;
	import video.events.OnMetaDataEvent;
	import video.events.PlayingEvent;
	import video.events.PlayStatusEvent;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class VideoPlayer extends Sprite  
	{
		private var _video:Video;
		
		private var _netStream:NetStream;
		private var _netConnetction:NetConnection;
		
		private var _totalTime:Number = 0;//视频总时间
		
		private var _connectSuccess:Boolean = false;//连接是否成功了
		
		private var _playStatus:String = "";
		private var _useFms:Boolean = false;//是否使用fms
		
		private var _playingTimer:Timer;
		private var _loadingTimer:Timer;
		
		private var _stream:String;
		private var _bufferTime:Number;
		
		private var _stop:Boolean = false;
		private var _flush:Boolean = false;
		
		public function VideoPlayer():void
		{
			initVideo(400,300);
		}
		//初始化视频元件
		private function initVideo(videoWidth:Number,videoHeight:Number):void
		{
			_video = new Video();
			_video.width = videoWidth;
			_video.height = videoHeight;
			_video.smoothing = true;
			addChild(_video);
		}
		//初始化连接
		private function initNetConnecttion():void
		{
			 _netConnetction = new NetConnection();
			 _netConnetction.addEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
			 _netConnetction.client = this;
		}
        //初始化流
		private function initStream(nc:NetConnection,videoComonent:Video,bufferTime:Number):void
		{
			_netStream = new NetStream(nc);
			_netStream.client = this;
			_netStream.bufferTime = bufferTime / 1000;
			videoComonent.attachNetStream(_netStream);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
		}
		private function onConnectSuccess():void
		{
			_connectSuccess = true;
			initTimer();
			initStream(_netConnetction, _video, _bufferTime);
			_netStream.play(_stream);
			
		}
		private function ncStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			switch (msg) 
			{ 
				case "NetConnection.Connect.Success":
					onConnectSuccess();
					break;
				case "NetConnection.Connect.Failed":
					_connectSuccess = false;
				    break;
			}
			var event:NetConnectionEvent = new NetConnectionEvent(NetConnectionEvent.CHANGE);
			event.status = msg;
			dispatchEvent(event);
		}
		private function onStreamNotFound():void
		{
			_loadingTimer.stop();
			_playingTimer.stop();
			dispatchEvent(new Event("streamNotFound"));
		}
		private function nsStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			//trace(msg)
			switch (msg) 
			{ 
				case "NetStream.Play.Start":
					onPlayStart();
					break;
				case "NetStream.Buffer.Full":
				    _flush = false;
				    break;
				case "NetStream.Buffer.Empty":
					onBufferEmpty();
				    break;
				case "NetStream.Seek.Notify":
					_flush = false;
				    break;
				case "NetStream.Buffer.Flush":
				    _flush = true;
				    break;	
				case "NetStream.Unpause.Notify":
				    /*_bufferFull = false;
					_bufferFlush = false;
					_playingTimer.stop();*/
				    break;	
				case "NetStream.Play.Stop":
				    _stop = true;
				    break;	
				case "NetStream.Play.StreamNotFound":
					onStreamNotFound();
					break;
			}
			var event:NetStreamEvent = new NetStreamEvent(NetStreamEvent.CHANGE);
			event.status = msg;
			dispatchEvent(event);
		}
        private function onPlayStart():void
		{
			if (!_useFms)
			{
				_loadingTimer.start();
			}
			_playingTimer.start();
			_playStatus = Data.PLAY;
					
			var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
			event.status = Data.PLAY;
			dispatchEvent(event);
		}
		private function playComplete():void
		{
			_playStatus = Data.COMPLETE;
			//_netStream.seek(0);
			//_netStream.pause();
					
			var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
			event.status = Data.COMPLETE;
			dispatchEvent(event);
		}
		private function onBufferEmpty():void
		{
			if (!_useFms)
			{
				if (_flush && _stop)
				{
					playComplete();
				}
			}
		}
		private function initTimer():void
		{
			_playingTimer = new Timer(100);
			_playingTimer.addEventListener(TimerEvent.TIMER, playingTimerHandler);
			
			if (!_useFms)
			{
				_loadingTimer = new Timer(100);
				_loadingTimer.addEventListener(TimerEvent.TIMER, loadingHandler);
			}
		}
		 //加载中
		private function loadingHandler(evn:Event):void
		{
			var per:Number = _netStream.bytesLoaded / _netStream.bytesTotal;
			
			var event:LoadingEvent = new LoadingEvent(LoadingEvent.LOADING);
			event.percent = per;
			dispatchEvent(event);
		}
		private function playingTimerHandler(evn:TimerEvent):void
		{
			var event:PlayingEvent = new PlayingEvent(PlayingEvent.PLAYING);
			event.currentTime = _netStream.time*1000;
			dispatchEvent(event);
		}
		private function _pause():void
		{
			if (_connectSuccess)
			{
				if (_playStatus == Data.PLAY)
				{
					_netStream.pause();
					_playStatus = Data.PAUSE;
					_playingTimer.stop();
					
					var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
					event.status = Data.PAUSE;
					dispatchEvent(event);
				}
			}
		}
		private function _seek(time:Number):void
		{
			if (_connectSuccess)
			{
				_netStream.seek(time);
			}
		}
		private function _resume():void
		{
			if (_connectSuccess)
			{
				switch(_playStatus)
				{
					case Data.PAUSE:
						_netStream.resume();
						_playStatus = Data.PLAY;
						_playingTimer.start();
						break;
					case Data.COMPLETE:
						_netStream.play(_stream,0);
						_playStatus = Data.PLAY;
						_playingTimer.start();
						break;
				}
				var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
				event.status = Data.PLAY;
				dispatchEvent(event);
			}
		}
		private function clear():void
		{			
			_netConnetction.close();
			_netConnetction.removeEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
			_netConnetction = null;
			
			_netStream.close();
			_netStream.removeEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
			_netStream = null;
			
			_totalTime = 0;
			_connectSuccess = false;
			_playStatus= "";
		    _useFms = false;
			_stop = false;
			_flush = false;
			
			_playingTimer.stop();
			_playingTimer.removeEventListener(TimerEvent.TIMER, playingTimerHandler);
			_playingTimer = null;
			
			if (!_useFms)
			{
				if (_loadingTimer != null)
				{
					_loadingTimer.stop();
					_loadingTimer.removeEventListener(TimerEvent.TIMER, loadingHandler);
					_loadingTimer = null;
				}
			}
		}
		private function _play(stream:String,fms:String,bufferTime:Number):void
		{
			if (_netConnetction != null)
			{
				clear();
			}
			_bufferTime = bufferTime;
			_stream = stream;
			
			//removeChild(_video);
			//initVideo(400,300);
			
			initNetConnecttion();
			//trace(fms)
			if (fms == "")
			{
				_useFms = false;
				_netConnetction.connect(null);
			}
			else
			{
				_useFms = true;
				_netConnetction.connect(fms);
			}
		}
		///////////////////////////////////////////////////////////////////////////////////////////////
		public function onMetaData(obj:Object):void
		{
			_totalTime = obj.duration*1000;
			
			var event:OnMetaDataEvent = new OnMetaDataEvent(OnMetaDataEvent.ON_METADATA);
			event.videoWidth = obj.width;
			event.videoHeight = obj.height;
			dispatchEvent(event);
		}
		public function onPlayStatus(obj:Object):void
		{
			switch (obj.code)
			{
				case "NetStream.Play.Complete":
					if (_useFms)
					{
						playComplete();
					}
				    break;
				case "NetStream.Play.TransitionComplete":
				    trace("流切换成功")
					break;
			}
			
		}
		public function onBWDone():void
		{
			
		}
		public function onXMPData(obj:Object):void
		{
			
		}
		public function onFI(obj:Object):void
		{
			
		}
		/****************************************************************************** 方法 **********************/
		public function play(stream:String,fms:String="",bufferTime:Number=5000):void
		{
			_play(stream,fms,bufferTime);
		}
		public function pause():void
		{
			_pause();
		}
		public function resume():void
		{
			_resume();
		}
		public function seek(time:Number):void
		{
			_seek(time);
		}
		//设置音量
		public function setVol(n:Number):void
		{
			SoundMixer.soundTransform = new SoundTransform( n );
		}
		/****************************************************************************** 属性 ********************/
		//连接是否成功
		public function get connectSuccess():Boolean
		{
			return _connectSuccess;
		}
		//视频持续时间
		public function get totalTime():Number
		{
			if (_connectSuccess)
			{
				return _totalTime;
			}
			return 0;
		}
		public function get status():String
		{
			return _playStatus;
		}
	}
	
}