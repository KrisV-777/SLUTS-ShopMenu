import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.ButtonPanel;

import skyui.util.Translator;
import skyui.defines.Input;

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
	/* STAGE */
	public var shoppanel: MovieClip;
	public var bottomBar: MovieClip;

	public var fillyrank: TextField;
	public var fillycoins: TextField;

	/* STAGE / NESTED */
	private var _shopList:ScrollingList;
	private var ItemCard_mc: MovieClip;

	private var _buttonPanelL: ButtonPanel;
	private var _buttonPanelR: ButtonPanel;

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
		ItemCard_mc = shoppanel.ItemCard_mc;

		_buttonPanelL = bottomBar.buttonPanelL;
		_buttonPanelR = bottomBar.buttonPanelR;
	}

	public function onLoad()
	{
		_shopList.listEnumeration = new BasicEnumeration(_shopList.entryList);

		ItemCard_mc._visible = false;

		// --- TEST ---
		populateShop("TEST", "123", "123", "123", "123", "123", "123", "123", "123", "123", "123", "123", "123", "123", "123", "123", "FINAL");
	}

	public function populateShop(/* shop data string - array */)
	{
		_shopList.clearList();
		_shopList.listState.savedIndex = null;

		for (var i = 0; i < arguments.length; i++) {
			var object = createData(arguments[i]);
			if (object != null) {
				_shopList.entryList.push(object);
			}
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
		
		updateModListButtons();
	}

	// ---
	private function createData(a_datastring: String): Object
	{
		// TODO: check how to string split and decide on a parsing algorithm !IMPORTANT
		return {data: a_datastring, enabled: true};
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

}