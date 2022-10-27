class ExchangeType
{
	// 0 - Unspecified | 1 - Valuable | 2 - Gear | 3 - Licenses | 4 - Upgrades | 5 - Extras
  public static var UNSPECIFIED: Number	= 0x00000001;
  public static var VALUABLE: Number		= 0x00000002;
  public static var GEAR: Number				= 0x00000004;
	public static var LICENSE: Number			= 0x00000008;
	public static var UPGRADE: Number			= 0x00000010;
	public static var EXTRA: Number				= 0x00000020;
}