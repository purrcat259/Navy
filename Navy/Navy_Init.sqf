#include "Navy_Macros.h"

Navy_PreInit =
{
	if (Navy_WaitForHull3) then
	{
		WAIT(hull3_isInitialized);
	};
	// Wait for Admiral AI Suite to finish initialising
	WAIT(sleep 0.5; adm_isInitialized);
	// Make sure the admiral API command for running on HC is available
	WAIT(!isNil "adm_api_fnc_executeIfAdmiralMachine");
	if (Navy_RunOnHC) then
	{
		[[],Navy_Init] call adm_api_fnc_executeIfAdmiralMachine;
	}
	else
	{
		RUN_ON_SERVER
		{
			[] call Navy_Init;
		};
	};
};

Navy_Init_Variables =
{
	Navy_Units = [];
	Navy_Unit_Counter = 0;
	Navy_Vehicles = [];
	Navy_Vehicle_Counter = 0;
};

Navy_Init =
{
	Navy_Initialised = false;
	[] call Navy_Init_Variables;
	PRECOMPILE("Navy\Navy_Settings.sqf");
	// Turn Debug off in multiplayer settings
	if (isMultiplayer && !DEBUG_MULTIPLAYER) then
	{
		Navy_Debug = false;
	};
	// Compile Debug functions only if debug is enabled
	DEBUG
	{
		PRECOMPILE("Navy\Navy_Debug.sqf");
		[] call Navy_Debug_Init;
	};
	PRECOMPILE("Navy\Navy_General.sqf");
	PRECOMPILE("Navy\Navy_Vehicles.sqf");
	PRECOMPILE("Navy\Navy_Routines.sqf");
	Navy_Initialised = true;
	publicVariable "Navy_Initialised";
};