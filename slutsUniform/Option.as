import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;
import com.greensock.*;
import com.greensock.easing.*;

class slutsUniform.Option extends MovieClip
{
	public var outline:MovieClip;
	public var border:MovieClip;
	public var background:MovieClip;
	public var fill:MovieClip;

	private var __width;
	private var __height;
	public var enabled;

	public function Option()
	{
		__width = _width;
		__height = _height;
    setHovered(false);
		setSelected(false);
	}
  
  // @abstract
	public function initialize(text, isEnabled, isSelected):Void {}

  /* Public */

  public function setHovered(hovered):Void
  {
    if (hovered) {
      _alpha = enabled ? 90 : 25;
      _width = __width;
      _height = __height;
      TweenLite.to(this, 0.2, {_width: __width + 2, _height: __height + 2});
    } else {
      _alpha = enabled ? 60 : 15;
      TweenLite.to(this, 0.2, {_width: __width, _height: __height});
    }
  }

	public function setSelected(selected):Void
	{
		outline._visible = selected && true;
	}

  public function isSelected():Boolean
  {
    return outline._visible;
  }

  /* Private */

  public function onRollOver():Void
  {
    if (enabled) {
      _parent.setActiveSelection(this);
    }
  }

  public function onRollOut():Void
  {
    if (enabled) {
      _parent.setActiveSelection(null);
    }
  }

  public function onPress():Void
  {
    if (enabled) {
      _parent.toggleSelection(this);
    }
  }

}