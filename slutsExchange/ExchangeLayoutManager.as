import skyui.util.ConfigManager;
import skyui.components.list.ListLayout;
import skyui.components.list.ListLayoutManager;

import slutsExchange.ExchangeType;

class slutsExchange.ExchangeLayoutManager extends ListLayoutManager
{
  // @override
	static private function initialize(): Boolean
	{
		ConfigManager.setConstant("ITEM_ICON", ListLayout.COL_TYPE_ITEM_ICON);
		ConfigManager.setConstant("EQUIP_ICON", ListLayout.COL_TYPE_EQUIP_ICON);
		ConfigManager.setConstant("NAME", ListLayout.COL_TYPE_NAME);
		ConfigManager.setConstant("TEXT", ListLayout.COL_TYPE_TEXT);
  
		ConfigManager.addConstantTable("ExchangeType", ExchangeType);

		return true;
	}
}
