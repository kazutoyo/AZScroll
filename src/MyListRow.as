package
{
	import com.landinggearup.azscroll.AZListViewRow;
	import com.landinggearup.azscroll.AZListViewRowData;
	
	import flash.text.TextField;
	
	public class MyListRow extends AZListViewRow
	{
		private var titleField:TextField;
		
		public function MyListRow()
		{
			super();
			titleField = new TextField();
			titleField.x = titleField.y = 10;
			titleField.textColor = 0xffffff;
			addChild(titleField);
		}
		
		override public function set data(value:AZListViewRowData):void{
			super.data = value;
			
			
			graphics.clear();
			graphics.beginFill((value as MyListRowData).color, 1);
			graphics.drawRoundRect(0, 0, 373, 60, 10, 10);
			graphics.endFill();
			
			titleField.text = (value as MyListRowData).title;
		}
	}
}