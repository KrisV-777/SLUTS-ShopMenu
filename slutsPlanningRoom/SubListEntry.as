import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import skyui.components.list.BasicList;
import flash.geom.ColorTransform;
import com.greensock.*;
import com.greensock.easing.*;

class slutsPlanningRoom.SubListEntry extends BasicListEntry
{
	// Stage

	public var name:TextField;
	public var selectIndicator:MovieClip;
	public var background:MovieClip;
	public var border:MovieClip;

	// Variables

	private var _selected

	// Init

	public function SubListEntry()
	{
		super();
		_selected = false;
	}

	// Public Functions

	// @override BasicListEntry
	public function initialize(a_index:Number, a_list:BasicList):Void
	{
		isEnabled = false;
		enabled = true;
	}

	// @override BasicListEntry
	public function setEntry(a_entryObject:Object, a_state:ListState):Void
	{
		name.text = a_entryObject.type;
		_selected = a_entryObject == a_state.list.selectedEntry;
		var allowedTypes = a_state.list["allowedTypes"];
		var allowedIdx = allowedTypes.indexOf(a_entryObject.type);
		enabled = isEnabled = allowedIdx != undefined;

		selectIndicator.clear();
		selectIndicator._visible = true;
		var activeIdx = a_state.list["activeTypes"].indexOf(a_entryObject.type);
		var active = activeIdx != undefined && activeIdx != -1;
		var color = active ? 0x1cd5a3 : 0xC70039;
		var gradientType = "linear";
		var colors = [color, color];
		var alphas = [90, 0];
		var ratios = [0, 255];
		var matrix = {matrixType: "box", x: selectIndicator._x + 1, y: selectIndicator._y, w: selectIndicator._width, h: selectIndicator._height, r: 0};
		selectIndicator.beginGradientFill(gradientType,colors,alphas,ratios,matrix);
		selectIndicator.moveTo(matrix.x,matrix.y);
		selectIndicator.lineTo(matrix.x + matrix.w,matrix.y);
		selectIndicator.lineTo(matrix.x + matrix.w,matrix.y + matrix.h);
		selectIndicator.lineTo(matrix.x,matrix.y + matrix.h);
		selectIndicator.lineTo(matrix.x,matrix.y);
		selectIndicator.endFill();

		if (_selected) {
			_alpha = enabled ? 100 : 25;
		} else {
			_alpha = enabled ? 60 : 15;
		}
	}

}