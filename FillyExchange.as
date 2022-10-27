import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Input;
import skyui.defines.Inventory;
import skyui.util.GlobalFunctions;
import skyui.util.ConfigManager;
import skyui.components.ButtonPanel;

import BottomBarEX;
import ShopLists;
import CategoryList;


class FillyExchange extends MovieClip
{
	/* STAGE */

	public var shopLists: ShopLists;		// NOTE: based on "InventoryLists"
	public var itemCardFadeHolder: MovieClip;
	public var bottomBarEX: MovieClip;
	public var background: MovieClip;

	public var itemCard: MovieClip;
	public var navPanel: ButtonPanel;

  /* PRIVATE VARIABLES */

	private var _shopItems: Array;	// Forms listed in the shop
	private var _extraData: Array;	// assert(_extraData[i] == _shopItems[i].extra)

	private var _coinRatio: Number = 50;
	private var _buyMult: Number = 1.0;
	private var _quantityMinCount: Number = 5;

	private var _playerCoins: Number = 0;
	private var _playerRank: Number = 0;

	private var _config: Object;
	private var _categoryListIconArt: Array;

	private var _itemSelected: Object;

	private var _switchTabKey: Number;
	private var _searchKey: Number;
	private var _searchControls: Object;
	private var _cancelControls: Object;
	private var _acceptControls: Object;
	// Console only controls
	private var _sortColumnControls: Array;
	private var _sortOrderControls: Object;

	private var _platform: Number = 0;

	/* PAPYRUS API */

	public function SetData(a_encumbranceCurrent: Number, a_encumbranceMax: Number, a_playerCoins: Number, a_playerrank: Number, a_coinratio: Number, a_buymult: Number)
	{
		_coinRatio = a_coinratio;
		_buyMult = a_buymult;
		_playerRank = a_playerrank;

		UpdatePlayerInfo(a_encumbranceCurrent, a_encumbranceMax, a_playerCoins);
	}

	public function UpdatePlayerInfo(a_encumbranceCurrent: Number, a_encumbranceMax: Number, a_playerCoins: Number): Void
	{
		_playerCoins = a_playerCoins;

		var plupdate = {encumbrance: a_encumbranceCurrent, maxEncumbrance: a_encumbranceMax};
		bottomBarEX.updateBarterInfo(plupdate, itemCard.itemInfo, _playerCoins, _playerRank);
	}

	public function AddItems(a_formlist: Object)
	{
		var list: Array = a_formlist.forms;
		for (var i = 0; i < list.length; i++) {
			var item = list[i];
			skse.ExtendData(item.formId, item, true, true);
				
			_shopItems.push(item);
		}
	}

	public function AddExtraData(/* Extra Data */)
	{
		for (var i = 0; i < arguments.length; i++) {
			var data = arguments[i].split(";");
			var extra = {
				type:		Math.max(data[0], 0),
				count:	data[1] < 0 ? undefined : data[1],
				rank:		data[2] < 1 ? undefined : data[2],
				value:	Math.max(data[3], 0),
				name: 	data[4] == "" ? undefined : data[4]
			};
			_extraData.push(extra);
		}
	}

	public function PopulateShop()
	{
		if (_shopItems.length != _extraData.length) {
			skse.SendModEvent("Sluts_PrintInfo", "Mismatch Data Count");
			skse.Log("Mismatching number of items and extra data");
			return;
		}

		shopLists.InitItemList();
		shopLists.itemList.clearList();

		for (var i = 0; i < _shopItems.length; i++) {
			var extra = _extraData[i];
			_shopItems[i].extra = extra;
			_shopItems[i].enabled = extra.rank <= _playerRank;
			shopLists.itemList.entryList.push(_shopItems[i]);
		}

		shopLists.InvalidateListData();
	}

  /* INITIALIZATION */


	public function FillyExchange()
	{
		super();

		itemCard = itemCardFadeHolder.ItemCard_mc;
		navPanel = bottomBarEX.bottomBar.buttonPanel;

		Mouse.addListener(this);

		var indicies = new Array();
		skse.LoadIndices("Sluts_Indicies", indicies);
		if (indicies.length == 0)
			ConfigManager.registerLoadCallback(this, "onConfigLoad");
		// else load(indicies);
		

		_shopItems = new Array();
		_extraData = new Array();
		// TODO: rewrite to fit own icons. Names are set in an external .swf file loaded through config (?)
		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];

	}

	public function onLoad(): Void
	{
		SetPlatform(0); // TODO: find platform dynamically

		// TODO: figure out if this is needed? prolly not?
		skse.ExtendData(true);
		skse.ForceContainerCategorization(true);

		// TODO: rename these or something, not sure what they mean
		shopLists.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		shopLists.addEventListener("showItemsList", this, "onShowItemsList");
		shopLists.addEventListener("hideItemsList", this, "onHideItemsList");

		shopLists.itemList.addEventListener("itemPress", this ,"onItemSelect");

		itemCard.addEventListener("quantitySelect",this,"onQuantityMenuSelect");		// when accepting slider
		itemCard.addEventListener("subMenuAction",this,"onItemCardSubMenuAction");	// when opening/closing any new card
		itemCard.addEventListener("sliderChange",this,"onQuantitySliderChange");		// when changing slider

		// positionFixedElements(); TODO: figure out what this does

		itemCard._visible = false;
		navPanel.hideButtons();

		// TODO: Initialize menu-specific list components
		var categoryList: CategoryList = shopLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}

	// fired ~3 seconds after menu opened
	private function onConfigLoad(event: Object): Void
	{
		_config = event.config;

		// positionFloatingElements();	TODO: figure out tf this does

		var itemListState = shopLists.itemList.listState;
		var appearance = _config["Appearance"];

		var categoryListState = shopLists.categoryList.listState;
		categoryListState.iconSource = appearance.icons.category.source;

		itemListState.iconSource = appearance.icons.item.source;
		itemListState.showStolenIcon = appearance.icons.item.showStolen;

		itemListState.defaultEnabledColor = appearance.colors.text.enabled;
		itemListState.negativeEnabledColor = appearance.colors.negative.enabled;
		itemListState.stolenEnabledColor = appearance.colors.stolen.enabled;
		itemListState.defaultDisabledColor = appearance.colors.text.disabled;
		itemListState.negativeDisabledColor = appearance.colors.negative.disabled;
		itemListState.stolenDisabledColor = appearance.colors.stolen.disabled;

		_quantityMinCount = _config["ItemList"].quantityMenu.minCount;

		_searchKey = _config["Input"].controls.pc.search;
		_searchControls = {keyCode: _searchKey};

		updateBottomBar(false);

		var itemList: TabularList = shopLists.itemList;
		itemList.addDataProcessor(new ShopDataSetter(_buyMult, _coinRatio));
		itemList.addDataProcessor(new InventoryIconSetter(_config["Appearance"]));
		itemList.addDataProcessor(new PropertyDataExtender(_config["Appearance"], _config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));

		// var layout: ListLayout = ListLayoutManager.createLayout(_config["ListLayout"], "ItemListLayout");
		var layout: ListLayout = ListLayoutManager.createLayout(_config["ListLayout"], "FillyExchangeLayout");
		itemList.layout = layout;
		trace(layout);

		// Not 100% happy with doing this here, but has to do for now.
		if (shopLists.categoryList.selectedEntry) {
			layout.changeFilterFlag(shopLists.categoryList.selectedEntry.flag);
		}
	}

  /* PUBLIC FUNCTIONS */

	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		// COMEBACK: This is never called right now and always assume _platform == PC
		// Assuming platform means controller or keyboard, I might want to figure out how to figure this out and then call this :^)
		_platform = a_platform;

		if (a_platform == 0) {
			_acceptControls = Input.Enter;
			_cancelControls = Input.Tab;

			// Defaults
			// _switchControls = Input.Alt;
		} else {
			_acceptControls = Input.Accept;
			_cancelControls = Input.Cancel;

			// Defaults
			// _switchControls = Input.GamepadBack;
			_sortColumnControls = Input.SortColumn;
			_sortOrderControls = Input.SortOrder;
		}

		// Defaults
		_searchControls = Input.Space;

		shopLists.setPlatform(a_platform, a_bPS3Switch);
		itemCard.SetPlatform(a_platform, a_bPS3Switch);
		bottomBarEX.bottomBar.setPlatform(a_platform, a_bPS3Switch);
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.SHIFT_TAB)) {
			// TODO: save config
			shopLists.OnMenuClose()
			skse.CloseMenu("CustomMenu");
		}

		return true;
	}

  /* PRIVATE FUNCTIONS */

	private function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled) {
			if (event.entry.count == 0)
				return;

			if (_quantityMinCount < 1 || event.entry.count < _quantityMinCount)
				onQuantityMenuSelect({amount:1, item: event.entry});
			else
				skse.SendModEvent("Sluts_PrintInfo", "Showing Quant Menu");
				_itemSelected = event.entry;
				itemCard.ShowQuantityMenu(event.entry.count);
		}
	}

	private function onQuantitySliderChange(event: Object): Void
	{
		var price = _itemSelected.extra.value * event.value * -1;
		bottomBarEX.updateBarterPriceInfo(_playerCoins, _playerRank, itemCard.itemInfo, price);
	}

	// @override ItemMenu
	private function onQuantityMenuSelect(event: Object): Void
	{
		if (event.item == undefined)
			event.item = _itemSelected;

		skse.SendModEvent("Sluts_OnExchange", "", event.amount, event.item.formId);
	}

	// @override ItemMenu
	private function onShowItemsList(event: Object): Void
	{
		shopLists.showItemsList();

		onItemHighlightChange(event);
	}

	// @override ItemMenu
	private function onItemHighlightChange(event: Object): Void
	{
		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
	private function onHideItemsList(event: Object): Void
	{
		// TODO: figure out if used
		// GameDelegate.call("UpdateItem3D",[false]);
		// itemCard.FadeOutCard();

		// bottomBar.updateBarterPerItemInfo({type:Inventory.ICT_NONE});

		updateBottomBar(false);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event: Object): Void
	{
		if (event.opening == true) {
			shopLists.itemList.disableSelection = true;
			shopLists.itemList.disableInput = true;
			shopLists.categoryList.disableSelection = true;
			shopLists.categoryList.disableInput = true;
		} else if (event.opening == false) {
			shopLists.itemList.disableSelection = false;
			shopLists.itemList.disableInput = false;
			shopLists.categoryList.disableSelection = false;
			shopLists.categoryList.disableInput = false;
		}

		if (event.menu == "quantity") {
			if (event.opening) {
				onQuantitySliderChange({value:itemCard.itemInfo.count});
				return;
			}
			bottomBarEX.updateBarterPriceInfo(_playerCoins, _playerRank);
		}
	}

	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();

		navPanel.addButton({text: "$Exit", controls: _cancelControls});
		navPanel.addButton({text: "$Search", controls: _searchControls});
		if (_platform != 0) {
			navPanel.addButton({text: "$Column", controls: _sortColumnControls});
			navPanel.addButton({text: "$Order", controls: _sortOrderControls});
		}
		if (a_bSelected) {
			navPanel.addButton({text: "$Buy", controls: Input.Activate});
		}

		navPanel.updateButtons(true);
	}

	// private function positionFixedElements(): Void
	// {
	// 	GlobalFunc.SetLockFunction();

	// 	inventoryLists.Lock("L");
	// 	inventoryLists._x = inventoryLists._x - 20;

	// 	var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
	// 	var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

	// 	bottomBar.positionElements(leftEdge, rightEdge);

	// 	MovieClip(exitMenuRect).Lock("TL");
	// 	exitMenuRect._x = exitMenuRect._x - Stage.safeRect.x;
	// 	exitMenuRect._y = exitMenuRect._y - Stage.safeRect.y;
	// }

	// private function positionFloatingElements(): Void
	// {
	// 	var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
	// 	var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

	// 	var a = inventoryLists.getContentBounds();
	// 	// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
	// 	var panelEdge = inventoryLists._x + a[0] + a[2] + 25;

	// 	var itemCardContainer = itemCard._parent;
	// 	var itemcardPosition = _config.ItemInfo.itemcard;
	// 	var itemiconPosition = _config.ItemInfo.itemicon;

	// 	var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;

	// 	// Scale down if necessary
	// 	if (scaleMult < 1.0) {
	// 		itemCardContainer._width *= scaleMult;
	// 		itemCardContainer._height *= scaleMult;
	// 		itemiconPosition.scale *= scaleMult;
	// 	}

	// 	if (itemcardPosition.align == "left")
	// 		itemCardContainer._x = panelEdge + leftEdge + itemcardPosition.xOffset;
	// 	else if (itemcardPosition.align == "right")
	// 		itemCardContainer._x = rightEdge - itemCardContainer._width + itemcardPosition.xOffset;
	// 	else
	// 		itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardContainer._width) / 2;

	// 	itemCardContainer._y = itemCardContainer._y + itemcardPosition.yOffset;

	// 	if (mouseRotationRect != undefined) {
	// 		MovieClip(mouseRotationRect).Lock("T");
	// 		mouseRotationRect._x = itemCard._parent._x;
	// 		mouseRotationRect._width = itemCardContainer._width;
	// 		mouseRotationRect._height = 0.55 * Stage.visibleRect.height;
	// 	}

	// 	_bItemCardPositioned = true;

	// 	// Delayed fade in if positioned wasn't set
	// 	if (_bItemCardFadedIn) {
	// 		GameDelegate.call("UpdateItem3D",[true]);
	// 		itemCard.FadeInCard();
	// 	}
	// }

}
