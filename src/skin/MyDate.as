package skin
{
	//import zhen.guo.yao.systems.MyShowMsg;
	
	public class MyDate 
	{
		/**
		 * 构造函数
		 */
		public function MyData() 
		{
			
		}
		
		/*-----------------------------------------------------------------------------------------------------------------------公开方法-----------------*/
		/**
		 * 获得经过格式化的时间
		 * @param	time 以毫秒为单位的时间
		 * @param	long 是否强制返回带小时的时间格式。默认如果不足1小时，则返回"00:00"形式
		 * @return  经过格式化的时间
		 */
		public static function getFormatTime(time:Number,long:Boolean=false):String
		{
			var f:String = "00:00:00";
			if (time >= 0)
			{
				time /= 1000;
				
				var h = int(time / 3600);
				var m = int((time - h * 3600) / 60);
				var s = int(time - h * 3600 - m * 60);
				if (h < 10)
				{
					h = "0" + h;
				}
				if (m < 10)
				{
					m = "0" + m;
				}
				if (s < 10)
				{
					s = "0" + s;
				}
				
				if (long || h != "00")
				{
					f = h + ":" + m + ":" + s;
				}
				else
				{
					f=m + ":" + s;
				}
			}
			else
			{
				//MyShowMsg.show(MyShowMsg.ERROR,"zhen.guo.yao.Date:"+"getFormatTime(time,long)","‘time’参数不能小于0")
			}
			
			return f;
		}
		public static function getRealTime(time:String):Number
		{
			var totalTime:Number = -1;
			var array:Array = time.split(":");
			var l:uint = array.length;
			if (l<=3&&l>=2)
			{
				if (l == 2)
				{
					array.unshift("0");
				}
				if (Number(array[1]) >= 60 ||Number(array[1]) < 0|| Number(array[2]) >= 60||Number(array[2]) < 0)
				{
					return -1;
				}
				else
				{
					totalTime = Number(array[0]) * 60 * 60 * 1000 + Number(array[1]) * 60 * 1000 + Number(array[2]) * 1000;
				}
			}
			return totalTime;
		}
	}
	
}