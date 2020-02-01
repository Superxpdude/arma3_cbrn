/*
	SXP_CBRN_fnc_process
	Author: Superxpdude
	The looping process for the radiation system

	Spawned by SXP_rad_fnc_init on mission start. Runs forever.
	
	Parameters:
		None
		
	Returns:
		Nothing
*/
// Only run this on clients with players
if (!hasInterface) exitWith {};

private _tickRate = 1; // How many seconds per tick. Increase if performance is poor.
private _damageDiv = 60 / _tickRate; // Blood loss multiplier per tick
private _bloodLossPerMin = 10; // Maximum blood loss per minute (unprotected)

// Turn on the chemical detector UI
"SXP_CBRN_DETECTOR" cutRsc ["RscWeaponChemicalDetector", "PLAIN", 1, false];
// Make sure we can access the detector
private _detectorUI = uiNamespace getVariable "RscWeaponChemicalDetector";
private _detectorObj = _detectorUI displayCtrl 101;

// Start our loop
while {SXP_CBRN_enabled} do {

	/*
	// Check if we have any active zones
	if ((count SXP_rad_active_zones) > 0) then {
		// If we have active zones, iterate through them
		private _activeZones = + SXP_rad_active_zones; // Copy the array so that we can modify it
		private _damage = 0; // Damage to be dealt at the end of the loop. Multiple zones do not stack.
		{
			// Check if the unit is still in the trigger
			if (_unit inArea (_x select 0)) then {
				
			} else {
				// If not, remove the trigger from the active zones list
			};
		} forEach _activeZones
	*/	
	
	// Set some variables
	private _hazard = 0; // Maximum hazard for this loop
	private _zones = + (player getVariable ["SXP_CBRN_player_areas", []]); // Copy the array so that we can modify the original
	private _damage = 0; // Damage for this loop
	
	{
		if (player inArea _x) then {
			// Player in CBRN area
			private _zoneIntensity = _x getVariable ["SXP_CBRN_intensity", 0];
			private _zoneIntenseRange = _x getVariable ["SXP_CBRN_intenserange", 0];
			private _zoneRange = ((triggerArea _x) select 0) max ((triggerArea _x) select 1);
			private _zoneHazard = 0;
			private _distance = player distance2D _x;
			if (_distance <= _zoneIntenseRange) then {
				// Player in max intensity range
				_zoneHazard = _zoneIntensity;
			} else {
				// Player in falloff range
				_zoneHazard = ((_distance - _zoneIntenseRange) / (_zoneRange - _zoneIntenseRange)) * _zoneIntensity;
			};
			
			// If this zone has the highest hazard this loop, set it as the loop hazard
			if (_zoneHazard > _hazard) then {
				_hazard = _zoneHazard;
			};
		} else {
			// Player not in CBRN area
			player setVariable ["SXP_CBRN_player_areas", (player getVariable ["SXP_CBRN_player_areas", []]) - [_x], true];
		};
	} forEach _zones
	
	// CHEMICAL DETECTOR SECTION
	_detectorObj ctrlAnimateModel ["Threat_Level_Source", _hazard, true]; // Might need to use 'toFixed' and 'parseNumber' here
	
	// DAMAGE SECTION
	// Calculate damage based on hazard, and equipped gear
	// Remove a portion of the player's blood based on remaining damage

	// Wait before running again
	sleep _tickRate;
};