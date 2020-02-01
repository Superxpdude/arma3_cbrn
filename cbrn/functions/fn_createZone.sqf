/*
	SXP_CBRN_fnc_createZone
	Author: Superxpdude
	Configures a trigger for the CBRN script

	Call from initServer.sqf.
	Configures the trigger to work as a CBRN zone.
	Only runs on the server.
	
	Parameters:
		0: TRIGGER - Trigger that defines the zone. Trigger must be circular, with no height limit, and identical X/Y dimensions.
		1: NUMBER - Maximum intensity of the zone. From 0 to 1. 1 means maximum damage rate when at full effect.
		2: NUMBER - Falloff distance. Players within this distance will take full effect, otherwise the effect scales linearly from the falloff distance to the trigger distance.
		
	Returns:
		Nothing
*/

// Only run on the server
if (!isServer) exitWith {};

params [
	["_trigger", objNull, [objNull]],
	["_intensity", -1, [0]],
	["_falloff", -1, [0]]
];

if (isNull _trigger) exitWith {};
if (_intensity < 0) exitWith {};
if (_falloff < 0) then {_falloff = ((triggerArea _trigger) select 0) min ((triggerArea _trigger) select 1)};

_trigger setVariable ["SXP_CBRN_active", true, true];
_trigger setVariable ["SXP_CBRN_intensity", _intensity, true];
_trigger setVariable ["SXP_CBRN_falloff", _falloff, true];