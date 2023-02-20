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

// If the unit is null, return 0,0
if (isNull _unit) exitWith {[0,0]};

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

// List of CBRN protected CSAT uniforms (the ones with the air unit on the upper back). Viper uniforms not included.
// THESE LISTS ARE CASE-SENSITIVE FOR PERFORMANCE
private _csatUniforms = [
	"U_O_CombatUniform_ocamo",
	"U_O_CombatUniform_oucamo",
	"U_O_SpecopsUniform_ocamo",
	"U_O_GhillieSuit",
	"U_O_T_Soldier_F",
	"U_O_T_Sniper_F",
	"tmtm_u_csatFatigues_atacsAu",
	"tmtm_u_csatFatigues_atacsFg",
	"tmtm_u_csatFatigues_black",
	"tmtm_u_csatFatigues_blue",
	"tmtm_u_csatFatigues_emr",
	"tmtm_u_csatFatigues_grey",
	"tmtm_u_csatFatigues_greyBlack",
	"tmtm_u_csatFatigues_ldf",
	"tmtm_u_csatFatigues_mtp",
	"tmtm_u_csatFatigues_multicam",
	"tmtm_u_csatFatigues_natoWdl",
	"tmtm_u_csatFatigues_surpat",
	"tmtm_u_csatFatigues_yellow"
];

private _cbrnUniforms = _csatUniforms + [
	"tmtm_u_granit_cbrn",
	"tmtm_u_granit_cbrnBlackAlt",
	"tmtm_u_granit_cbrnBlack",
	"U_I_E_CBRN_Suit_01_EAF_F",
	"U_I_CBRN_Suit_01_AAF_F",
	"U_B_CBRN_Suit_01_Wdl_F",
	"U_C_CBRN_Suit_01_White_F",
	"U_B_CBRN_Suit_01_Tropic_F",
	"U_B_CBRN_Suit_01_MTP_F",
	"U_C_CBRN_Suit_01_Blue_F"
];

// CBRN protected backpacks. Includes radio backpacks for use by squad leaders 
private _cbrnBackpacks = [
	"B_CombinationUnitRespirator_01_F",
	"B_SCBA_01_F",
	"B_RadioBag_01_black_F",
	"B_RadioBag_01_digi_F",
	"B_RadioBag_01_eaf_F",
	"B_RadioBag_01_ghex_F",
	"B_RadioBag_01_hex_F",
	"B_RadioBag_01_mtp_F",
	"B_RadioBag_01_tropic_F",
	"B_RadioBag_01_oucamo_F",
	"B_RadioBag_01_wdl_F",
	"TMTM_B_RadioBag_01_darkgreen_b",
	"TMTM_B_RadioBag_01_winter_b"
];

// Mask protection values
private _maskPro = switch (toLower (goggles _unit)) do {
	// CSAT masks (with filter)
	case "g_airpurifyingrespirator_02_black_f";
	case "g_airpurifyingrespirator_02_olive_f";
	case "g_airpurifyingrespirator_02_sand_f";
	// NATO mask (with filter)
	case "g_airpurifyingrespirator_01_f": {
		// Check to see which protection value we use
		if (((backpack _unit) in _cbrnBackpacks) OR {(uniform _unit) in _csatUniforms}) then {
			MASK_AIR_PROTECTION
		} else {
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
		// Check to see which protection value we use
		if (((backpack _unit) in _cbrnBackpacks) OR {(uniform _unit) in _csatUniforms}) then {
			MASK_AIR_PROTECTION
		} else {
			MASK_PROTECTION
		};
	};
	// Laws of war face masks
	case "g_respirator_blue_f";
	case "g_respirator_white_f";
	case "g_respirator_yellow_f": {FACEMASK_PROTECTION}; // Super basic protection for face masks
	default {NO_PROTECTION};
};

// Uniform protection values
private _uniformPro = if ((uniform player) in _cbrnUniforms) then {CBRN_SUIT_PROTECTION} else {NO_PROTECTION};

private _protection = [(_maskPro select 0) + (_uniformPro select 0),(_maskPro select 1) + (_uniformPro select 1)];

_protection;