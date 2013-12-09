package com.landinggearup.azscroll
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class AZListView extends AZScrollView
	{
		private var _isHorizontal:Boolean;
		
		private var _rowQualifiedClassName:String;
		private var _rowQualifiedClass:Class;
		private var _dataProvider:Vector.<AZListViewRowData>;
		
		/**
		 * rows' count
		 */
		private var rowCountCache:int;
		
		/**
		 * every rows' height
		 */
		private var rowHeightsCache:Vector.<int>;	// index(int) => int
		
		/**
		 * this height is the summation of the height of all the rows before it and inclue it.
		 */
		private var totalRowHeightsCache:Vector.<int>;	// index(int) => int
		
		private var displayingRowsCache:Dictionary;	// index(int) => ListViewRow2
		private var unusedRowsCache:Dictionary;	// reusableIdentifer => Vector.<ListViewRow2>
		
		/**
		 * If the scroll rect not change, will not loadRows, for performance consideration
		 */
		private var lastScrollRectPos:Number = -1000;
		private var lastStartRowIndex:int = -100;
		private var lastEndRowIndex:int = -100;
		
		/**
		 * force to load the rows currently displaying, regardless of any situation
		 */
		private var forceLoadRowsForOneTime:Boolean = false;
		
		/**
		 * When calling reloadRowAtIndex(rowIndex), enqueue the rowIndex to this vector,
		 * so that in the next time load the row with that index,
		 * call the set data regardless of the data is changed.
		 */
		private var forceReloadRowIndexesForOneTime:Vector.<int>;
		
		/**
		 * when loading a row, animate the rows' positions:
		 */
		private var forceAnimatePositionLoadForOneTime:Boolean;
		
		/**
		 * In normal status, the displaying rows' position will not updated when loadRows(),
		 * set this var to true will force those rows' position been updated.
		 */
		private var forceUpdateDisplayingRowsPostionForOneTime:Boolean;
		
		
		/**
		 * Usage:
		 * 1, new
		 * 2, set viewPortSize
		 * 3, set rowQualifiedClassName
		 * 4, set dataProvider
		 */
		public function AZListView(isHorizontal:Boolean=false)
		{
			super();
			
			_isHorizontal = isHorizontal;
			
			this.bounceHorizontal = _isHorizontal;
			this.bounceVertical = ! _isHorizontal;
			
			this.showVerticalScrollBar = ! _isHorizontal;
			
			rowHeightsCache = new Vector.<int>();
			totalRowHeightsCache = new Vector.<int>();
			
			displayingRowsCache = new Dictionary();
			unusedRowsCache = new Dictionary();
			
			forceLoadRowsForOneTime = false;
			forceReloadRowIndexesForOneTime = new Vector.<int>();
			forceAnimatePositionLoadForOneTime = false;
			forceUpdateDisplayingRowsPostionForOneTime = false;
		}
		
		override public function release():void{
			this.clean();
			
			super.release();
		}
		
		
		public final function set rowQualifiedClassName(value:String):void{
			_rowQualifiedClassName = value;
			_rowQualifiedClass = getDefinitionByName(_rowQualifiedClassName) as Class;
			if(! _rowQualifiedClass){
				trace("unable to getDefinitionByName for: "+ _rowQualifiedClassName);
			}
		}
		
		
		public final function set dataProvider(value:Vector.<AZListViewRowData>):void{
			_dataProvider = value;
			
			rowHeightsCache.splice(0, rowHeightsCache.length);
			
			rowCountCache = _dataProvider.length;
			
			var i:int;
			for(i=0; i<rowCountCache; i++){
				var dt:AZListViewRowData = _dataProvider[i];
				var rh:int = dt.rowHeight;
				rowHeightsCache.push(rh);
			}
			
			this.reCalcTotalRowHeightCache();
			
			this.reloadData();
		}
		
		public final function get dataProvider():Vector.<AZListViewRowData>{
			return _dataProvider;
		}
		
		
		
		private function clean():void{
			var i:int = 0;
			for(i in displayingRowsCache){
				var row:AZListViewRow = displayingRowsCache[i];
				row.parent.removeChild(row);
				row.release();
				delete displayingRowsCache[i];
			}
			for(var k:* in unusedRowsCache){
				delete unusedRowsCache[k];
			}
		}
		
		
		private function adjustContentSize(animated:Boolean=false):void{
			if(rowCountCache <= 0){
				this.contentSize = new AZSizeInt();
			}else{
				var r:AZSizeInt = this.contentSize.clone();
				if(_isHorizontal){
					r.width = totalRowHeightsCache[rowCountCache - 1];
				}else{
					r.height = totalRowHeightsCache[rowCountCache - 1];
				}
				this.setContentSizeWithAdjustment(r, animated);
			}
		}
		
		
		public final function reloadData():void{
			this.clean();
			
			this.adjustContentSize();
			
			this.contentOffset = new AZSizeInt();
			
			forceLoadRowsForOneTime = true;
		}
		
		
		
		public final function positionOfRow(rowIndex:int):int{
			if(rowIndex <= 0){
				return 0;
			}
			var totalHeight:int = totalRowHeightsCache[rowIndex] - rowHeightsCache[rowIndex];
			return totalHeight;
		}
		
		public final function rectangleOfRow(rowIndex:int):Rectangle{
			var r:Rectangle = new Rectangle();
			
			if(_isHorizontal){
				r.x = this.positionOfRow(rowIndex);
				r.y = 0;
				r.width = rowHeightsCache[rowIndex];
				r.height = this.viewportSize.height;
			}else{
				r.x = 0;
				r.y = this.positionOfRow(rowIndex);
				r.width = this.viewportSize.width;
				r.height = rowHeightsCache[rowIndex];
			}
			
			return r;
		}
		
		public final function rowIndexOfPosition(val:Number):int{
			var rowIndex:int = rowCountCache - 1;
			
			var i:int = 0;
			for(i=0; i<rowCountCache; i++){
				var totalHeight:int = totalRowHeightsCache[i];
				if(totalHeight >= val){
					rowIndex = i;
					break;
				}
			}
			
			return rowIndex;
		}
		
		public final function rowAtIndex(rowIndex:int):AZListViewRow{
			return displayingRowsCache[rowIndex];
		}
		
		public final function rowForData(data:AZListViewRowData):AZListViewRow{
			var i:int;
			for(i=0; i<_dataProvider.length; i++){
				if(_dataProvider[i] == data){
					break;
				}
			}
			return this.rowAtIndex(i);
		}
		
		/**
		 * 滚动到某行。
		 * @param rowIndex 行号，从0开始
		 * @param animated 是否显示动画
		 */
		public function scrollToRow(rowIndex:int, animated:Boolean=false):void{
			var pos:int = this.positionOfRow(rowIndex);
			var sz:AZSizeInt = this.contentOffset.clone();
			if(_isHorizontal){
				sz.width = - pos;
			}else{
				sz.height = - pos;
			}
			this.setContentOffsetWithAdjustment(sz, animated);
		}
		
		public function changeRowHeight(rowIndex:int, newHeight:int, animated:Boolean = true, onComplete:Function = null):void{
			var oldHeight:int = _dataProvider[rowIndex].rowHeight;
			_dataProvider[rowIndex].rowHeight = newHeight;
			rowHeightsCache[rowIndex] = newHeight;
			this.reCalcTotalRowHeightCache();
			
			this.adjustContentSize(animated);
			
			this.moveAllDisplayingRowCacheToUnused();
			forceLoadRowsForOneTime = true;
			forceUpdateDisplayingRowsPostionForOneTime = true;
			forceAnimatePositionLoadForOneTime = animated;
			
			this.loadRows();
			
			if(onComplete){
				var delay:int = 0;
				if(animated){
					delay = AZScrollView.ScrollViewAnimationDurationMilliSec + 1000 / stage.frameRate + 1;
				}
				TweenLite.delayedCall(delay / 1000, onComplete);
			}
			
		}
		
		public function insertRowAtIndex(data:AZListViewRowData, rowIndex:int):void{
			_dataProvider.splice(rowIndex, 0, data);
			rowHeightsCache.splice(rowIndex, 0, data.rowHeight);
			rowCountCache ++;
			this.reCalcTotalRowHeightCache();
			
			this.adjustContentSize();
			
			this.moveAllDisplayingRowCacheToUnused();
			forceLoadRowsForOneTime = true;
			
			this.loadRows();
		}
		
		public function removeRowAtIndex(rowIndex:int):void{
			_dataProvider.splice(rowIndex, 1);
			rowHeightsCache.splice(rowIndex, 1);
			rowCountCache --;
			this.reCalcTotalRowHeightCache();
			
			this.adjustContentSize();
			
			this.moveAllDisplayingRowCacheToUnused();
			forceLoadRowsForOneTime = true;
			
			this.loadRows();
		}
		
		/**
		 * NOTE: reloadRowAtIndex doesn't handle the row height change.
		 */
		public function reloadRowAtIndex(rowIndex:int):void{
			forceLoadRowsForOneTime = true;
			if(forceReloadRowIndexesForOneTime.indexOf(rowIndex) < 0){
				forceReloadRowIndexesForOneTime.push(rowIndex);
			}
			
			this.loadRows();
		}
		
		
		
		private function moveAllDisplayingRowCacheToUnused():void{
			var i:int;
			for(i in displayingRowsCache){
				var row:AZListViewRow = displayingRowsCache[i];
				row.visible = false;
				
				var unused:Vector.<AZListViewRow> = unusedRowsCache[row.data.reusableIdentifier];
				if(! unused){
					unused = new Vector.<AZListViewRow>();
					unusedRowsCache[row.data.reusableIdentifier] = unused;
				}
				
				unused.push(row);
				delete displayingRowsCache[i];
			}
		}
		
		
		/**
		 * rowCountCache and rowHeightsCache must be ready before calling thie method
		 */
		private function reCalcTotalRowHeightCache():void{
			totalRowHeightsCache.splice(0, totalRowHeightsCache.length);
			
			var totalRowHeight:int = 0;
			
			var i:int;
			
			for(i=0; i<rowCountCache; i++){
				totalRowHeight += rowHeightsCache[i];
				totalRowHeightsCache.push(totalRowHeight);
			}
		}
		
		
		
		private function loadRowAtIndex(rowIndex:int):AZListViewRow{
			var rowDt:AZListViewRowData = _dataProvider[rowIndex];
			
			var newlyRow:AZListViewRow = null;
			
			var isNewlyCreate:Boolean = false;
			
			var unused:Vector.<AZListViewRow> = unusedRowsCache[rowDt.reusableIdentifier];
			
			if(unused && unused.length > 0){
				// try to find the old row with the same data and others first:
				for(var i:int=0; i<unused.length; i++){
					var r:AZListViewRow = unused[i];
					if(r.rowIndex == rowIndex){
						newlyRow = r;
						unused.splice(i, 1);
						break;
					}
				}
				if(! newlyRow){
					newlyRow = unused.splice(0, 1)[0];
				}
			}else{
				isNewlyCreate = true;
				newlyRow = new _rowQualifiedClass();
			}
			newlyRow.rowIndex = rowIndex;
			
			var forceReloadRowIndex:int = forceReloadRowIndexesForOneTime.indexOf(rowIndex);
			var shouldReloadRow:Boolean = (forceReloadRowIndex >= 0);
			if(shouldReloadRow || newlyRow.data != rowDt){
				newlyRow.data = rowDt;
				forceReloadRowIndexesForOneTime.splice(forceReloadRowIndex, 1);
			}
			
			var thePos:int = this.positionOfRow(rowIndex);
			if(forceAnimatePositionLoadForOneTime){
				if(_isHorizontal){
					TweenLite.to(newlyRow, AZScrollView.ScrollViewAnimationDurationMilliSec / 1000, {x: thePos});
				}else{
					TweenLite.to(newlyRow, AZScrollView.ScrollViewAnimationDurationMilliSec / 1000, {y: thePos});
				}
			}else{
				if(_isHorizontal){
					newlyRow.x = thePos;
				}else{
					newlyRow.y = thePos;
				}
			}
			
			if(! newlyRow.parent){
				addChild(newlyRow);
			}
			newlyRow.visible = true;
			
			displayingRowsCache[rowIndex] = newlyRow;
			
			if(isNewlyCreate){
				var evt:AZListViewEvent = new AZListViewEvent(AZListViewEvent.LOAD_ROW);
				evt.loadedRow = newlyRow;
				dispatchEvent(evt);
			}
			
			return newlyRow;
			
		}
		
		
		private function loadRows():void{
			if(! _dataProvider || rowCountCache <= 0){
				return;
			}
			
			var sr:Rectangle = this.scrollRect;
			if(! forceLoadRowsForOneTime){
				if(! sr){
					return;
				}
			}
			
			if(! forceLoadRowsForOneTime){
				var isSameScrollPos:Boolean;
				if(_isHorizontal){
					isSameScrollPos = (sr.x == lastScrollRectPos);
				}else{
					isSameScrollPos = (sr.y == lastScrollRectPos);
				}
				if(isSameScrollPos){
					return;
				}
			}
			if(_isHorizontal){
				lastScrollRectPos = sr.x;
			}else{
				lastScrollRectPos = sr.y;
			}
			
			var startRowIndex:int;
			var endRowIndex:int;
			if(_isHorizontal){
				startRowIndex = this.rowIndexOfPosition(sr.x);
				endRowIndex = this.rowIndexOfPosition(sr.x + sr.width);
			}else{
				startRowIndex = this.rowIndexOfPosition(sr.y);
				endRowIndex = this.rowIndexOfPosition(sr.y + sr.height);
			}
			
			if(! forceLoadRowsForOneTime){
				if(startRowIndex == lastStartRowIndex && endRowIndex == lastEndRowIndex){
					return;
				}
			}
			lastStartRowIndex = startRowIndex;
			lastEndRowIndex = endRowIndex;
			
			var i:int;
			for(i = startRowIndex; i <= endRowIndex; i++){
				var cachedDisplayingRow:AZListViewRow = displayingRowsCache[i];
				
				if(cachedDisplayingRow){
					var forceReloadRowIndex:int = forceReloadRowIndexesForOneTime.indexOf(i);
					var shouldReloadRow:Boolean = (forceReloadRowIndex >= 0);
					
					var rowDt:AZListViewRowData = _dataProvider[i];
					if(shouldReloadRow || cachedDisplayingRow.data != rowDt){
						cachedDisplayingRow.data = rowDt;
						forceReloadRowIndexesForOneTime.splice(forceReloadRowIndex, 1);
					}
					
					if(forceUpdateDisplayingRowsPostionForOneTime){
						var thePos:int = this.positionOfRow(i);
						if(forceAnimatePositionLoadForOneTime){
							if(_isHorizontal){
								TweenLite.to(cachedDisplayingRow, AZScrollView.ScrollViewAnimationDurationMilliSec / 1000, {x: thePos});
							}else{
								TweenLite.to(cachedDisplayingRow, AZScrollView.ScrollViewAnimationDurationMilliSec / 1000, {y: thePos});
							}
						}else{
							if(_isHorizontal){
								cachedDisplayingRow.x = thePos;
							}else{
								cachedDisplayingRow.y = thePos;
							}
						}
					}
					
				}else{
					this.loadRowAtIndex(i);
					
				}
			}
			
			
			if(forceLoadRowsForOneTime){
				forceLoadRowsForOneTime = false;
			}
			
			if(forceUpdateDisplayingRowsPostionForOneTime){
				forceUpdateDisplayingRowsPostionForOneTime = false;
			}
			
			if(forceAnimatePositionLoadForOneTime){
				forceAnimatePositionLoadForOneTime = false;
			}
			
			
			for(i in displayingRowsCache){
				if(i < startRowIndex || i > endRowIndex){
					var unusedRow:AZListViewRow = displayingRowsCache[i];
					var unused:Vector.<AZListViewRow> = unusedRowsCache[unusedRow.data.reusableIdentifier];
					if(! unused){
						unused = new Vector.<AZListViewRow>();
						unusedRowsCache[unusedRow.data.reusableIdentifier] = unused;
					}
					unused.push(unusedRow);
					unusedRow.visible = false;
					delete displayingRowsCache[i];
				}
			}
			
		}
		
		override protected function onEnterFrame(e:Event):void{
			super.onEnterFrame(e);
			
			this.loadRows();
			
		}
		
		
	}
}