
import BottomBar;

class BottomBarEX extends MovieClip {

	public var bottomBar: BottomBar;
	
	private var _playerInfoObj: Object;
		
	public function BottomBarEX() {
		super();
	}

	public function onLoad()
	{
		var infoCard = bottomBar.playerInfoCard;
		infoCard.gotoAndStop("Barter");
		SetLabelOverrides()
	}

	public function updateBarterInfo(a_playerUpdateObj: Object, a_itemUpdateObj: Object, a_playercoins: Number, a_fillyrank: Number): Void
	{
		_playerInfoObj = a_playerUpdateObj; // TODO: figure out what update object may be

		var infoCard = bottomBar.playerInfoCard;
		infoCard.gotoAndStop("Barter");
		SetLabelOverrides()

		infoCard.CarryWeightValue.textAutoSize = "shrink";
		infoCard.CarryWeightValue.SetText(Math.ceil(_playerInfoObj.encumbrance) + "/" + Math.floor(_playerInfoObj.maxEncumbrance));

		// using vendor panel for displaying filly rank
		infoCard.VendorGoldLabel.textAutoSize = "shrink";
		infoCard.VendorGoldLabel.SetText("$SLUTS_FillyRank");

		updateBarterPriceInfo(a_playercoins, a_fillyrank, a_itemUpdateObj);
	}

	public function updateBarterPriceInfo(a_playercoins: Number, a_fillyrank: Number, a_itemUpdateObj: Object, a_goldDelta: Number): Void
	{
		var infoCard = bottomBar.playerInfoCard;

		infoCard.PlayerGoldValue.textAutoSize = "shrink";
		if (a_goldDelta == undefined) {
			infoCard.PlayerGoldValue.SetText(a_playercoins.toString(), true);
		} else if (a_goldDelta >= 0) {
			infoCard.PlayerGoldValue.SetText(a_playercoins.toString() + " <font color=\'#189515\'>(+" + a_goldDelta.toString() + ")</font>", true);
		} else {
			infoCard.PlayerGoldValue.SetText(a_playercoins.toString() + " <font color=\'#FF0000\'>(" + a_goldDelta.toString() + ")</font>", true);
		}

		infoCard.VendorGoldValue.textAutoSize = "shrink";
		infoCard.VendorGoldValue.SetText(a_fillyrank.toString());

		infoCard.VendorGoldLabel._x = infoCard.VendorGoldValue._x + infoCard.VendorGoldValue.getLineMetrics(0).x - infoCard.VendorGoldLabel._width;
		infoCard.PlayerGoldValue._x = infoCard.VendorGoldLabel._x + infoCard.VendorGoldLabel.getLineMetrics(0).x - infoCard.PlayerGoldValue._width - 10;
		infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width;
		infoCard.CarryWeightValue._x = infoCard.PlayerGoldLabel._x + infoCard.PlayerGoldLabel.getLineMetrics(0).x - infoCard.CarryWeightValue._width - 5;
		infoCard.CarryWeightLabel._x = infoCard.CarryWeightValue._x + infoCard.CarryWeightValue.getLineMetrics(0).x - infoCard.CarryWeightLabel._width;

		bottomBar.updateBarterPerItemInfo(a_itemUpdateObj);
	}

	private function SetLabelOverrides()
	{
		var infoCard = bottomBar.playerInfoCard;
		infoCard.PlayerGoldLabel.textAutoSize = "shrink";
		infoCard.PlayerGoldLabel.SetText("$SLUTS_FillyCoins");

		infoCard.VendorGoldLabel.textAutoSize = "shrink";
		infoCard.VendorGoldLabel.SetText("$SLUTS_FillyRank");
	}
}
