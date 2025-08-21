import CategoryList;

class slutsExchange.CategoryListV extends CategoryList {

	public var iconHeight;
	public var iconWidth;
	public var selectorOffset;	// offset from rightern bound for selector

	private var _contentHeight;
	private var _totalHeight;
	
	public function CategoryListV() {
		super();

		if (iconHeight == undefined)
			iconHeight = iconSize;
		if (iconWidth == undefined)
			iconWidth = iconSize;
	}

	// @override CategoryList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}
		
		setClipCount(_segmentLength);

		var ch = 0;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);

			entryClip.setEntry(listEnumeration.at(i + _segmentOffset), listState);

			entryClip.background._width = iconWidth;
			entryClip.background._height = iconHeight;

			listEnumeration.at(i + _segmentOffset).clipIndex = i;
			entryClip.itemIndex = i + _segmentOffset;

			ch += iconHeight;
		}

		_contentHeight = ch;
		_totalHeight = background._height;

		var spacing = (_totalHeight - _contentHeight) / (_segmentLength + 1);

		var yPos = background._y + spacing;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._y = yPos;

			yPos += iconHeight + spacing;
			entryClip._visible = true;
		}
		
		updateSelector();
	}

	// @override CategoryList
	private function updateSelector(): Void
	{
		if (selectorCenter == undefined) {
			return;
		}
			
		if (_selectedIndex == -1) {
			selectorCenter._visible = false;

			if (selectorLeft != undefined)
				selectorLeft._visible = false;
				
			if (selectorRight != undefined)
				selectorRight._visible = false;

			return;
		}

		var selectedClip = _entryClipManager.getClip(_selectedIndex - _segmentOffset);

		_targetSelectorPos = selectedClip._y + (selectedClip.background._height - selectorCenter._height) / 2;
		
		selectorCenter._visible = true;
		selectorCenter._x = selectedClip._x + selectedClip.background._width; // unnecessary, x coordinate is already set in the widget
		
		if (selectorLeft != undefined) {
			selectorLeft._visible = true;
			selectorLeft._x = selectorCenter._x;
			selectorLeft._y = 0; // -iconHeight;
		}

		if (selectorRight != undefined) {
			selectorRight._visible = true;
			selectorRight._x = selectorCenter._x;
			selectorRight._height = _totalHeight - selectorRight._y;
		}
	}

	// @override CategoryList
	private function refreshSelector(): Void
	{
		selectorCenter._visible = true;
		var selectedClip = _entryClipManager.getClip(_selectedIndex - _segmentOffset);

		selectorCenter._y = _selectorPos;

		if (selectorLeft != undefined) {
			selectorLeft._height = selectorCenter._y; // + iconHeight;
		}
		if (selectorRight != undefined) {
			selectorRight._y = selectorCenter._y + selectorCenter._height;
			selectorRight._height = _totalHeight - selectorRight._y;
		}
	}
}
