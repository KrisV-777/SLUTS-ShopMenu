import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;
import com.greensock.*;
import com.greensock.easing.*;

import slutsUniform.Option;

class slutsUniform.ColorOption extends Option
{
	public function ColorOption()
	{
		super();
	}

	public function initialize(color, isEnabled, isSelected):Void
	{
		enabled = isEnabled;
		var colorTransform:Color = new Color(fill);
		colorTransform.setRGB(color);
		// Determine if the color is light by checking its brightness
		var r = (color >> 16) & 0xFF;
		var g = (color >> 8) & 0xFF;
		var b = color & 0xFF;
		var brightness = (r * 299 + g * 587 + b * 114) / 1000;
		var borderColor:Color = new Color(border);
		trace("Color brightness: " + brightness);
		if (brightness > 200) {
			borderColor.setRGB(0x000000); // black border for light colors
		} else {
			borderColor.setRGB(0xAAAAAA); // grey border for dark colors
		}
    setSelected(isSelected);
		setHovered(false);
	}
}