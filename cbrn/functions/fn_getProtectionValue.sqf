/*
	SXP_CBRN_fnc_getProtectionValue
	Author: Superxpdude
	Returns the protection value for a unit

	Called in the EachFrame event handler. Needs to be extra fast.
	
	Parameters:
		0: Object - Unit to calculate protection value for
		
	Returns:
		Number - Protection value of unit
*/

params [
	["_unit", objNull, [objNull]]
];

// If the unit is null, return 0
if (isNull _unit) exitWith {0};

_uniformProtection = 0.4;
_maskProtection = 0.4;

_cbrnUniforms = [
	"U_C_CBRN_Suit_01_Blue_F",
	"U_B_CBRN_Suit_01_MTP_F",
	"U_B_CBRN_Suit_01_Tropic_F",
	"U_C_CBRN_Suit_01_White_F",
	"U_B_CBRN_Suit_01_Wdl_F",
	"U_I_CBRN_Suit_01_AAF_F",
	"U_I_E_CBRN_Suit_01_EAF_F",
	"tg_u_gorka_cbrn_black",
	"tg_u_gorka_cbrn_black_alt",
	"tg_u_gorka_cbrn"
];

_cbrnMasks = [
	"G_AirPurifyingRespirator_02_black_F",
	"G_AirPurifyingRespirator_02_olive_F",
	"G_AirPurifyingRespirator_02_sand_F",
	"G_AirPurifyingRespirator_01_F",
	"G_RegulatorMask_F",
	"G_CBRN_M04",
	"G_CBRN_M04_Hood",
	"G_CBRN_M50",
	"G_CBRN_M50_Hood",
	"G_CBRN_S10"
];

/*
	Basic face masks. Maybe give these a low protection value at some point
	G_Respirator_blue_F
	G_Respirator_white_F
	G_Respirator_yellow_F
*/

// Start with a protection of 0
private _protection = 0;


if ((uniform player) in _cbrnUniforms) then {
	_protection = _protection + _uniformProtection;
};

if ((goggles player) in _cbrnMasks) then {
	_protection = _protection + _maskProtection;
};

_protection