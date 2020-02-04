/*
	SXP_CBRN_fnc_getProtectionValue
	Author: Superxpdude
	Returns the protection value for a unit

	Called in the EachFrame event handler. Needs to be extra fast.
	
	Parameters:
		0: Object - Unit to calculate protection value for
		
	Returns: Array
		0: Number - Flat protection value of unit
		1: Number - Percentage resistance of unit
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

/*
	PROTECTION VALUES:
	
	Filtered mask provides 10/20%.
	Unfiltered mask provides 10/0%.
	Mask with air provides 30/50%.
	Mask with CSAT suit provides 30/50%.
	CBRN or CSAT suits provide 20/10%.
	
	Total max protection is 50/60%. (At a hazard of 1 you take 0.2 damage).
*/

#define FILTERED_MASK_PROTECTION [0.1,0.2]
#define MASK_PROTECTION [0.1,0]
#define MASK_AIR_PROTECTION [0.3,0.5]
#define CBRN_SUIT_PROTECTION [0.2,0.1]
#define FACEMASK_PROTECTION [0,0.1]
#define NO_PROTECTION [0,0]

private _csatUniforms = [];
private _cbrnBackpacks = [
	"B_CombinationUnitRespirator_01_F",
	"B_SCBA_01_F"
];

// Mask protection values
private _maskPro = switch (toLower (goggles _unit)) do {
	// CSAT masks (with filter)
	case "g_airpurifyingrespirator_02_black_f";
	case "g_airpurifyingrespirator_02_olive_f";
	case "g_airpurifyingrespirator_02_sand_f";
	// NATO mask (with filter)
	case "g_airpurifyingrespirator_01_f": {
		// Mask with filter means no air hose connected
		if ((uniform _unit) in _csatUniforms) then {
			// Mask with CSAT uniform (CBRN protected)
			MASK_AIR_PROTECTION
		} else {
			// Mask only
			FILTERED_MASK_PROTECTION
		};
	};
	// CSAT masks (no filter)
	case "g_airpurifyingrespirator_02_black_nofilter_f";
	case "g_airpurifyingrespirator_02_olive_nofilter_f";
	case "g_airpurifyingrespirator_02_sand_nofilter_f";
	// NATO mask (no filter)
	case "g_airpurifyingrespirator_01_nofilter_f";
	case "g_regulatormask_f": {
		if ((backpack _unit) in _cbrnBackpacks) do {
			// Unit has CBRN backpack
			private _backpackTextures = getObjectTextures (backpackContainer _unit)
		} else {
			// No CBRN backpack
			MASK_PROTECTION
		};
	};
	case "g_respirator_blue_f";
	case "g_respirator_white_f";
	case "g_respirator_yellow_f": {FACEMASK_PROTECTION}; // Super basic protection for face masks
	default {NO_PROTECTION};
};

// Uniform protection values
switch (toLower (uniform player)) do {
	case "u_c_cbrn_suit_01_blue_f": {_uniPro = 0.2; _uniResist = 0.3;};
	default {NO_PROTECTION};
};

if ((uniform player) in _cbrnUniforms) then {
	_protection = _protection + _uniformProtection;
};

if ((goggles player) in _cbrnMasks) then {
	_protection = _protection + _maskProtection;
};

_protection