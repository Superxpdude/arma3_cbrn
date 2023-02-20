/*
	SXP_CBRN_fnc_updateProtectionValue
	Author: Superxpdude
	Re-calculates the CBRN protection value for a unit.

	Called from a CBA "loadout" player event handler.
	
	Parameters:
		0: Object - Player unit
		1: Array - New unit loadout
		2: Array - Old unit loadout, will be an empty array on retroactive execution
		
	Returns:
		None
*/

params [
	["_unit", objNull, [objNull]],
	["_newLoadout", nil, [[]], 10],
	["_oldLoadout", nil, [[]], [0,10]]
];

private _fn_compareFacewear = {
	params ["_new", "_old"];
	if ((_new # 7) == (_old # 7)) then {
		true
	} else {
		false
	};
};

private _fn_compareBackpack = {
	params ["_new", "_old"];
	if ((count (_new # 5) == count (_old # 5)) AND {(_new # 5 # 0) == (_old # 5 # 0)}) then {
		true
	} else {
		false
	};
};

private _fn_compareUniform = {
	params ["_new", "_old"];
	if ((count (_new # 3) == count (_old # 3)) AND {(_new # 3 # 0) == (_old # 3 # 0)}) then {
		true
	} else {
		false
	};
};

// Check if any parts of the loadout that we care about have changed
if (
	((count _oldLoadout) == 0) OR // No old loadout
	{!(([_newLoadout, _oldLoadout] call _fn_compareFacewear) AND // Facewear/mask
	{([_newLoadout,_oldLoadout] call _fn_compareBackpack) AND  // Backpack
	{[_newLoadout,_oldLoadout] call _fn_compareUniform}})} // Uniform
) then {
	SXP_CBRN_protection = [player] call SXP_CBRN_fnc_getProtectionValue;
};
