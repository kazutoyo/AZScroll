package com.landinggearup.azscroll
{
	public class AZListViewRowData extends Object
	{
		public var reusableIdentifier:String = "ListViewRowData2.general";
		
		protected var _rowHeight:int;
		
		public function AZListViewRowData()
		{
			super();
		}
		
		
		public final function get rowHeight():int{
			return _rowHeight;
		}
		
		public final function set rowHeight(value:int):void{
			_rowHeight = value;
		}
		
	}
}