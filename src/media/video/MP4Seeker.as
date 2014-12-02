package com.cdvcloud.xems.ve.player.psp
{
	//20142014-9-26上午11:07:37
	//奋斗 QQ:275522479
	import flash.net.NetStream;
	
	public class MP4Seeker extends Seeker
	{
		public function MP4Seeker(mdata:Object, stream:NetStream)
		{
			super(mdata, stream);
		}
		override protected function addMetaData(mdata:Object):void{
			times=mdata.seekpoints;
		}
		override public function seek(tm:Number,url:String):void{
			_seekBytes=getByteOffsetByTime(tm);
			_seekTime=getTimeOffsetByTime(tm);
			fileposition=_seekTime;
			var url:String=getURL(url);
			netstream.play(url);
//			trace(url,tm,fileposition);
		}
		override protected function getByteOffsetByTime(tm:Number):Number{
			for (var i:Number = 0; i < this.times.length - 1; i++)
			{ //通过循环比较，定位最接近关键帧
				if (this.times[i].time <= tm && this.times[i + 1].time > tm)
				{
					return this.times[i].offset;
				}
			}
			return 0;
		}
		override protected function getTimeOffsetByTime(tm:Number):Number{
			for (var i:Number = 0; i < this.times.length - 1; i++)
			{ //通过循环比较，定位最接近关键帧
				if (this.times[i].time <= tm && this.times[i + 1].time >= tm)
				{
					return times[i].time;
				}
			}
			if(tm>=this.times[this.times.length-1].time){
				return this.times[this.times.length-1].time;
			}
			return 0;
		}
		override public function canSeekToTime(tm:Number):Boolean{
			return tm<=this.times[this.times.length-1].time;
		}
		override public function get endTime():Number{
			return this.times[this.times.length-1].time;
		}
	}
}