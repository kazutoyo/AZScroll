package
{
	import com.landinggearup.azscroll.AZListView;
	import com.landinggearup.azscroll.AZListViewRowData;
	import com.landinggearup.azscroll.AZScrollView;
	import com.landinggearup.azscroll.AZSizeInt;
	
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	import avmplus.getQualifiedClassName;
	
	public class AZScroll extends Sprite
	{
		private var _scrollView:AZScrollView;
		private var _listView:AZListView;
		
		private var ferrariLoader:Loader;
		
		public function AZScroll()
		{
			super();
			
			trace("Note: The device's screen must be at least 400x600 for the testing.");
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.color = 0;
			
			graphics.beginFill(0xdddddd, 1);
			graphics.drawRect(0, 0, 400, 600);
			graphics.endFill();
			
			var txt:TextField;
			
			var sp1:Sprite = new Sprite();
			sp1.graphics.beginFill(0x666666, 1);
			sp1.graphics.drawRoundRect(0, 0, 100, 40, 10, 10);
			sp1.graphics.endFill();
			txt = new TextField();
			txt.mouseEnabled = false;
			txt.textColor = 0xff0000;
			txt.text = "AZScrollView";
			txt.x = txt.y = 10;
			txt.width = 90;
			sp1.addChild(txt);
			
			var sp2:Sprite = new Sprite();
			sp2.graphics.beginFill(0x444444, 1);
			sp2.graphics.drawRoundRect(0, 0, 100, 40, 10, 10);
			sp2.graphics.endFill();
			txt = new TextField();
			txt.mouseEnabled = false;
			txt.textColor = 0xff0000;
			txt.text = "AZScrollView";
			txt.x = txt.y = 10;
			txt.width = 90;
			sp2.addChild(txt);
			
			var btn1:SimpleButton = new SimpleButton(sp1, sp1, sp2, sp2);
			addChild(btn1);
			
			
			sp1 = new Sprite();
			sp1.graphics.beginFill(0x666666, 1);
			sp1.graphics.drawRoundRect(0, 0, 100, 40, 10, 10);
			sp1.graphics.endFill();
			txt = new TextField();
			txt.mouseEnabled = false;
			txt.textColor = 0x00ff00;
			txt.text = "AZListView";
			txt.x = txt.y = 10;
			txt.width = 90;
			sp1.addChild(txt);
			
			sp2 = new Sprite();
			sp2.graphics.beginFill(0x444444, 1);
			sp2.graphics.drawRoundRect(0, 0, 100, 40, 10, 10);
			sp2.graphics.endFill();
			txt = new TextField();
			txt.mouseEnabled = false;
			txt.textColor = 0x00ff00;
			txt.text = "AZListView";
			txt.x = txt.y = 10;
			txt.width = 90;
			sp2.addChild(txt);
			
			var btn2:SimpleButton = new SimpleButton(sp1, sp1, sp2, sp2);
			addChild(btn2);
			
			btn1.x = btn1.y = 10;
			btn2.x = btn1.x + btn1.width + 15;
			btn2.y = 10;
			
			btn1.addEventListener(MouseEvent.CLICK, toggle1, false, 0, true);
			btn2.addEventListener(MouseEvent.CLICK, toggle2, false, 0, true);
			
			this.createScrollView();
			this.createListView();
			
			this.toggle(1);
		}
		
		private function toggle1(e:MouseEvent):void{
			this.toggle(1);
		}
		private function toggle2(e:MouseEvent):void{
			this.toggle(2);
		}
		
		private function toggle(t:int):void{
			_scrollView.visible = t == 1;
			_listView.visible = t != 1;
		}
		
		
		/**
		 * This function show how to use the AZScrollView
		 */
		private function createScrollView():void{
			_scrollView = new AZScrollView();
			_scrollView.x = 10;
			_scrollView.y = 70;
			_scrollView.viewportSize = new AZSizeInt(380, 500);
			_scrollView.showVerticalScrollBar = false;
			ferrariLoader = new Loader();
			ferrariLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadFerrariComplete, false, 0, true);
			ferrariLoader.load(new URLRequest("ferrari.jpg"));
			_scrollView.addChild(ferrariLoader);
			addChild(_scrollView);
		}
		
		private function onLoadFerrariComplete(e:Event):void{
			_scrollView.contentSize = new AZSizeInt(ferrariLoader.width, ferrariLoader.height);
		}
		
		
		/**
		 * This function show how to use the AZListView
		 */
		private function createListView():void{
			_listView = new AZListView();
			_listView.x = 10;
			_listView.y = 70;
			_listView.viewportSize = new AZSizeInt(380, 500);
			addChild(_listView);
			
			var data:Vector.<AZListViewRowData> = new Vector.<AZListViewRowData>();
			for(var i:int=1; i<=200; i++){
				var dt:MyListRowData = new MyListRowData();
				dt.title = "Row - "+ i;
				dt.color = (i / 220) * 0xaaaaaa + 0x222222;
				data.push(dt);
			}
			_listView.rowQualifiedClassName = getQualifiedClassName(MyListRow);
			_listView.dataProvider = data;
		}
		
	}
}