
import ShopList;
import skyui.components.list.ListLayout;
import skyui.components.list.ListState;
import skyui.components.list.ColumnLayoutData;
import skyui.components.list.IEntryFormatter;
import skyui.components.list.BasicListEntry;

class ShopListEntry extends BasicListEntry 
{	
	/* STAGE ELEMENTS */
	public var _nametag: TextField;
	public var _pricetag: TextField;

	public var _soldout: TextField;
	public var _selectIndicator: MovieClip;
	private var selectIndicatorArrow: MovieClip;
	private var selectIndicatorBG: MovieClip;
	
	// ---
	private var type: String;

	public static var defaultTextColor: Number = 0xCCCCCC;
	// public static var activeTextColor: Number = 0xffffff;
	// public static var selectedTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x454545;
	public static var expensiveTextColor: Number = 0xFF0000;

	// ---
	public function ShopListEntry()
	{
		super();

		// constructor code
		selectIndicatorArrow = _selectIndicator._arrow;
		selectIndicatorBG = _selectIndicator._background;
	}

	// IDEA: when option disabled, set color selectIndicatorBG to #660000 || otherwise #666666
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		// Not using "enabled" directly, because we still want to be able to receive onMouseX events,
		// even if we chose not to process them.
		isEnabled = a_entryObject.enabled;
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		_nametag.text = a_entryObject.name;
		_pricetag.text = a_entryObject.price + " F.C.";
		a_entryObject.disablereason;
		if (isEnabled) {
			_soldout.text = " ";
			_nametag.textColor = defaultTextColor;
			if (a_entryObject.price > Shop.COINS) {
				_pricetag.textColor = expensiveTextColor;
				// isEnabled = false;
			} else {
				_pricetag.textColor = defaultTextColor;
			}
			_pricetag._alpha = 100
			_nametag._alpha = 100
		} else {
			if (a_entryObject.rank > Shop.RANK)
				_soldout.text = "$SLUTS_ReqRank{" + a_entryObject.rank + "}";
			else if (a_entryObject.stock == 0)
				_soldout.text = "$SOLD OUT";
			_pricetag.textColor = disabledTextColor;
			_nametag.textColor = disabledTextColor;

			_pricetag._alpha = 35
			_nametag._alpha = 35
		}
		
		_selectIndicator._visible = isSelected;
		
	}
}
