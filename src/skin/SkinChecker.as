package skin 
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	internal class SkinChecker 
	{
		
		public static  function check(mc:MovieClip):String
		{
			var controlBar = mc.getChildByName("controlBar");
			if (controlBar == null)
			{
				return "controlBar";
			}
			else
			{
				var playBtn = mc.controlBar.getChildByName("playBtn");
				if (playBtn == null)
				{
					return "controlBar.playBtn";
				}
				var pauseBtn = mc.controlBar.getChildByName("pauseBtn");
				if (pauseBtn == null)
				{
					return "controlBar.pauseBtn";
				}
				var progressBar = mc.controlBar.getChildByName("progressBar");
				if (progressBar == null)
				{
					return "controlBar.progressBar";
				}
				else
				{
					var progressBarBg = mc.controlBar.progressBar.getChildByName("progressBarBg");
					if (progressBarBg == null)
					{
						return "controlBar.progressBar.progressBarBg";
					}
					var followBar = mc.controlBar.progressBar.getChildByName("followBar");
					if (followBar == null)
					{
						return "controlBar.progressBar.followBar";
					}
					var loadingBar = mc.controlBar.progressBar.getChildByName("loadingBar");
					if (loadingBar == null)
					{
						return "controlBar.progressBar.loadingBar";
					}
					var block = mc.controlBar.progressBar.getChildByName("block");
					if (block == null)
					{
						return "controlBar.progressBar.block";
					}
				}
				var volBar = mc.controlBar.getChildByName("volBar");
				if (volBar == null)
				{
					return "controlBar.volBar";
				}
				else
				{
					var path = mc.controlBar.volBar.getChildByName("path");
					if (path == null)
					{
						return "controlBar.volBar.path";
					}
					var followBar = mc.controlBar.volBar.getChildByName("followBar");
					if (followBar == null)
					{
						return "controlBar.volBar.followBar";
					}
					var block = mc.controlBar.volBar.getChildByName("block");
					if (block == null)
					{
						return "controlBar.volBar.block";
					}
				}
				var volBtn = mc.controlBar.getChildByName("volBtn");
				if (volBtn == null)
				{
					return "controlBar.volBtn";
				}
				var fullscreenBtn = mc.controlBar.getChildByName("fullscreenBtn");
				if (fullscreenBtn == null)
				{
					return "controlBar.fullscreenBtn";
				}
				var time = mc.controlBar.getChildByName("time");
				if (time == null)
				{
					return "controlBar.time";
				}
				var alertMsg = mc.controlBar.getChildByName("alertMsg");
				if (alertMsg == null)
				{
					return "controlBar.alertMsg";
				}
				
			}
			return "";
		}
	}

}