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

private _csatUniforms = [
	"U_O_CombatUniform_ocamo",
	"U_O_CombatUniform_oucamo",
	"U_O_SpecopsUniform_ocamo",
	"U_O_GhillieSuit",
	"U_O_T_Soldier_F",
	"U_O_T_Sniper_F"
];
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
		if ((backpack _unit) in _cbrnBackpacks) then {
			// Unit has CBRN backpack
			private _backpackTextures = getObjectTextures (backpackContainer _unit);
			// Check if the hose is connected
			if ((_backpackTextures select 1 != "") OR (_backpackTextures select 2 != "")) then {
				// Hose connected
				MASK_AIR_PROTECTION
			} else {
				MASK_PROTECTION
			};
		} else {
			// No CBRN backpack
			MASK_PROTECTION
		};
	};
	// CBRN mod masks. These don't support hose textures.
	case "g_cbrn_m04";
	case "g_cbrn_m04_hood";
	case "g_cbrn_m50";
	case "g_cbrn_m50_hood";
	case "g_cbrn_s10": {
		if ((backpack _unit) in _cbrnBackpacks) then {
			MASK_AIR_PROTECTION
		} else {
			// No CBRN backpack
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
private _uniformPro = switch (toLower (uniform player)) do {
	case "tg_u_gorka_cbrn";
	case "tg_u_gorka_cbrn_black_alt";
	case "tg_u_gorka_cbrn_black";
	case "u_o_combatuniform_ocamo";
	case "u_o_combatuniform_oucamo";
	case "u_o_specopsuniform_ocamo";
	case "u_o_ghilliesuit";
	case "u_o_t_soldier_f";
	case "u_o_t_sniper_f";
	case "u_i_e_cbrn_suit_01_eaf_f";
	case "u_i_cbrn_suit_01_aaf_f";
	case "u_b_cbrn_suit_01_wdl_f";
	case "u_c_cbrn_suit_01_white_f";
	case "u_b_cbrn_suit_01_tropic_f";
	case "u_b_cbrn_suit_01_mtp_f";
	case "u_c_cbrn_suit_01_blue_f": {CBRN_SUIT_PROTECTION};
	default {NO_PROTECTION};
};

private _protection = [(_maskPro select 0) + (_uniformPro select 0),(_maskPro select 1) + (_uniformPro select 1)];

_protection