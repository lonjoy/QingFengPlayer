package com.cdvcloud.xems.ve.player.psp
{
	//20142014-9-25上午10:50:22
	//奋斗 QQ:275522479
	//该播放器支持HTTP伪流，本地视频，支持格式MP4,FLV，伪流拖拽参数默认为start，需要修改时请设置
	import com.cdvcloud.xems.ve.player.IPlayer;
	
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
	import media.PlayState;
	import media.MediaEvent;
	
	public class PSVideo extends Sprite implements IPlayer
	{
		private var video:*;
		private var netConnection:NetConnection; //视频链接对象
		protected var netStream:NetStream; //主要的视频流加载
		private var size:Point;
		private var bufferTime:Number=0.1;
		private var videoStage:Stage;
		private var _bgColor:int=0x0;
		private var _resizeMode:String="all";
		private var _startParams:String="start";
		private var _url:String;
		protected var isPause:Boolean=false;
		
		
		private var _isReady:Boolean=false;
		private var metaData:Object=null;
		private var isHttpstream:Boolean=false;
		private var seeker:Seeker;
		private var listenTimer:Timer;
		
		private var preTime:Number=0;
		private var seekToTime:Number=-1;
		private var isBuffer:Boolean=false;
		
		private var _mute:Boolean=false;
		private var _volume:Number=1;
		private var _isSeeking:Boolean=false;
		
		public function PSVideo(stage:Stage=null,bufferTime:Number=0.1,bgColor:int=0x0)
		{
			this.videoStage=stage;
			this.bufferTime=bufferTime;
			this.bgColor=bgColor;
			setSize(320,240);
			initVideo();
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
			netStream.soundTransform=soundtr;
		}

		public function get mute():Boolean
		{
			return _mute;
		}

		public function set mute(value:Boolean):void
		{
			_mute = value;
		}

		public function get startParams():String
		{
			return _startParams;
		}

		public function set startParams(value:String):void
		{
			_startParams = value;
			if(seeker){
				seeker.startParams=value;
			}
		}

		override public function set width(value:Number):void{
			super.width=value;
			throw new Error("请使用setSize设置");
		}
		override public function set height(value:Number):void{
			super.height=value;
			throw new Error("请使用setSize设置");
		}
		/**
		 *设置显示的缩放模式，默认情况是直接变形适配宽高，要传自动一缩放比例时请传"宽度_高度",如4_3 
		 * @param value
		 * 
		 */
		public function set resizeMode(value:String):void
		{
			_resizeMode = value;
		}

		
		/**
		 *播放新的视频 
		 * @param url
		 * 
		 */
		public function load(url:String):void{
			_isReady=false;
			metaData=null;
			_url=url;
			preTime=0;
			isBuffer=true;
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_BUFFER_CHANGED,{state:PlayState.MEDIA_BUFFER_START}));
			netStream.play(_url);
			if(!listenTimer.running){
				listenTimer.start();
			}
		}
		/**
		 * 
		 * @param tm单位为秒
		 * 
		 */
		public function seek(tm:Number):void{
			isBuffer=true;
			_isSeeking=true;
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_BUFFER_CHANGED,{state:PlayState.MEDIA_BUFFER_START}));
			if(isHttpstream){
				seeker.seek(tm,_url);
				preTime=seeker.seekTime*1000;
			}else{
				//非HTTP流
				var bufferedTime:Number = (netStream.bytesLoaded / netStream.bytesTotal) * duration;
				if (tm <= bufferedTime)
				{	
					tm=int(Math.min(tm,duration-1));
					netStream.seek(tm);
					preTime=tm*1000;
				}else{
					trace("还没加载到拖拽时间的位置");
				}
			}
		}
		/**
		 *视频完全终止，流停止 
		 * 
		 */
		public function stop():void{
			if(listenTimer.running){
				listenTimer.stop();
			}
			try
			{
				netStream.close();
			} 
			catch(error:Error) 
			{
				
			}
		}
		public function clear():void
		{
			if(this.video is Video)
			{
				Video(this.video).clear();
			}else
			{
					
			}
		}
		/**
		 *能否拖拽至该时间 
		 * @param tm
		 * @return 
		 * 
		 */
		public function canSeekToTime(tm:Number):Boolean{
			if(isHttpstream){
				return seeker.canSeekToTime(tm);
			}else{
				var bufferedTime:Number=netStream.bytesLoaded/netStream.bytesTotal;
				return tm<=bufferedTime;
			}
			return false;
		}
		/**
		 *播放 
		 * 
		 */
		public function play():void{
			isPause=false;
			netStream.resume();
			
			if(listenTimer.running==false)
			{
				listenTimer.start();
			}
		}
		/**
		 *暂停 
		 * 
		 */
		public function pause():void{
			isPause=true;
			netStream.pause();
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
		public function get duration():Number{		
			if(isHttpstream){
				if(seeker){
					return seeker.endTime;
				}
			}
			return metaData.duration;
		}
		/**
		 *获取视频当前时间 
		 * @return 
		 * 
		 */
		public function get time():Number{
			var seekOff:Number=0;
			if(seeker){
				seekOff=seeker.seekTime;
			}
			var tm:Number=netStream.time+seekOff;
			return Math.min(tm,duration)*1000;
		}
		/**
		 *获取缓冲进度 
		 * @return 
		 * 
		 */
		public function get bufferLoad():Number{			
			return Math.min(netStream.bufferLength/netStream.bufferTime,1);
		}
		/**
		 *获取加载进度 
		 * @return 
		 * 
		 */
		public function get byteLoaded():Number{
			var seekOff:Number=0;
			if(seeker){
				seekOff=seeker.seekBytes;
			}
			return Math.min((netStream.bytesLoaded+seekOff)/netStream.bytesTotal,1);
		}
		/**
		 *设置背景颜色 
		 * @param value
		 * 
		 */
		public function set bgColor(value:int):void
		{
			_bgColor = value;
		}
		
		/**
		 *设置Box规格 
		 * @param width
		 * @param height
		 * 
		 */
		public function setSize(width:int=320, height:int=240):void{
			size=new Point(width,height);
			if(this.metaData){
				resizeVideo();
			}
			drawBackgroundColor();
		}
		
		/**
		 *判断视频是否支持硬件加速 
		 * @param event
		 * 
		 */
		protected function onStageVideoState(event:StageVideoAvailabilityEvent):void
		{
			this.videoStage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY,onStageVideoState);
			if(event.availability==StageVideoAvailability.AVAILABLE){
				video=this.videoStage.stageVideos[0];
				video.viewPort = new Rectangle(0,0,size.x,size.y);
				video.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoChanged);
			}else{
				video = new Video();				
				addChild(video);  
			}
			video.attachNetStream(netStream);
		}
		/**
		 *硬件加速 
		 * @param e
		 * 
		 */
		protected function onStageVideoChanged(e:StageVideoEvent):void{
			//trace(e.status);
		}
		
		protected function resizeVideo():void{
			var mode:String=this._resizeMode;
			var w:Number=metaData.width;
			var h:Number=metaData.height;

			var np:Point;
			if(mode==ResizeMode.SHOW_ALL){
//				np=ResizeFit.resizeInBox(new Point(w,h),this.size);
				setVideoSize(this.size.x,this.size.y);
			}else{
				var ratio:Number=getRatio();
				h=w*ratio;
				np=ResizeFit.resizeInBox(new Point(w,h),this.size);
				setVideoSize(np.x,np.y);
			}
		}
		protected function getRatio():Number{
			var arr:Array=this._resizeMode.split("_");
			var a:Number=parseFloat(arr[0]);
			var b:Number=parseFloat(arr[1]);
			return b/a;
		}
		protected function setVideoSize(w:Number,h:Number):void{
			if(this.video is Video){
				this.video.width=w;
				this.video.height=h;	
				this.video.x=(this.size.x-this.video.width)/2;
			    this.video.y=(this.size.y-this.video.height)/2;
				
			}else{
				/*var xx=(this.size.x-w)/2;
				var yy=(this.size.y-h)/2;
				video.viewPort = new Rectangle(xx,yy,w,h);*/
			}
			
		}
		protected function onMetaData(metaData:Object):void{		
			if(isReady==false){		
				_isReady=true;		
				if(seeker){
					seeker.dispose();
					seeker=null;
				}
				volume=volume;
				this.metaData=metaData;	
				if(_url.indexOf("http://")>-1){
					if (metaData.keyframes){
						isHttpstream=true;
						seeker=new FLVSkeer(metaData,netStream);
						startParams=startParams;
					}else if(metaData.seekpoints){
						isHttpstream=true;
						seeker=new MP4Seeker(metaData,netStream);
						startParams=startParams;
					}else{
						isHttpstream=false;
					}
				}else{
					isHttpstream=false;
				}	
				
				//resizeVideo();
				
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_READY,null));
			}
		}
		protected function onCuePoint(cueData:Object):void{
			trace("onCuePoint");
		}
		protected function onNsStatus(stateData:Object):void{
			//trace("onNsStatus",stateData.code);
			if (stateData.code == "NetStream.Play.Complete")
			{
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_COMPLETE}));
				return;
			}
			if(stateData.level.status&&stateData.level.status=="NetStream.Play.Complete"){
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_COMPLETE}));
			}
		}
		private function initVideo():void
		{
			// TODO Auto Generated method stub                  
			netConnection = new NetConnection();
			netConnection.connect(null)
			netStream = new NetStream(netConnection);
			netStream.bufferTime=this.bufferTime;
			
			var netClient:Object=new Object();
			netClient.onMetaData = onMetaData;
			netClient.onCuePoint = onCuePoint;
			netClient.onPlayStatus = onNsStatus;
			netStream.client = netClient;
			netStream.addEventListener(NetStatusEvent.NET_STATUS,onNetStateHandler);
			netConnection.addEventListener(NetStatusEvent.NET_STATUS,onNetStateHandler);
			
			listenTimer=new Timer(100);
			listenTimer.addEventListener(TimerEvent.TIMER,onTimerHandler);
			
			
			//当传入stage时则开启支持硬件加速
//			if(this.videoStage){
//				this.videoStage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY,onStageVideoState);
//			}else{
				video = new Video();				
				addChild(video);  
				video.attachNetStream(netStream);
//			}
			
		}
		
		protected function onTimerHandler(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			if(isReady&&isBuffer==false){
				if(preTime!=time){
					if(isPause){
						//this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_TIME_CHANGED,{time:time,duration:duration}));
					}else{
						//if(time>=preTime){		
							this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_TIME_CHANGED,{time:time,duration:duration}));							
						//}
					}					
				}
			}
			if(isBuffer){
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_BUFFER_CHANGED,{state:PlayState.MEDIA_BUFFER_ING,bufferLoad:bufferLoad}));
			}
		}
		protected function onNetStateHandler(event:NetStatusEvent):void{
			if(event.target==netStream){  
				//trace("=======================================event.info.code",event.info.code);
				switch(event.info.code){
					case "NetStream.Unpause.Notify":
						this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PLAY}));
						break;
					case "NetStream.Pause.Notify":
						this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PAUSE}));
						break;
					case "NetStream.Play.StreamNotFound":
						this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PLAY_ERRO}));
						break;
					case "NetStream.Buffer.Full":
						isBuffer=false;
						_isSeeking=false;
						this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_BUFFER_CHANGED,{state:PlayState.MEDIA_BUFFER_END}));
						break;
				}
			}else{
				trace("netConnection");
			}
		}
		
		private function drawBackgroundColor():void{
			if(this.video is StageVideo){
				///当是硬件加速时则绘制背景不起作用,因为StageVideo只能在最底层
				return;
			}
			this.graphics.clear();
			this.graphics.beginFill(_bgColor);
			this.graphics.drawRect(0,0,size.x,size.y);
			this.graphics.endFill();
		}
	}
	
}
import flash.geom.Point;
class ResizeFit{
	public static function resizeInBox(displaySize:Point,boxSize:Point):Point{
		var w:Number=displaySize.x;
		var h:Number=displaySize.y;
		var sw:Number=boxSize.x;
		var sh:Number=boxSize.y;
		var ssw:Number=sw;
		var ssh:Number=sh;
		if((w/h)>(sw/sh)){
			ssh=(ssw/(w/h));
		}else{
			ssw=((ssh*w)/h);
		}
		return new Point(ssw,ssh);
	}
}
