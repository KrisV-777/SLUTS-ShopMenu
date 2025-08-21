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


class slutsPlanningRoom.SubList extends skyui.components.list.ScrollingList
{
	/* VARIABLES */

	public var activeTypes:Array;
	public var allowedTypes:Array;

	/* INITIALIZATION */

	public function SubList()
	{
		super();
    activeTypes = new Array();
		allowedTypes = new Array();
	}

	// public functions

	public function updateEnabledStatus(enabledTypes:Array, validTypes:Array)
	{
    activeTypes = enabledTypes;
		allowedTypes = validTypes;
		InvalidateData();
	}

	// @Override ScrollingList
	public function InvalidateData()
	{
		super.InvalidateData();

		doSetSelectedIndex(-1,SELECT_MOUSE);
	}

}