
import ShopList;
import skyui.components.list.ListLayout;
import skyui.components.list.ListState;
import skyui.components.list.ColumnLayoutData;
import skyui.components.list.IEntryFormatter;
import skyui.components.list.BasicListEntry;

class ShopListEntry extends BasicListEntry 
{	
	/* STAGE ELEMENTS */
	public var _name: TextField;
	public var _pricetag: TextField;

	public var _soldout: TextField

	// -- Data
	private var itemname: String;
	private var price: Number;

	private var stock: Number;
	private var fillyrank: Number;

	private var selectIndicator: MovieClip;
	private var selectIndicatorArrow: MovieClip;
	private var selectIndicatorBG: MovieClip;
	
	// ---
	private var type: String;

	public static var defaultTextColor: Number = 0xCCCCCC;
	// public static var activeTextColor: Number = 0xffffff;
	// public static var selectedTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x353535;

	// ---
	public function ShopListEntry()
	{
		super();

		// constructor code
		selectIndicatorArrow = selectIndicator._arrow;
		selectIndicatorBG = selectIndicator._background;
	}

	// IDEA: when option disabled, set color selectIndicatorBG to #660000 || otherwise #666666
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		// Not using "enabled" directly, because we still want to be able to receive onMouseX events,
		// even if we chose not to process them.
		isEnabled = a_entryObject.enabled;

		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		_name.text = a_entryObject.name;
		_pricetag.text = a_entryObject.price + " F.C.";
		a_entryObject.disablereason;
		if (isEnabled) {
			_soldout.text = " ";
			_name.textColor = defaultTextColor;
			_pricetag.textColor = defaultTextColor;
		} else {
			_soldout.text = a_entryObject.errormessage;
			_name.textColor = disabledTextColor;
			_pricetag.textColor = disabledTextColor;
		}
		
		selectIndicator._visible = isSelected;
	}
}
