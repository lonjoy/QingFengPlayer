package media
{	
	import com.greensock.layout.*;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.NetStatusEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import media.MediaEvent;
	import media.PlayState;
	
	public class BaseVideo extends Sprite implements IPlayer
	{
		private var _video:Video;
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _fmsServer:String;
		
		private var size:Point;
		private var _bufferTime:Number=0.1;
		private var _startParams:String="start";
		private var _url:String;		
		
		private var _isReady:Boolean=false;
		private var _metaData:Object=null;
		private var _isHttpstream:Boolean=false;
		private var _isRtmpstream:Boolean=false;
		private var _seeker:Seeker;
		private var _listenTimer:Timer;
		
		private var _preTime:Number=0;
		private var _seekToTime:Number=-1;
		private var _isBuffering:Boolean=false;
		
		private var _mute:Boolean=false;
		private var _volume:Number=1;
		private var _isSeeking:Boolean=false;
		private var _playStatus:uint;
		
		private var _areaWidth:Number=400;
		private var _areaHeight:Number=300;
		
		public function BaseVideo(bufferTime:Number,startParams:String=null)
		{
			_bufferTime=bufferTime;
			_startParams=startParams;
			init();
		}
		private function init():void
		{               
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS,onNetStateHandler);

			if(GlobleData.isRTMP)
			{
				if(_fmsServer)
				{
					_netConnection.connect(_fmsServer);
				}
				else
				{
					trace("当前是rtmp，但没有解析出fms服务器地址")
				}
			}
			else
			{
				_netConnection.connect(null)
			}
		}
		private function onNetStateHandler(event:NetStatusEvent):void
		{
			if(event.target==_netStream)
			{  
				switch(event.info.code)
				{
					case "NetStream.Unpause.Notify":
						dispatchOnPlayStatusChange(PlayState.PLAY);
						break;
					case "NetStream.Pause.Notify":
						dispatchOnPlayStatusChange(PlayState.PAUSE);
						break;
					case "NetStream.Play.StreamNotFound":
						dispatchOnPlayStatusChange(PlayState.ERRO);
						break;
					case "NetStream.Buffer.Full":
						_isBuffering=false;
						_isSeeking=false;
						dispatchOnBufferStatusChange(BufferStatus.END);
						break;
				}
			}
			else
			{
				switch(event.info.code)
				{
					case "NetConnection.Connect.Success":
						onConnectSuccess();
						break;
					case "NetConnection.Connect.Failed":
						onConnectFailed();
						break;
					case "NetConnection.Connect.Closed":
						onConnectClosed();
						break;
				}
			}
		}
		private function onConnectSuccess():void
		{
			initStream();
			initTime();
			initVideo();
		}
		private function initStream():void
		{
			_netStream = new NetStream(_netConnection);
			
			_netStream.bufferTime=this._bufferTime;
			
			var netClient:Object=new Object();
			netClient.onMetaData = onMetaData;
			netClient.onCuePoint = onCuePoint;
			netClient.onPlayStatus = onNsStatus;
			_netStream.client = netClient;
			
			_netStream.addEventListener(NetStatusEvent.NET_STATUS,onNetStateHandler);
		}
		private function initTime():void
		{
			_listenTimer=new Timer(100);
			_listenTimer.addEventListener(TimerEvent.TIMER,onTimerHandler);
		}
		private function initVideo():void
		{
			_video = new Video();				
			addChild(_video);  
			_video.attachNetStream(_netStream);
		}
		private function onConnectFailed():void
		{
			
		}
		private function onConnectClosed():void
		{
			
		}
		private function setSeeker(isFlv:Boolean):void
		{
			if(_seeker)
			{
				_seeker.dispose();
				_seeker=null;
			}
			
			if (isFlv)
			{
				_seeker=new FLVSkeer(_metaData,_netStream);
			}
			else
			{
				_seeker=new MP4Seeker(_metaData,_netStream);
			}
			_seeker.startParams=_startParams;
		}
		protected function onMetaData(metaData:Object):void
		{		
			if(isReady==false)
			{		
				_isReady=true;	
				volume=volume;
				_metaData=metaData;	

				if(_url.indexOf("http://")>-1)
				{
					if (metaData.keyframes)
					{
						_isHttpstream=true;
						setSeeker(true);
					}
					else if(metaData.seekpoints)
					{
						_isHttpstream=true;
						setSeeker(false);
					}
					else
					{
						_isHttpstream=false;
					}
					_isRtmpstream=false;
				}
				else if(_url.indexOf("rtmp://")>-1)
				{
					_isRtmpstream=true;
					_fmsServer=getFmsServerFromURL(_url)
					_isHttpstream=false;
				}	
				else
				{
					_isRtmpstream=false;
					_isHttpstream=false;
				}
				dispatchEvent(new MediaEvent(MediaEvent.READY));
			}
		}
		private function getFmsServerFromURL(url:String):String
		{
			var array:Array=url.split("/");
			return array[0]+"//"+array[2]+"/"+array[3];
		}
		protected function onCuePoint(cueData:Object):void
		{
			trace("onCuePoint");
		}
		protected function onNsStatus(stateData:Object):void
		{
			if (stateData.code == "NetStream.Play.Complete")
			{
				dispatchOnPlayStatusChange(PlayState.COMPLETE);
				return;
			}
			if(stateData.level.status&&stateData.level.status=="NetStream.Play.Complete")
			{
				dispatchOnPlayStatusChange(PlayState.COMPLETE);
				return;
			}
		}
		
		private function dispatchOnBufferStatusChange(status:uint,bufferPercent:Number=0):void
		{
			var param:Object=new Object();
			param.status=status;
			param.bufferPerceng=bufferPercent
			dispatchEvent(MediaEvent.BUFFER_STATUS_CHANGED,param);
		}
		private function dispatchOnPlayStatusChange(status:uint):void
		{
			var param:Object=new Object();
			param.status=status;
			dispatchEvent(MediaEvent.PLAY_STATUS_CHANGED,param);
		}
		private function dispatchOnTimeChange($time:Number,$duration:Number):void
		{
			var param:Object=new Object();
			param.time=$time;
			param.duration=$duration;
			dispatchEvent(MediaEvent.TIME_CHANGED,param);
		}
		protected function onTimerHandler(event:TimerEvent):void
		{
			if(isBuffering)
			{
				dispatchOnBufferStatusChange(BufferStatus.BUFFERING,bufferLoad);
			}
			else
			{
				if(playStatus==PlayState.PLAY)
				{
					dispatchOnTimeChange(time,duration)
				}
			}
		}
        private function getNumScale(strScale:String):Number
		{
			var array:Array=strScale.split(":");
			return Number(array[1])/Number(array[0]);
		}
		public function resizeVideo(areaWidth:Number,areaHeight:Number,scale:String=null):void
		{
			if(isReady)
			{
				_areaWidth=areaWidth;
				_areaHeight=areaHeight;
				
				var videoPer:Number
				if(scale)
				{
					videoPer=_metaData.width/(_metaData.width*getNumScale(scale));
				}
				else
				{
					videoPer=_metaData.width/_metaData.height;
				}
				var areaPer:Number=areaWidth/areaHeight;
				
				if (videoPer >= areaPer)
				{
					_video.height = areaHeight;
					_video.width = this.height/videoPer;
				}
				else
				{
					_video.width = areaWidth;
					_video.height = this.width*videoPer;
				}
			}
			else
			{
				trace("调用resizeVideo方法必须在Ready事件后")
			}
		}
		/**
		 * 
		 * @param tm单位为秒
		 * 
		 */
		public function seek(tm:Number):void
		{
			_isBuffering=true;
			_isSeeking=true;
			dispatchOnBufferStatusChange(BufferStatus.START);
			if(_isHttpstream)
			{
				_seeker.seek(tm,_url);
				_preTime=_seeker.seekTime*1000;
			}
			else
			{
				//非HTTP流
				var bufferedTime:Number = (_netStream.bytesLoaded / _netStream.bytesTotal) * duration;
				if (tm <= bufferedTime)
				{	
					tm=int(Math.min(tm,duration-1));
					_netStream.seek(tm);
					_preTime=tm*1000;
				}
				else
				{
					trace("还没加载到拖拽时间的位置");
				}
			}
		}
		/**
		 *视频完全终止，流停止 
		 * 
		 */
		public function stop():void
		{
			_listenTimer.reset();
			try
			{
				_netStream.close();
			} 
			catch(error:Error) 
			{
				
			}
		}
		public function clear():void
		{
			_video.clear()
		}
		/**
		 *能否拖拽至该时间 
		 * @param tm
		 * @return 
		 * 
		 */
		public function canSeekToTime(tm:Number):Boolean
		{
			if(_isHttpstream)
			{
				return _seeker.canSeekToTime(tm);
			}
			else
			{
				var bufferedTime:Number=_netStream.bytesLoaded/_netStream.bytesTotal;
				return tm<=bufferedTime;
			}
			return false;
		}
		/**
		 *播放 
		 * 
		 */
		public function play(url:String):void
		{
			if(url)//如果是播放新视频
			{
				_isReady=false;
				_metaData=null;
				_url=url;
				_preTime=0;
				_isBuffering=true;
				_netStream.play(_url);
				if(!_listenTimer.running)
				{
					_listenTimer.start();
				}
				dispatchOnBufferStatusChange(BufferStatus.START);
			}
			else//如果是从暂停恢复
			{
				_netStream.resume();
				
				if(_listenTimer.running==false)
				{
					_listenTimer.start();
				}
			}
		}
		/**
		 *暂停 
		 * 
		 */
		public function pause():void
		{
			_netStream.pause();
		}
		/**
		 *恢复播放 
		 * 
		 */
		public function resume():void{
			play();
		}
		/**
		 *获取视频总时长 
		 * @return 
		 * 
		 */
		public function get duration():Number
		{		
			if(_isHttpstream)
			{
				if(_seeker)
				{
					return _seeker.endTime;
				}
			}
			return _metaData.duration;
		}
		/**
		 *获取视频当前时间 
		 * @return 
		 * 
		 */
		public function get time():Number
		{
			var seekOff:Number=0;
			if(_seeker){
				seekOff=_seeker.seekTime;
			}
			var tm:Number=_netStream.time+seekOff;
			return Math.min(tm,duration);
		}
		public function get playStatus():uint
		{
			return _playStatus;
		}
		/**
		 *获取缓冲进度 
		 * @return 
		 * 
		 */
		public function get bufferLoad():Number
		{			
			return Math.min(_netStream.bufferLength/_netStream.bufferTime,1);
		}
		/**
		 *获取加载进度 
		 * @return 
		 * 
		 */
		public function get byteLoaded():Number
		{
			var seekOff:Number=0;
			if(_seeker)
			{
				seekOff=_seeker.seekBytes;
			}
			return Math.min((_netStream.bytesLoaded+seekOff)/_netStream.bytesTotal,1);
		}
		public function get isBuffering():Boolean
		{
			return _isBuffering
		}
		public function get isReady():Boolean
		{
			return _isReady;
		}
		
		public function get isSeeking():Boolean
		{
			return _isSeeking;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
			var soundtr:SoundTransform=new SoundTransform(_volume);
			_netStream.soundTransform=soundtr;
		}
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function set mute(value:Boolean):void
		{
			_mute = value;
		}
	}
}
