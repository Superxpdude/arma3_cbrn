/*
	SXP_CBRN_fnc_process
	Author: Superxpdude
	The looping process for the CBRN system

	Spawned by SXP_CBRN_fnc_init on mission start. Runs forever.
	
	Parameters:
		None
		
	Returns:
		Nothing
*/
// Only run this on clients with players
if (!hasInterface) exitWith {};

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

// Turn on the chemical detector UI
"SXP_CBRN_DETECTOR" cutRsc ["RscWeaponChemicalDetector", "PLAIN", 1, false];

SXP_CBRN_eh = addMissionEventHandler ["EachFrame", {
	// Set some variables
	private _hazard = 0; // Maximum hazard for this loop
	private _zones = + (player getVariable ["SXP_CBRN_player_areas", []]); // Copy the array so that we can modify the original
	private _damage = 0; // Damage for this loop
	private _detectorUI = uiNamespace getVariable "RscWeaponChemicalDetector";
	private _detectorObj = _detectorUI displayCtrl 101;
	private _dps = ((getMissionConfigValue ["SXP_CBRN_damagePerMinute", 0.48]) param [0,0.48,[0]])/60; // Calculate the damage per second value of a maximum hazard zone
	
	{
		if (player inArea _x) then {
			// Player in CBRN area
			private _zoneIntensity = _x getVariable ["SXP_CBRN_intensity", 0];
			private _zoneIntenseRange = _x getVariable ["SXP_CBRN_intenserange", 0];
			private _zoneRange = ((triggerArea _x) select 0) max ((triggerArea _x) select 1);
			private _zoneHazard = 0;
			private _distance = player distance2D _x;
			// TODO: Rewrite this to use linearConversion
			// _zoneHazard = linearConversion [_zoneIntenseRange,_zoneRange,_distance,_zoneIntensity,0,true];
			if (_distance <= _zoneIntenseRange) then {
				// Player in max intensity range
				_zoneHazard = _zoneIntensity;
			} else {
				// Player in falloff range
				_zoneHazard = (((_distance - _zoneIntenseRange) / -(_zoneRange - _zoneIntenseRange)) + 1) * _zoneIntensity;
			};
			
			// If this zone has the highest hazard this loop, set it as the loop hazard
			if (_zoneHazard > _hazard) then {
				_hazard = _zoneHazard;
			};
		} else {
			// Player not in CBRN area
			player setVariable ["SXP_CBRN_player_areas", (player getVariable ["SXP_CBRN_player_areas", []]) - [_x], true];
		};
	} forEach _zones;
	
	private _hazardDisplay = (ceil (_hazard * 1000)) / 100;
	
	// CHEMICAL DETECTOR SECTION
	_detectorObj ctrlAnimateModel ["Threat_Level_Source", _hazardDisplay min 9.99, true]; // Might need to use 'toFixed' and 'parseNumber' here
	
	// Sound section
	if (("ChemicalDetector_01_watch_F" in (assignedItems player)) AND {SXP_CBRN_sound_enabled AND {_hazard > 0.1}}) then {
		if ((cba_missionTime - SXP_CBRN_lastSoundTime) > (((1/((8 * _hazard)-0.6)) - 0.125) * SXP_CBRN_nextSoundVariation)) then {
			//linearConversion [0.1,0.9,_hazard,2,0.02,true]
			// Play the sound
			playSound "sxp_cbrn_tick";
			// Set the last sound time, and figure out our next variation
			SXP_CBRN_lastSoundTime = cba_missionTime;
			SXP_CBRN_nextSoundVariation = 0.8 + (random 0.4);
		};
	};
	
	// Damage section
	private _protection = [player] call SXP_CBRN_fnc_getProtectionValue;
	private _playerHazard = ((_hazard - (_protection select 0)) max 0) * (1 - (_protection select 1)); // Maximum hazard value with the player resistances applied
	private _damage = (_dps/diag_fps) * _playerHazard;
	player setVariable ["ace_medical_bloodVolume", (player getVariable ["ace_medical_bloodVolume", 6]) - _damage];
	
	if (SXP_CBRN_nextPPTime < cba_missionTime) then {
		// Set visual effect
		SXP_CBRN_pp_handle ppEffectAdjust [_playerHazard];
		SXP_CBRN_pp_handle ppEffectCommit 5;
		SXP_CBRN_nextPPTime = cba_missionTime + 1;
	};
}];