import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import skyui.components.list.BasicList;
import flash.geom.ColorTransform;
import com.greensock.*;
import com.greensock.easing.*;

class slutsPlanningRoom.MainListEntry extends BasicListEntry
{
	// Stage

	public var name:TextField;
	public var hold:TextField;
	public var background:MovieClip;

	// Variables
	private var border;
	private var bgFill;

	private var __width;
	private var __height;

	// Init

	public function MainListEntry()
	{
		super();

		border = background.border;
		bgFill = background.background;
	}

	// Public Functions

	// @override BasicListEntry
	public function initialize(a_index:Number, a_list:BasicList):Void
	{
		__width = _width;
		__height = _height;
	}

	// @override BasicListEntry
	public function setEntry(a_entryObject:Object, a_state:ListState):Void
	{
		var selected = a_entryObject == a_state.list.selectedEntry;
		enabled = a_entryObject.enabled;
		name.text = a_entryObject.name;
		hold.text = a_entryObject.location;

		if (selected) {
			_alpha = enabled ? 100 : 25;

			_width = __width;
			_height = __height;
			TweenLite.to(this,0.2,{_width:__width + 2, _height:__height + 2});
		} else {
			_alpha = enabled ? 60 : 15;
			TweenLite.to(this,0.2,{_width:__width, _height:__height});
		}
	}
}