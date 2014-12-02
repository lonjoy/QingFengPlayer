package media
{
	import flash.net.NetStream;
	public class FLVSkeer extends Seeker
	{
		public function FLVSkeer(mdata:Object,stream:NetStream)
		{
			super(mdata,stream);
		}
		override protected function addMetaData(mdata:Object):void{
			times=mdata.keyframes.times;
			filepositions=mdata.keyframes.filepositions;
		}
		override public function seek(tm:Number,url:String):void{
			fileposition=getByteOffsetByTime(tm);
//			_seekBytes=fileposition;
			//getTimeOffsetByTime(tm);
			var url:String=getURL(url);
			netstream.play(url);
//			trace(url,fileposition);
		}
		override protected function getByteOffsetByTime(tm:Number):Number{
			for (var i:Number = 0; i < this.times.length - 1; i++)
			{ //通过循环比较，定位最接近关键帧
				if (this.times[i] <= tm && this.times[i + 1] > tm)
				{
					return filepositions[i];
				}
			}
			if(tm>=this.times[this.times.length-1]){
				return this.filepositions[this.times.length-2];
			}
			return 0;
		}
		override protected function getTimeOffsetByTime(tm:Number):Number{
			for (var i:Number = 0; i < this.times.length - 1; i++)
			{ //通过循环比较，定位最接近关键帧
				if (this.times[i] <= tm && this.times[i + 1] > tm)
				{
					return times[i];
				}
			}
			if(tm>=this.times[this.times.length-1]){
				return this.times[this.times.length-1];
			}
			return 0;
		}
		override public function canSeekToTime(tm:Number):Boolean{
			return tm<=this.times[this.times.length-1];
		}
		override public function get endTime():Number{
			return this.times[this.times.length-1];
		}
	}
}