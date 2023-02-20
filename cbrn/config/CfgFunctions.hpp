// CfgFunctions
class SXP_CBRN
{
	class functions
	{
		file = "cbrn\functions";
		class eachFrame {}; // eachFrame event handler calculations
		class enterZone {}; // Enter CBRN zone
		class getProtectionValue {}; // Return the protection value of equipped gear
		class init {preInit = 1;}; // CBRN init
		class updateProtectionValue {}; // Updates current protection value on inventory change
	};
};