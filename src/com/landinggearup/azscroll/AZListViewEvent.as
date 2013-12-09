package com.landinggearup.azscroll
{
	import flash.events.Event;
	
	public class AZListViewEvent extends Event
	{
		public static const LOAD_ROW:String = "com.landinggearup.azscroll.event.AZListViewEvent.loadRow";
		
		public var loadedRow:AZListViewRow;
		
		public function AZListViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}