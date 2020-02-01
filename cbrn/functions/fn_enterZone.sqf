/*
	SXP_CBRN_fnc_enterZone
	Author: Superxpdude
	Triggered when entering a CBRN zone

	Must be called from the activation field of a trigger.
	Trigger should use the following value for the condition:
		"this && player in thisList"
	
	Trigger MUST be circular. It must have no height limit, and identical X/Y dimensions. Trigger must not be set to server only, and must be configured to activate multiple times.
	
	Parameters:
		0: TRIGGER - Trigger that defines the zone
		1: OBJECT - Player that entered the zone
		2: NUMBER - Maximum intensity of the zone. From 0 to 1. 1 means maximum damage rate when at full effect.
		3: NUMBER (OPTIONAL) - Maximum intensity radius. The area within the trigger that the maximum damage rate is applied. Damage outside of this radius is linearly scaled to the edge of the trigger.
		
	Returns:
		Nothing
*/

// This only applies to player machines
if (!hasInterface) exitWith {};

params [
	["_trigger", objNull, [objNull]],
	["_player", objNull, [objNull]],
	["_intensity", 0, [0]],
	["_intenserange", 0, [0]]
];

// Exit if the trigger or player are null
if ((isNull _trigger) or (isNull _player)) exitWith {};
// Exit if the player is not local
if (!local _player) exitWith {};
// Exit if the player is not in the trigger
if !(player in (list _trigger)) exitWith {};

// Set some variables on the trigger so that we can retrieve them later.
_trigger setVariable ["SXP_CBRN_intensity", _intensity];
_trigger setVariable ["SXP_CBRN_intenserange", _intenserange];

// Add the area to the player's area array
private _CBRNareas = _player getVariable ["SXP_CBRN_player_areas", []];
_CBRNareas pushBackUnique _trigger;
_player setVariable ["SXP_CBRN_player_areas", _CBRNareas, true];