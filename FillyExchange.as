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
import skyui.util.Translator;
import skyui.components.ButtonPanel;

import BottomBarEX;
import ShopLists;
import CategoryList;


class FillyExchange extends MovieClip
{
	private static var SLUTS_SERIALIZEKEY = "Sluts_Serialize";

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

	private var _platform: Number;
	private var _fadedOut: Boolean;

	private var _populateShopID: Number;

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

	public function PopulateShop(): Void
	{
		if (_shopItems.length != _extraData.length) {
			skse.SendModEvent("Sluts_PrintInfo", "[Exchange] Mismatch Data Count");
			return;
		}

		if (_fadedOut) {
			_populateShopID = setInterval(this, "populateShopImpl", 10);
		} else {
			populateShopImpl();
		}
	}

	private function populateShopImpl(): Void
	{
		if (_populateShopID) {
			if (_fadedOut)
				return;

			clearInterval(_populateShopID);
			delete _populateShopID;
		}

		shopLists.InitItemList();
		shopLists.itemList.clearList();

		for (var i = 0; i < _shopItems.length; i++) {
			skse.ExtendData(_shopItems[i].formId, _shopItems[i], true, true);
			var extra = _extraData[i];
			_shopItems[i].enabled = extra.rank <= _playerRank;
			_shopItems[i].extra = extra;
			_shopItems[i].text = extra.name;
			_shopItems[i].filterFlag = 1 << extra.type;
			shopLists.itemList.entryList.push(_shopItems[i]);
		}

		shopLists.InvalidateListData();
	}

  /* INITIALIZATION */


	public function FillyExchange()
	{
		super();
		_fadedOut = true;
		_platform = 0;		// TODO: find a dynamic way to figure this out

		itemCard = itemCardFadeHolder.ItemCard_mc;
		navPanel = bottomBarEX.bottomBar.buttonPanel;

		Mouse.addListener(this);

		ConfigManager.registerLoadCallback(this, "onConfigLoad");

		_shopItems = new Array();
		_extraData = new Array();
		// TODO: rewrite to fit own icons. Names are set in an external .swf file loaded through config (?)
		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
	}

	public function onLoad(): Void
	{
		shopLists.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		shopLists.addEventListener("showItemsList", this, "onShowItemsList");

		shopLists.itemList.addEventListener("itemPress", this, "onItemSelect");

		itemCard.addEventListener("quantitySelect", this, "onQuantityMenuSelect");		// when accepting slider
		itemCard.addEventListener("subMenuAction", this, "onItemCardSubMenuAction");	// when opening/closing any new card
		itemCard.addEventListener("sliderChange", this, "onQuantitySliderChange");		// when changing slider

		positionFixedElements();

		itemCard._visible = false;
		navPanel.hideButtons();

		var categoryList: CategoryList = shopLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}

	// fired ~3 seconds after menu opened
	private function onConfigLoad(event: Object): Void
	{
		_config = event.config;
		SetPlatform(_platform);

		skse.ExtendData(true);
		skse.ForceContainerCategorization(true);

		gotoAndPlay("fadeIn");
		_fadedOut = false;

		var indicies = new Array();
		skse.LoadIndices(SLUTS_SERIALIZEKEY, indicies);
		if (indicies.length > 0)
			load(indicies);

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

		// Not 100% happy with doing this here, but has to do for now.
		if (shopLists.categoryList.selectedEntry) {
			layout.changeFilterFlag(shopLists.categoryList.selectedEntry.flag);
		}
	}

	/* SERIALIZATION */	
	private function load(a_indicies: Array): Void
	{
		shopLists.categoryList.selectedIndex = a_indicies[0];
		shopLists.itemList.selectedIndex = a_indicies[1];
		shopLists.itemList.scrollPosition = a_indicies[2];
		shopLists.itemList.layout.activeColumnIndex = a_indicies[3];
		shopLists.itemList.layout.activeColumnState = a_indicies[4];
	}

	private function save(): Void
	{
		var data: Array = new Array();
		data.push(shopLists.categoryList.selectedIndex);
		data.push(shopLists.itemList.selectedIndex);
		data.push(shopLists.itemList.scrollPosition);
		data.push(shopLists.itemList.layout.activeColumnIndex);
		data.push(shopLists.itemList.layout.activeColumnState);

		skse.StoreIndices(SLUTS_SERIALIZEKEY, data);
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
		} else {
			_acceptControls = Input.Accept;
			_cancelControls = Input.Cancel;

			// Defaults
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
		if (_fadedOut)
			return;

		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.SHIFT_TAB)) {
			save();
			shopLists.OnMenuClose();
			skse.CloseMenu("CustomMenu");
		}

		return true;
	}

  /* PRIVATE FUNCTIONS */

	private function getQuantityMax(a_entryitem: Object): Number
	{
		var amount = a_entryitem.extra.count;
		if (amount == undefined || amount * a_entryitem.value < _playerCoins)
			amount = Math.floor(_playerCoins / a_entryitem.value);
		return amount;
	}

	private function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled) {
			if (event.entry.extra.count == 0)
				return;

			var amount = getQuantityMax(event.entry);
			if (amount == 0) {
				skse.SendModEvent("Sluts_PrintInfo", Translator.translate("$SLUTS_NotEnoughCoins"));
				return;
			}

			if (_quantityMinCount < 1 || event.entry.count < _quantityMinCount) {
				onQuantityMenuSelect({amount:1, item: event.entry});
			}	else {
				_itemSelected = event.entry;
				itemCard.ShowQuantityMenu(amount);
				itemCard.FadeInCard();
			}
		}
	}

	private function onQuantitySliderChange(event: Object): Void
	{
		var price = _itemSelected.value * event.value;
		bottomBarEX.updateBarterPriceInfo(_playerCoins, _playerRank, itemCard.itemInfo, -price);
	}

	private function onQuantityMenuSelect(event: Object): Void
	{
		if (event.item == undefined)
			event.item = _itemSelected;

		skse.SendModEvent("Sluts_OnExchange", "", event.amount, event.item.formId);
		if (event.item.extra.count)
			event.item.extra.count -= event.amount;
	}

	private function onShowItemsList(event: Object): Void
	{
		shopLists.showItemsList();

		onItemHighlightChange(event);
	}

	private function onItemHighlightChange(event: Object): Void
	{
		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event: Object): Void
	{
		if (event.menu != "quantity")
			return;

		if (event.opening == true) {
			shopLists.itemList.disableSelection = true;
			shopLists.itemList.disableInput = true;
			shopLists.categoryList.disableSelection = true;
			shopLists.categoryList.disableInput = true;

			onQuantitySliderChange({value: getQuantityMax(_itemSelected)});
		} else if (event.opening == false) {
			itemCard.FadeOutCard()
			bottomBarEX.updateBarterPriceInfo(_playerCoins, _playerRank);

			shopLists.itemList.disableSelection = false;
			shopLists.itemList.disableInput = false;
			shopLists.categoryList.disableSelection = false;
			shopLists.categoryList.disableInput = false;
		}
	}

	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();

		navPanel.addButton({text: "$Exit", controls: _cancelControls});
		// navPanel.addButton({text: "$Search", controls: _searchControls});
		if (_platform != 0) {
			navPanel.addButton({text: "$Column", controls: _sortColumnControls});
			navPanel.addButton({text: "$Order", controls: _sortOrderControls});
		}
		if (a_bSelected) {
			navPanel.addButton({text: "$Buy", controls: Input.Activate});
		}

		navPanel.updateButtons(true);
	}

	private function positionFixedElements(): Void
	{
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		bottomBarEX.bottomBar.positionElements(leftEdge, rightEdge);
	}
}
