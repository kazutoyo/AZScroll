package
{
	import com.landinggearup.azscroll.AZListViewRowData;
	
	public class MyListRowData extends AZListViewRowData
	{
		public var title:String;
		public var color:uint;
		
		public function MyListRowData()
		{
			super();
			_rowHeight = 60;
		}
	}
}