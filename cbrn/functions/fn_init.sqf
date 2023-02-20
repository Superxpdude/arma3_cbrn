/*
	SXP_CBRN_fnc_init
	Author: Superxpdude
	Initializes the radiation system on all machines

	Needs to be executed on all clients at mission start.
	By default this is executed in preInit.
	
	Parameters:
		None
		
	Returns:
		Nothing
*/

/*
	ACE Blood Info
	Players start at 6 litres of blood.
	ACE3 uses the following thresholds
		6.0 - Less than 15% loss
		5.1 - More than 15% loss
		4.2 - More than 30% loss
		3.6 - More than 40% loss
		3.0 - More than 50% loss. Unrecoverable without a blood IV
	Going below 3.6 will result in unconsciousness
	Default value will put the player down to 3.6 in 10 minutes if unprotected
*/

// Set some variables
SXP_CBRN_enabled = true; // Mark the script as enabled.
SXP_CBRN_lastSoundTime = 0; // cba_missiontime of the last ticking sound
SXP_CBRN_nextSoundVariation = 1; // Variation of the next ticking sound (can be +/- 20%)
SXP_CBRN_sound_enabled = true; // Sounds enabled
SXP_CBRN_nextPPTime = 0; // Next post-process change time

SXP_CBRN_true_hazard = 0; // Current "true" hazard level for the player, before resistances.
SXP_CBRN_player_hazard = 0; // Current "effective" hazard for the player, after resistances.

SXP_CBRN_eachFrameEH = -1;
SXP_CBRN_inventoryEH = -1;

SXP_CBRN_protection = [0,0]; // Current player protection

// Add CBA context menu options
[
	"ChemicalDetector_01_watch_F", 
	"WATCH", 
	"Enable Sounds", 
	nil, 
	nil,
	{!SXP_CBRN_sound_enabled},
	{
        SXP_CBRN_sound_enabled = true;
        false
    }, 
	false
] call CBA_fnc_addItemContextMenuOption;

[
	"ChemicalDetector_01_watch_F", 
	"WATCH", 
	"Disable Sounds", 
	nil, 
	nil,
	{SXP_CBRN_sound_enabled},
	{
        SXP_CBRN_sound_enabled = false;
        false
    }, 
	false
] call CBA_fnc_addItemContextMenuOption;

// Only run this part on clients with an interface
if (hasInterface) then {
	private _priority = 400;
	while {
		SXP_CBRN_pp_handle = ppEffectCreate ["DynamicBlur", _priority];
		SXP_CBRN_pp_handle < 0
	} do {
		_priority = _priority + 1;
	};
	SXP_CBRN_pp_handle ppEffectEnable true;
	SXP_CBRN_pp_handle ppEffectAdjust [0];
	SXP_CBRN_pp_handle ppEffectCommit 0;
	
	// Add our inventory update event handler
	SXP_CBRN_inventoryEH = ["loadout", SXP_CBRN_fnc_updateProtectionValue, true] call CBA_fnc_addPlayerEventHandler;
	
	// Turn on the chemical detector UI
	"SXP_CBRN_DETECTOR" cutRsc ["RscWeaponChemicalDetector", "PLAIN", 1, false];

	SXP_CBRN_eachFrameEH = addMissionEventHandler ["EachFrame", SXP_CBRN_fnc_eachFrame];
};
