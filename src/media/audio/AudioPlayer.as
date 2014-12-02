package com.cdvcloud.xems.ve.player.audio
{
	import com.cdvcloud.xems.ve.player.IPlayer;
	import media.MediaEvent;
	import media.PlayState;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	//20142014-9-28上午9:49:53
	//奋斗 QQ:275522479
	public class AudioPlayer extends Sprite implements IPlayer
	{
		private var sound:Sound;
		private var soundChannel:SoundChannel;
		
		private var _mute:Boolean=false;
		private var _volume:Number=1;
		private var _duration:Number=0;
		private var preTime:Number=0;
		private var listenTimer:Timer;
		private var _isReady:Boolean=false;
		protected var isPause:Boolean=false;
		public function AudioPlayer()
		{
			creatSound();
			
			listenTimer=new Timer(100);
			listenTimer.addEventListener(TimerEvent.TIMER,onTimerHandler);
		}	
		private function creatSound():void
		{
			if(sound)
			{
				sound.removeEventListener(Event.COMPLETE,soundDataLoadCompleted);
				sound.removeEventListener(IOErrorEvent.IO_ERROR,soundDataLoadErro);
				sound.removeEventListener(ProgressEvent.PROGRESS,soundDataLoadProgress);
				sound.removeEventListener(Event.OPEN,soundOpenHandler);
				sound.removeEventListener(Event.OPEN,soundDataLoadOpen);
			}
			sound=new Sound();
			sound.addEventListener(Event.COMPLETE,soundDataLoadCompleted);
			sound.addEventListener(IOErrorEvent.IO_ERROR,soundDataLoadErro);
			sound.addEventListener(ProgressEvent.PROGRESS,soundDataLoadProgress);
			sound.addEventListener(Event.OPEN,soundOpenHandler);
			sound.addEventListener(Event.OPEN,soundDataLoadOpen);
		}
		protected function onTimerHandler(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			if(duration>=0){
				if(isPause==false)
				{
					this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_TIME_CHANGED,{time:time,duration:duration}));
				}
			}
		}
		
		protected function soundDataLoadOpen(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function soundOpenHandler(event:Event):void
		{
			// TODO Auto-generated method stub
//			trace("aaaaaaaa",sound.length);
		}
		
		protected function soundDataLoadProgress(event:ProgressEvent):void
		{
			// TODO Auto-generated method stub
		}
		
		/**
		 *声音加载错误 
		 * @param event
		 * 
		 */
		protected function soundDataLoadErro(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PLAY_ERRO}));
		}		
		/**
		 *声音数据加载完成时执行 
		 * @param event
		 * 
		 */
		protected function soundDataLoadCompleted(event:Event):void
		{
			// TODO Auto-generated method stub
			_isReady=true;
			if(isPause==false){
				play();
			}
			
		}
		public function load(url:String):void{
			_isReady=false;
			
			creatSound();
			
			sound.load(new URLRequest(url));
		}
		public function play():void{
			if(soundChannel){
				soundChannel.stop();
			}
			try
			{
				soundChannel=sound.play(preTime);	
			}
			catch(err:Error)
			{
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PLAY_ERRO}));
				return;
			}
			if(soundChannel.hasEventListener(Event.SOUND_COMPLETE)==false){
				soundChannel.addEventListener(Event.SOUND_COMPLETE,soundPlayCompleted);
			}
			volume=volume;
			if(!listenTimer.running){
				listenTimer.start();
			}
			isPause=false;
			
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PLAY}));
		}
		
		protected function soundPlayCompleted(event:Event):void
		{
			// TODO Auto-generated method stub
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_COMPLETE}));
		}
		public function resume():void{
			play();
		}
		public function pause():void{
			if(soundChannel){
				preTime=soundChannel.position;
				soundChannel.stop();
			}			
			isPause=true;
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_PAUSE}));
		}
		public function seek(tm:Number):void{
			if(canSeekToTime(tm)){
				preTime=tm;
				play();
				if(tm>=duration){
					this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_PLAY_STATE_CHANGED,{state:PlayState.MEDIA_COMPLETE}));
					
				}
				
			}
			else
			{
				trace("can not seek")
			}
		}
		/**
		 *终止播放，时间会归零，跟暂停不同 
		 * 加载也会终止
		 * 
		 */
		public function stop():void{
			if(listenTimer.running){
				listenTimer.stop();
			}
			try
			{
				soundChannel.stop();
			} 
			catch(error:Error) 
			{
				
			}
			try
			{
				sound.close();
			} 
			catch(error:Error) 
			{
				
			}
		}
		public function clear():void
		{
			
		}
		public function get time():Number{
			if(soundChannel)
			{
				return soundChannel.position;
			}
			return 0
		}
		public function get duration():Number{
			_duration=0;
			if(sound){
				_duration=sound.length;
			}
			return _duration;
		}
		public function get isReady():Boolean{
			return true;
		}
		public function get isSeeking():Boolean{
			return true;
		}
		public function get byteLoaded():Number{
			return sound.bytesLoaded/sound.bytesTotal;
		}
		public function get bufferLoad():Number{
			return 1;
		}
		public function canSeekToTime(tm:Number):Boolean{
			var bufferedTime:Number=sound.bytesLoaded/sound.bytesTotal*sound.length;
			return tm<=bufferedTime;
		}
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;			
			if(mute){
				mute=mute;
				return;
			}else{
				var soundTr:SoundTransform=new SoundTransform();
				soundTr.volume=_volume;
				if(soundChannel){
					soundChannel.soundTransform=soundTr;
				}
			}
			
		}
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function set mute(value:Boolean):void
		{
			_mute = value;
			var soundTr:SoundTransform=new SoundTransform(1);
			if(value){
				soundTr.volume=0;
			}else{
				soundTr.volume=_volume;
			}
			if(soundChannel){
				soundChannel.soundTransform=soundTr;
			}
		}
	}
}