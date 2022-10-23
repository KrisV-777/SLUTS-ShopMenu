import gfx.io.GameDelegate;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.list.BasicList;
import skyui.components.ButtonPanel;

import skyui.util.Translator;
import skyui.defines.Input;
import skse;

import ShopCategoryList;

/**
	enum TYPE
	{
		Coins,
		Licenses,
		Upgrades,
		Gear,
		Miscallenous
	}

	struct EntryObject
	{
		TYPE type;

		string item_name;
		int price;

		int stock;
		int required_fillyrank;
	};
*/

class Shop extends MovieClip
{
	public static var RATIO: Number;
	public static var COINS: Number;
	public static var RANK: Number;

	/* STAGE */
	public var shoppanel: MovieClip;
	public var bottomBar: MovieClip;

	public var fillyrank: TextField;
	public var fillycoins: TextField;
	private var titleText: TextField;

	private var _shopList: ScrollingList;
	private var _categorielist: ScrollingList;

	private var _buttonPanelL: ButtonPanel;
	private var _buttonPanelR: ButtonPanel;

	private var itemCard: MovieClip;

	// ---
	private var _platform: Number;

	private var _acceptControls: Object;
	private var _cancelControls: Object;

	// ---
	public function Shop()
	{
		super();

		// constructor code
		_shopList = shoppanel.list;
		_categorielist = shoppanel.categories;
		itemCard = shoppanel._ItemCardContainer.ItemCard_mc;

		titleText = shoppanel.decorTitle.textField;
		titleText.text = "$SLUTS_FillyCoinExchange"

		_buttonPanelL = bottomBar.buttonPanelL;
		_buttonPanelR = bottomBar.buttonPanelR;
	}

	public function onLoad()
	{
		_shopList.listEnumeration = new BasicEnumeration(_shopList.entryList);
		_categorielist.listEnumeration = new BasicEnumeration(_categorielist.entryList);

		_shopList.addEventListener("itemPress", this ,"onItemSelect");						// {index: Number, entry: Object, keyboardOrMouse: Bool}

		_categorielist.addEventListener("itemPress", this ,"onItemSelect_Category");

		itemCard.addEventListener("quantitySelect",this,"onQuantityMenuSelect");	// {amount: Number}
		itemCard.addEventListener("subMenuAction",this,"onSubMenuAction"); 				// {opening: Bool, menu: String} | [Listen for menu == "quantity"]
		itemCard._visible = false;

		populateCategories();

		// --- TEST ---
		// setShopData(50, 1, 30);
		// // aiType + asEntryID + ";" + asEntryName + ";" + aiPriceInGold + ";" + aiAvailableStock + ";" + aiRequiredRank
		// populateShop("0;SLUTS_Gold;gold;1;-1;0");
		// "1;lpescrow;License \"Premium Escrow\" (3 Days);500;1;2", 
		// "0;upgrboots;Upgrade Certificate (Boots);100;1;3", 
		// "1;upgrhoove;Upgrade Certificate (Hooves);234;0;2", 
		// "2;upgrbootsp;Filly Adventuring Gear (Boots, Pink);200;1;10", 
		// "2;gearhoovesb;Filly Adventuring Gear (Hooves, Blue);600;-1;7");
	}

	public function setShopData(a_ratio, a_rank, a_coins): Void
	{
		RATIO = a_ratio;
		RANK = a_rank;
		fillyrank.text = "$SLUTS_FillyRank: " + RANK;
		updateShopData(a_coins);
	}

	public function updateShopData(a_coins: Number): Void
	{
		COINS = a_coins;
		fillycoins.text = "$SLUTS_FillyCoins: " + a_coins;
	}

	public function populateShop(/* shop data string - array */): Void
	{
		_shopList.clearList();
		_shopList.listState.savedIndex = null;

		for (var i = 0; i < arguments.length; i++) {
			var data = arguments[i].split(";");
			var enabled = data[4] != 0 && data[5] <= RANK;
			_shopList.entryList.push({id: data[0], type: data[1], name: data[2], price: RATIO * data[3], stock: data[4], rank: data[5], enabled: enabled});
		}

		_shopList.entryList.sortOn("text", Array.CASEINSENSITIVE);
		_shopList.InvalidateData();
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		
		if (a_platform == 0) {
			_acceptControls = Input.Enter;
			_cancelControls = Input.Tab;
		} else {
			_acceptControls = Input.Accept;
			_cancelControls = Input.Cancel;
		}
		
		_buttonPanelL.setPlatform(a_platform, a_bPS3Switch);
		_buttonPanelR.setPlatform(a_platform, a_bPS3Switch);
		itemCard.SetPlatform(a_platform,a_bPS3Switch);
		
		updateModListButtons();
	}

	// --- Private ---
	private function populateCategories(): Void
	{
		_categorielist.clearList();
		_categorielist.listState.savedIndex = 0;

		var icons = ["Everything", "Coins", "Upgrades", "Gear", "Licenses", "Customization", "Misc"];
		for (var i = 0; i < icons.length; i++) {
			_categorielist.entryList.push({name: icons[i], iconLabel: icons[i], enabled: true})
		}

		_categorielist.InvalidateData();
	}

	private function updateModListButtons(): Void
	{
		var entry = _shopList.selectedEntry;
		
		_buttonPanelL.clearButtons();
		if (entry != null)
			_buttonPanelL.addButton({text: "$Select", controls: _acceptControls});
		_buttonPanelL.updateButtons(true);

		_buttonPanelR.clearButtons();
		_buttonPanelR.addButton({text: "$Exit", controls: _cancelControls});
		_buttonPanelR.updateButtons(true);
	}

	private function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled && event.entry.price < COINS) {
			var stock = event.entry.stock;
			var max = Math.floor(COINS / event.entry.price);
			if (stock && stock < max)
				Math.min(max, stock)

			if (max == 1) {
				onQuantityMenuSelect({amount:1});
			}	else {
				itemCard.ShowQuantityMenu(max);
			}
		} else {
			GameDelegate.call("DisabledItemSelect",[]);
		}
	}

	public function onSubMenuAction(event: Object): Void
	{
		if (event.menu == "quantity") {
			if (event.opening == true) {
				_shopList.disableSelection = true;
				_shopList.disableInput = true;
				_categorielist.disableSelection = true;
				_categorielist.disableInput = true;
				itemCard.FadeInCard();
			} else if (event.opening == false) {
				itemCard.FadeOutCard()
				_shopList.disableSelection = false;
				_shopList.disableInput = false;
				_categorielist.disableSelection = false;
				_categorielist.disableInput = false;
			}
		}
	}

	private function onQuantityMenuSelect(event: Object): Void
	{
		updateShopData(COINS - _shopList.selectedEntry.price * event.amount);
		_shopList.InvalidateData();

		skse.SendModEvent("SLUTSINTERN_ProcessFillyCoinExchange", _shopList.selectedEntry.id, event.amount);
	}

}