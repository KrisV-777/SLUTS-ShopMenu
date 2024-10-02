import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.controls.Button;
import Shared.GlobalFunc;

import skyui.components.SearchWidget;
import skyui.components.TabBar;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.TabularList;
import skyui.components.list.SortedListHeader;
import skyui.filter.ItemTypeFilter;
import skyui.filter.NameFilter;
import skyui.filter.SortFilter;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.util.DialogManager;
import skyui.util.Debug;

import skyui.defines.Input;
import CategoryListV;
import ExchangeType;

class ShopLists extends MovieClip 
{
	/* CONSTANTS */
	
	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;
	
	
  /* STAGE ELEMENTS */
  
	public var itemList: TabularList;

	public var categoryList: CategoryListV;
	public var categoryLabel: MovieClip;

	public var searchWidget: SearchWidget;

	public var background: MovieClip;

  /* PRIVATE VARIABLES */

	private var _typeFilter: ItemTypeFilter;
	private var _nameFilter: NameFilter;
	private var _sortFilter: SortFilter;
	
	private var _platform: Number;
	
	private var _currCategoryIndex: Number;
	private var _savedSelectionIndex: Number = -1;
	
	private var _searchKey: Number = -1;
	private var _switchTabKey: Number = -1;
	private var _sortOrderKey: Number = -1;
	private var _sortOrderKeyHeld: Boolean = false;
	
	// private var _bTabbed = false;
	// private var _leftTabText: String;
	// private var _rightTabText: String;

	private var _columnSelectDialog: MovieClip;
	private var _columnSelectInterval: Number;
	
	private var _disableInput: Boolean;

  /* INITIALIZATION */

	public function ShopLists()
	{
		super();

		GlobalFunctions.addArrayFunctions();

		EventDispatcher.initialize(this);

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		ConfigManager.registerUpdateCallback(this, "onConfigUpdate");
		
		// data processors are initialized by the top-level menu since they differ in each case
		_typeFilter = new ItemTypeFilter();
		_nameFilter = new NameFilter();
		_sortFilter = new SortFilter();

		categoryList.suspended = true;
		itemList.suspended = true;
		_disableInput = true;
	}
	
	public function onLoad(): Void
	{

		itemList.listState.maxTextLength = 80;

		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");

		categoryList.addEventListener("itemPress", this, "onCategoriesItemPress");
		categoryList.addEventListener("itemPressAux", this, "onCategoriesItemPress");
		categoryList.addEventListener("selectionChange", this, "onCategoriesListSelectionChange");

		itemList.disableInput = false;

		itemList.addEventListener("selectionChange", this, "onItemsListSelectionChange");
		itemList.addEventListener("sortChange", this, "onSortChange");

		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");

		FocusHandler.instance.setFocus(itemList, 0);

		categoryList.suspended = false;
		itemList.suspended = false;
		_disableInput = false;
	}

	public function InitItemList(): Void
	{
		if (itemList.listEnumeration != undefined)
			return;

		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_sortFilter);
		itemList.listEnumeration = listEnumeration;
	}

	// Called to initially set the category list.
	public function SetCategoriesList(/* CATEGORIES */): Void
	{
		var categories = [
			{text: "$SLUTS_All", flag: 1, bDontHide: true, savedItemIndex: 0, filterFlag: 1},
			{text: "$SLUTS_Gear", flag: ExchangeType.GEAR, bDontHide: true, savedItemIndex: 0, filterFlag: 1},
			{text: "$SLUTS_Potions", flag: ExchangeType.POTIONS, bDontHide: true, savedItemIndex: 0, filterFlag: 1},
			{text: "$SLUTS_Miscellaneous", flag: ExchangeType.UNSPECIFIED + ExchangeType.VALUABLE, bDontHide: true, savedItemIndex: 0, filterFlag: 1}
		];

		categoryList.listEnumeration = new BasicEnumeration(categoryList.entryList);
		categoryList.clearList();

		for (var i = 0; i < categories.length; i++) {
			var entry = categories[i];
			categoryList.entryList.push(entry);

			if (entry.flag == 0)
				categoryList.dividerIndex = i;
		}

		categoryLabel.textField.SetText(categoryList.selectedEntry.text);
		categoryList.InvalidateData();
		categoryList.onItemPress(0, 0);
	}
	
  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	// @mixin by Shared.GlobalFunc
	public var Lock: Function;

	public function OnMenuClose(): Void
	{
		_disableInput = true;
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;

		categoryList.setPlatform(a_platform,a_bPS3Switch);
		itemList.setPlatform(a_platform,a_bPS3Switch);
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (_disableInput)
			return false;

		if (_platform != 0) {
			if (details.skseKeycode == _sortOrderKey) {
				if (details.value == "keyDown") {
					_sortOrderKeyHeld = true;

					if (_columnSelectDialog)
						DialogManager.close();
					else
						_columnSelectInterval = setInterval(this, "onColumnSelectButtonPress", 1000, {type: "timeout"});

					return true;
				} else if (details.value == "keyUp") {
					_sortOrderKeyHeld = false;

					if (_columnSelectInterval == undefined)
						// keyPress handled: Key was released after the interval expired, don't process any further
						return true;

					// keyPress not handled: Clear intervals and change value to keyDown to be processed later
					clearInterval(_columnSelectInterval);
					delete(_columnSelectInterval);
					// Continue processing the event as a normal keyDown event
					details.value = "keyDown";
				} else if (_sortOrderKeyHeld && details.value == "keyHold") {
					// Fix for opening journal menu while key is depressed
					// For some reason this is the only time we receive a keyHold event
					_sortOrderKeyHeld = false;

					if (_columnSelectDialog)
						DialogManager.close();

					return true;
				}
			}

			if (_sortOrderKeyHeld) // Disable extra input while interval is active
				return true;
		}

		if (GlobalFunc.IsKeyPressed(details)) {
			// Search hotkey (default space)
			if (details.skseKeycode == _searchKey) {
				searchWidget.startInput();
				return true;
			}
		}
		
		if (categoryList.handleInput(details, pathToFocus))
			return true;
		
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}

	public function getContentBounds():Array
	{
		return [background._x, background._y, background._width, background._height];

		// var lb = panelContainer.ListBackground;
		// return [lb._x, lb._y, lb._width, lb._height];
	}
	
	public function showItemsList(): Void
	{
		_currCategoryIndex = categoryList.selectedIndex;
		
		categoryLabel.textField.SetText(categoryList.selectedEntry.text);

		// Start with no selection
		itemList.selectedIndex = -1;
		itemList.scrollPosition = 0;

		if (categoryList.selectedEntry != undefined) {
			// Set filter type
			_typeFilter.changeFilterFlag(categoryList.selectedEntry.flag);
			
			// Not set yet before the config is loaded
			itemList.layout.changeFilterFlag(categoryList.selectedEntry.flag);
		}
		 
		itemList.requestUpdate();
		
		dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});

		itemList.disableInput = false;
	}

	// Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	// @API
	public function InvalidateListData(): Void
	{
		var flag = categoryList.selectedEntry.flag;

		for (var i = 0; i < categoryList.entryList.length; i++)
			categoryList.entryList[i].filterFlag = categoryList.entryList[i].bDontHide ? 1 : 0;

		itemList.InvalidateData();

		// Set filter flag = 1 for non-empty categories with bDontHideOffset=false
		for (var i = 0; i < itemList.entryList.length; i++) {
			for (var j = 0; j < categoryList.entryList.length; ++j) {
				if (categoryList.entryList[j].filterFlag != 0)
					continue;

				if (itemList.entryList[i].filterFlag & categoryList.entryList[j].flag)
					categoryList.entryList[j].filterFlag = 1;
			}
		}

		categoryList.UpdateList();

		if (flag != categoryList.selectedEntry.flag) {
			// Triggers an update if filter flag changed
			_typeFilter.itemFilter = categoryList.selectedEntry.flag;
			dispatchEvent({type:"categoryChange", index:categoryList.selectedIndex});
		}
		
		// This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data    
		if (itemList.selectedIndex == -1)
			dispatchEvent({type:"showItemsList", index: -1});
		else
			dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});
	}
	
	
  /* PRIVATE FUNCTIONS */
  
  	private function onConfigLoad(event: Object): Void
	{
		var config = event.config;
		_searchKey = config["Input"].controls.pc.search;
		
		if (_platform == 0)
			_switchTabKey = config["Input"].controls.pc.switchTab;
		else {
			_switchTabKey = config["Input"].controls.gamepad.switchTab;
			_sortOrderKey = config["Input"].controls.gamepad.sortOrder;
		}
	}
  
	private function onFilterChange(): Void
	{
		itemList.requestInvalidate();
	}
	
	private function onColumnSelectButtonPress(event: Object): Void
	{
		if (event.type == "timeout") {
			clearInterval(_columnSelectInterval);
			delete(_columnSelectInterval);
		}

		if (_columnSelectDialog) {
			DialogManager.close();
			return;
		}
		
		_savedSelectionIndex = itemList.selectedIndex;
		itemList.selectedIndex = -1;
		
		categoryList.disableSelection = categoryList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true;
		searchWidget.isDisabled = true;
	}
	
	private function onColumnSelectDialogClosed(event: Object): Void
	{
		categoryList.disableSelection = categoryList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		searchWidget.isDisabled = false;
		
		itemList.selectedIndex = _savedSelectionIndex;
	}
	
	private function onConfigUpdate(event: Object): Void
	{
		itemList.layout.refresh();
	}

	private function onCategoriesItemPress(): Void
	{
		showItemsList();
	}

	private function onCategoriesListSelectionChange(event: Object): Void
	{
		dispatchEvent({type:"categoryChange", index:event.index});
		
		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	private function onItemsListSelectionChange(event: Object): Void
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	private function onSortChange(event: Object): Void
	{
		_sortFilter.setSortBy(event.attributes, event.options);
	}

	private function onSearchInputStart(event: Object): Void
	{
		categoryList.disableSelection = categoryList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
		categoryList.disableSelection = categoryList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		_nameFilter.filterText = event.data;
	}

}
