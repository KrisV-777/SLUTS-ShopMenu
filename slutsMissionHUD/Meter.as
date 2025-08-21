import flash.geom.ColorTransform;
import gfx.utils.Delegate;
import com.greensock.*;
import com.greensock.plugins.*;
import com.greensock.easing.*;

class slutsMissionHUD.Meter extends MovieClip
{
	/* STAGE */
	public var start:MovieClip;
	public var mid:MovieClip;
	public var end:MovieClip;

	public var div1:MovieClip;
	public var div2:MovieClip;
	public var div3:MovieClip;

	public var mask:MovieClip;
	public var maskArmor:MovieClip;
	public var fill:MovieClip;
	public var fillArmor:MovieClip;
	public var background:MovieClip;
	
	/* VARIABLES */
	private static var WIDTHPERCENT = 75 * 100;	// Ratio: {n} Health for 1% screen width?
	private static var START_RATIO = 0.2;				// How much of start is part of filling
	private static var END_RATIO = 0.38;

	private var _meterTimeline: TimelineLite;
	private var _meterDuration: Number;

	private var _greyTransform: Object;
	private var _resetTransform: Object;

	/* INIT */
	public function Meter()
	{
		super();

		_meterTimeline = new TimelineLite({_paused:true});
		_meterDuration = 0.01;

		TweenPlugin.activate([ColorTransformPlugin]);

		_greyTransform = {
				redMultiplier: 0.65,
				greenMultiplier: 0.65,
				blueMultiplier: 0.65,
				alphaMultiplier: 1
		};
		_resetTransform = {
				redMultiplier: 1,
				greenMultiplier: 1,
				blueMultiplier: 1,
				alphaMultiplier: 1
		};
	}

	public function onLoad()
	{
	}

	/* PUBLIC */
	public function arrangeObjects(seg1, seg2, seg3, hpBase, segSeal)
	{
		var myPct = mask._width / fill._width;
		var myArmor = getArmorPct();

		var stage_width = Stage.visibleRect.width;
		var fill_start = start._width * START_RATIO;
		var fill_end = end._width * END_RATIO;
		var meterstart = start._width - fill_start;

		var totalHp = hpBase + segSeal;
		var meterwidth = stage_width * (totalHp / WIDTHPERCENT);
		mid._width = meterwidth - (fill_start + fill_end);
		end._x = mid._x + mid._width;
		
		background._width = meterwidth;
		background._x = meterstart;

		var segmentwidth = stage_width * (hpBase / WIDTHPERCENT);
		var getX = function(seg) {
			var atpercental = seg / hpBase;
			var divoffset = segmentwidth * atpercental;
			var coordinates = {x: divoffset, y: 0};
			start.localToGlobal(coordinates);
			globalToLocal(coordinates);
			return coordinates.x + (start._width - fill_start);
		};
		div1._x = getX(hpBase - seg1);
		div2._x = getX(hpBase - seg2);
		div3._x = getX(hpBase - seg3);

		fill._width = Math.abs(meterstart - div1._x)
		fill._x = mask._x = meterstart;

		fillArmor._width = Math.abs(meterwidth - fill._width);
		fillArmor._x = maskArmor._x = fill._x + fill._width;

		setArmorPercent(myArmor);
		setMeterPercent(myPct);
	}	

	public function setMeterPercent(percent)
	{
		_meterTimeline.clear();
		percent = Math.min(1, Math.max(percent, 0));
		mask._width = fill._width * percent;
	}

	public function setArmorPercent(percent)
	{
		_meterTimeline.clear();
		percent = Math.min(1, Math.max(percent, 0));
		maskArmor._width = fillArmor._width * percent;
	}

	public function updateMeterPercent(percent)
	{
		// if (getArmorPct() > 0) {
		// 	updateArmorPercent(0, 0.3);
		// }
		percent = Math.min(1, Math.max(percent, 0));

		if (!_meterTimeline.isActive())
		{
			_meterTimeline.clear();
			_meterTimeline.progress(0);
			_meterTimeline.restart();
		}
		_meterTimeline.to(mask, 1, {_width: fill._width * percent}, _meterTimeline.time() + _meterDuration);
		_meterTimeline.play();
	}
	
	public function updateArmorPercent(percent)
	{
		percent = Math.min(1, Math.max(percent, 0));

		if (!_meterTimeline.isActive())
		{
			_meterTimeline.clear();
			_meterTimeline.progress(0);
			_meterTimeline.restart();
		}
		_meterTimeline.to(maskArmor, 1, {_width: fillArmor._width * percent}, _meterTimeline.time() + _meterDuration);
		TweenLite.to(fill, 0.3, {colorTransform: (percent > 0 ? _greyTransform : _resetTransform), ease:Linear.easeNone});
		_meterTimeline.play();
	}

	private function getArmorPct()
	{
		return maskArmor._width / fillArmor._width;
	}

}