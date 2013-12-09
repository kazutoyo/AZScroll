package com.landinggearup.azscroll
{
	
	/**
	 */
	
	public class AZSizeInt
	{
		
		public var width:int;
		public var height:int;
		
		public function AZSizeInt(w:int=0, h:int=0)
		{
			width = w;
			height = h;
		}
		
		public function toString():String{
			return "[object SizeInt] (width="+ width +", height="+ height +")";
		}
		
		public function clone():AZSizeInt{
			return new AZSizeInt(width, height);
		}
		
		public function isEqual(sz:AZSizeInt):Boolean{
			if(this == sz){
				return true;
			}
			return (sz.width == this.width && sz.height == this.height);
		}
		
	}
}