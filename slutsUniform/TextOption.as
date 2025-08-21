import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;
import com.greensock.*;
import com.greensock.easing.*;

import slutsUniform.Option;

class slutsUniform.TextOption extends Option
{
	public var textfield:TextField;

	public function TextOption()
	{
		super();
	}

	public function initialize(text, isEnabled, isSelected):Void
	{
		enabled = isEnabled;
		textfield.text = text;
    setSelected(isSelected);
		setHovered(false);
	}
}