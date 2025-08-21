import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.defines.Input;
import skyui.util.ConfigLoader;
import skyui.util.GlobalFunctions;
import skyui.components.list.ListLayout;
import skyui.components.list.SortedListHeader;
import skyui.components.list.ScrollingList;
import skyui.filter.IFilter;
import skyui.util.ConfigManager;


class slutsPlanningRoom.MainList extends skyui.components.list.ScrollingList
{	
  /* PROPERTIES */ 
	
	public var entryWidth: Number = 170;

	/* Variables */

	private var _maxEntryWidthCount;
	private var _listWidth;

  /* INITIALIZATION */

	public function MainList()
	{
		super();

		_listWidth = background._width - leftBorder - rightBorder;
		_maxEntryWidthCount = Math.floor(_listWidth / entryWidth);
		_maxListIndex = Math.floor(_listHeight / entryHeight) * _maxEntryWidthCount;

		scrollDelta = _maxEntryWidthCount;
	}

	public function getNthObj(n)
	{
		return getListEnumEntry(n);
	}

	// @override ScrollingList
	public function onLoad(): Void
	{
		if (scrollbar != undefined) {
			scrollbar.position = 0;
			scrollbar.addEventListener("scroll", this, "onScroll");
			scrollbar._y = topBorder;
			scrollbar.height = _listHeight;
		}
	}

	// @Override ScrollingList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}
		// Prepare clips
		setClipCount(_maxListIndex);
		
		var xStart = background._x + leftBorder;
		var yStart = background._y + topBorder;
		var h = 0;
		var w = 0;

		// Clear clipIndex for everything before the selected list portion
		for (var i = 0, ww = 1; i < getListEnumSize() && i < _scrollPosition ; i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;
		// Display the selected list portion of the list
		for (var i = _scrollPosition; i < getListEnumSize() && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;
			
			entryClip.setEntry(entryItem, listState);

			entryClip._x = xStart + w;
			entryClip._y = yStart + h;
			entryClip._visible = true;

			if (ww++ % _maxEntryWidthCount) {
				w += entryWidth;
			} else {
				h += entryHeight;
				w = 0;
			}

			++_listIndex;
		}
		
		// Clear clipIndex for everything after the selected list portion
		for (var i = _scrollPosition + _listIndex; i < getListEnumSize(); i++)
			getListEnumEntry(i).clipIndex = undefined;
			
		// Select entry under the cursor for mouse-driven navigation
		if (isMouseDrivenNav)
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, SELECT_MOUSE);
					
		if (scrollUpButton != undefined)
			scrollUpButton._visible = _scrollPosition > 0;
		if (scrollDownButton != undefined) 
			scrollDownButton._visible = _scrollPosition < _maxScrollPosition;
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		if (disableInput)
			return false;

		if (super.handleInput(details, pathToFocus))
			return true;

		if (!disableSelection && GlobalFunc.IsKeyPressed(details)) {
			var s = getSelectedListEnumIndex();
			var m = s % _maxEntryWidthCount;
			var idx = undefined;
			if (details.navEquivalent == NavigationCode.RIGHT) {
				if (s < getListEnumSize() - 1 && m != _maxEntryWidthCount - 1)
					idx = getListEnumRelativeIndex(1);
			} else if (details.navEquivalent == NavigationCode.LEFT) {
				if (s > 0 && m > 0)
					idx = getListEnumRelativeIndex(-1);
			}
			if (idx != undefined) {
				doSetSelectedIndex(idx, SELECT_KEYBOARD);
				isMouseDrivenNav = false;
				if (isPressOnMove)
					onItemPress();
				return true;
			}
		}
		return false;
	}

	// @Override ScrollingList
	public function moveSelectionDown(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(true);
			} else {
				var idx;
				if (getSelectedListEnumIndex() < getListEnumSize() - scrollDelta) {
					idx = getListEnumRelativeIndex(scrollDelta);
				} else {
					var w = getListEnumSize() - getSelectedListEnumIndex();
					var v = getListEnumSize() % _maxEntryWidthCount
					if (w <= v)
						return;
					idx = getListEnumSize() - 1;
				}
				doSetSelectedIndex(idx, SELECT_KEYBOARD);
				isMouseDrivenNav = false;
				
				if (isPressOnMove)
					onItemPress();
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition + _listIndex;
			scrollPosition = t < _maxScrollPosition ? t : _maxScrollPosition;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition + scrollDelta;
		}
	}

	// @Override ScrollingList
	private function calculateMaxScrollPosition(): Void
 	{
		var m = getListEnumSize();
		var t = m - _maxListIndex;
		var e = m % _maxEntryWidthCount;
		_maxScrollPosition = (t > 0) ? (t - e + _maxEntryWidthCount) : 0;

		updateScrollbar();

		if (_scrollPosition > _maxScrollPosition)
			scrollPosition = _maxScrollPosition;
	}
	
	// @Override ScrollingList
	private function updateScrollPosition(a_position: Number): Void
	{
		var newPosition =  a_position - (a_position % _maxEntryWidthCount);
		if (newPosition == _scrollPosition)
			return;
		_scrollPosition = newPosition;
		UpdateList();
	}

}