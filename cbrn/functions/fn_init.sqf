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

// Set some variables
SXP_CBRN_enabled = true; // Mark the script as enabled.
SXP_CBRN_lastSoundTime = 0; // cba_missiontime of the last ticking sound
SXP_CBRN_nextSoundVariation = 1; // Variation of the next ticking sound (can be +/- 20%)
SXP_CBRN_sound_enabled = true; // Sounds enabled
SXP_CBRN_nextPPTime = 0;

// Set up our post-process effects
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
};

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

// We need to spawn a thread for the process to keep looping. This only needs to be run on clients.
if (hasInterface) then {
	[] spawn SXP_CBRN_fnc_process;
};