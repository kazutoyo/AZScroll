package com.landinggearup.azscroll
{
	import flash.display.Sprite;
	
	public class AZListViewRow extends Sprite
	{
		public var rowIndex:int = -1;
		
		protected var _data:AZListViewRowData;
		
		public function AZListViewRow()
		{
			super();
		}
		
		public function release():void{
			
		}
		
		/**
		 * Override must call super
		 */
		public function set data(value:AZListViewRowData):void{
			_data = value;
		}
		public final function get data():AZListViewRowData{
			return _data;
		}
		
	}
}