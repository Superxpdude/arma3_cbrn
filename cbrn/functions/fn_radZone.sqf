/*
	SXP_rad_fnc_radZone
	Author: Superxpdude
	Defines a radiation zone.

	Must be called from the activation field of a trigger.
	Adds the trigger to the client's radiation process.
	
	Parameters:
		0: TRIGGER - Trigger that defines the zone
		1: NUMBER - Maximum intensity of the radiation, defined in ace blood loss per minute (players start with 100 blood)
		
	Returns:
		Nothing
*/