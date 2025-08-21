import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.utils.Delegate;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

class slutsUniform.Main extends MovieClip
{
	public static var BLACK_IDX = 0;
	public static var BLUE_IDX = 1;
	public static var PINK_IDX = 2;
	public static var RED_IDX = 3;
	public static var WHITE_IDX = 4;
	public static var COLOR_SELECTED_IDX = 5;

	public var background:MovieClip;

	public var colorBlack:MovieClip;
	public var colorBlue:MovieClip;
	public var colorPink:MovieClip;
	public var colorRed:MovieClip;
	public var colorWhite:MovieClip;
	public var blindfold:MovieClip;
	public var harness:MovieClip;

	private var colors:Array;
	private var colorIdx:Number;
	private var extraIdx:Number;
	private var activeSelection:MovieClip;

	public function Main()
	{
		super();
		Mouse.addListener(this);
		FocusHandler.instance.setFocus(this, 0);

		colors = [colorBlack, colorBlue, colorPink, colorRed, colorWhite];
		colorIdx = 0;
		extraIdx = 0;
		activeSelection = null;
	}

	public function onLoad()
	{
		_global.gfxExtensions = true;
		
		var minXY: Object = {x: Stage.visibleRect.x + Stage.safeRect.x, y: Stage.visibleRect.y + Stage.safeRect.y};
    var maxXY: Object = {x: Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x, y: Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};

    //  (minXY.x, minXY.y) _____________ (maxXY.x, minXY.y)
    //                    |             |
    //                    |     THE     |
    //                    |    STAGE    |
    //  (minXY.x, maxXY.y)|_____________|(maxXY.x, maxXY.y)

		_x = maxXY.x / 2;
		_y = maxXY.y / 2;
		_height = (maxXY.y - minXY.y) * 0.3472;
		_width = _height * 2.56;

		// var randomColors:Array = [];
		// for (var i:Number = 0; i < 5; i++) {
		// 	randomColors.push(true);
		// }
		// randomColors.push(2);
		// initializeColors.apply(this, randomColors);
		// initializeGear(true, false, true, true);

		setActiveSelection(colors[colorIdx]);
	}

	public function initializeColors(/* args */)
	{
		var colorColors = [0x000000, 0x0000FF, 0xFF00FF, 0xFF0000, 0xFFFFFF]
		for (var i:Number = 0; i < colors.length; i++) {
			colors[i].initialize(colorColors[i], arguments[i], arguments[COLOR_SELECTED_IDX] == i);
		}
	}

	public function initializeGear(blindfoldEnabled, blindfoldUsed, harnessEnabled, harnessUsed)
	{
		blindfold.initialize("$SLUTS_UseBlindfold", blindfoldEnabled, blindfoldUsed);
		harness.initialize("$SLUTS_UseHarness", harnessEnabled, harnessUsed);
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (!GlobalFunc.IsKeyPressed(details)) {
			return false;
		}
		switch (details.navEquivalent) {
		case NavigationCode.LEFT:
		case NavigationCode.RIGHT:
			if (activeSelection == blindfold) {
				setActiveSelection(harness)
				extraIdx = 1;
			} else if (activeSelection == harness) {
				setActiveSelection(blindfold)
				extraIdx = 0;
			} else {
				if (details.navEquivalent == NavigationCode.LEFT) {
					setActiveSelection(colors[(colorIdx - 1 + colors.length) % colors.length]);
				} else if (details.navEquivalent == NavigationCode.RIGHT) {
					setActiveSelection(colors[(colorIdx + 1) % colors.length]);
				}
				colorIdx = indexOf(colors, activeSelection);
			}
			break;
		case NavigationCode.UP:
		case NavigationCode.DOWN:
			if (activeSelection == blindfold || activeSelection == harness) {
				setActiveSelection(colors[colorIdx]);
			} else {
				setActiveSelection(extraIdx == 0 ? blindfold : harness);
			}
			break;
		case NavigationCode.ENTER:
			toggleSelection(activeSelection);
			break;
		case NavigationCode.TAB:
		case NavigationCode.BACK:
		case NavigationCode.ESCAPE:
			// Handle back and escape navigation
			var colorIdx:Number = -1;
			for (var i:Number = 0; i < colors.length; i++) {
				if (colors[i].isSelected())
					colorIdx = i;
			}
			var blindfoldIdx = blindfold.isSelected() ? 1 : 0;
			var harnessIdx = harness.isSelected() ? 1 : 0;
			var selectionString = colorIdx + "," + blindfoldIdx + "," + harnessIdx;
			trace("Selection: " + selectionString);
			skse.SendModEvent("SLUTS_CustomSelection", selectionString, 0, 0);
			break;
		default:
			trace("Unhandled navigation code: " + details.navEquivalent);
			return false;
		}
		return true;
	}

	private function setActiveSelection(selection: MovieClip): Void
	{
		if (activeSelection != null) {
			activeSelection.setHovered(false);
		}
		activeSelection = selection;
		if (selection == null) {
			return;
		}
		activeSelection.setHovered(true);
	}

	public function toggleSelection(selection: MovieClip): Void
	{
		if (!selection.enabled) {
			return;
		}
		var colorIdx = indexOf(colors, selection);
		if (colorIdx != -1) {
			for (var i:Number = 0; i < colors.length; i++) {
				if (i != colorIdx) {
					colors[i].setSelected(false);
				}
			}
		}
		selection.setSelected(!selection.isSelected());
	}

	private function indexOf(array: Array, item: MovieClip): Number
	{
		for (var i:Number = 0; i < array.length; i++) {
			if (array[i] == item) {
				return i;
			}
		}
		return -1; // Not found
	}

}