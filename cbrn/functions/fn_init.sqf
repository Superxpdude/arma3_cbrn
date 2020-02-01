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
SXP_CBRN_enabled = true; // Mark the script as enabled. This can be used to kill the rad loop later on

// We need to spawn a thread for the process to keep looping. This only needs to be run on clients.
if (hasInterface) then {
	[] spawn SXP_CBRN_fnc_process;
};