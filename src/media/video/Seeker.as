package com.cdvcloud.xems.ve.player.psp
{
	import flash.net.NetStream;

	//20142014-9-25下午3:08:03
	//奋斗 QQ:275522479
	public class Seeker
	{
		protected var times:Array=null;
		protected var filepositions:Array=null;
		protected var _seekTime:Number=0;
		protected var _seekBytes:Number=0;
		protected var netstream:NetStream;
		protected var fileSeekOff:Number=0;
		protected var fileposition:Number=0;
		private var _startParams:String="start";
		private var _endTime:Number=0;
		
		public function Seeker(mdata:Object,stream:NetStream)
		{
			this.netstream=stream;
			addMetaData(mdata);
		}

		public function get endTime():Number
		{
			return _endTime;
		}

		public function get seekBytes():Number
		{
			return _seekBytes;
		}

		public function get startParams():String
		{
			return _startParams;
		}

		public function set startParams(value:String):void
		{
			_startParams = value;
		}

		public function get seekTime():Number
		{
			return _seekTime;
		}

		protected function addMetaData(mdata:Object):void{
			
		}
		public function seek(tm:Number,url:String):void{
			
			
		}
		/** 为URL添加参数**/
		protected function getURLConcat(url:String, prm:String, val:*):String
		{
			if (url.indexOf('?') > -1)
			{
				return url + '&' + prm + '=' + val;
			}
			else
			{
				return url + '?' + prm + '=' + val;
			}
		}
		/**  创建视频播放URL **/
		protected function getURL(url:String):String
		{
			var startparam:String = this.startParams;
			if (fileposition > 0)
			{
				url = getURLConcat(url, startparam, fileposition);
			}
			return url;
		}
		protected function getByteOffsetByTime(tm:Number):Number{
			
			return 0;
		}
		protected function getTimeOffsetByTime(tm:Number):Number{
			return 0;
		}
		public function canSeekToTime(tm:Number):Boolean{
			
			return false;
		}
		public function dispose():void{
			times=null;
			filepositions=null;
		}
	}
}