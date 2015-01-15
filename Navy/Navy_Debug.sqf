#include "Navy_Macros.h"

Navy_Debug_Init =
{
	Navy_Debug_Markers = [];
	[["Navy Debug successfully initialised."]] call Navy_Debug_SideChatRPT;
};

Navy_Debug_SideChatRPT =
{
	FUN_ARGS_1(_message);
	[[_message]] call Navy_Debug_RPT;
	[[_message]] call Navy_Debug_SideChat;
};

Navy_Debug_RPT =
{
	FUN_ARGS_1(_message);
	if (DEBUG_LOGTORPT) then
	{
		diag_log format ["%1%2",DEBUG_HEADER,(format _message)];
	};
};

Navy_Debug_Hint =
{
	FUN_ARGS_2(_message,_silent);
	// _silent parameter: decided whether hint or hintSilent is used. Default is true
	if (DEBUG_HINTS) then
	{
		if (isNil "_silent") then
		{
			_silent = true;
		};
		if (_silent) then
		{
			hintSilent format ["%1%2",DEBUG_HEADER,(format _message)];
		}
		else
		{
			hint format ["%1%2",DEBUG_HEADER,(format _message)];
		};
	};
};

Navy_Debug_SideChat =
{
	FUN_ARGS_1(_message);
	if (DEBUG_SIDECHAT) then
	{
		player sideChat format ["%1%2",DEBUG_HEADER,(format _message)];
	};
};

Navy_Debug_InitMarker =
{
	FUN_ARGS_1(_unit);
	PVT_5(_vehicle_str,_marker_name,_marker_counter,_marker_colour,_marker_size);
	if ((vehicle _unit) != _unit) then
	{
		_vehicle_str = "Vehi";
		_marker_colour = DEBUG_MARKER_COLOUR_VEHICLE;
		_marker_size = DEBUG_MARKER_SIZE_VEHICLE;
		_marker_counter = Navy_Vehicle_Counter;
		INC(Navy_Vehicle_Counter);
	}
	else
	{
		_vehicle_str = "Unit";_
		_marker_colour = DEBUG_MARKER_COLOUR_UNIT;
		_marker_size = DEBUG_MARKER_SIZE_UNIT;
		_marker_counter = Navy_Unit_Counter;
		INC(Navy_Unit_Counter);
	};
	_marker_name = format ["Navy_%1_%2_%3",_vehicle,_marker_counter,_unit];
	[_marker_name,getposATL _unit,"ICON","mil_traingle_noShadow",_marker_colour,_marker_size] call adm_common_fnc_createLocalMarker;
	Navy_Debug_Markers pushBack _marker_name;
	_marker_name;
};

Navy_Debug_RemoveMarker =
{
	FUN_ARGS_1(_marker_name);
	Navy_Debug_Markers = Navy_Debug_Markers - [_marker_name]; // REPLACE WITH DELETEAT!
	REMOVE_ELEMENT(Navy_Debug_Markers,_marker_name);
};

Navy_Debug_TrackUnit =
{
	FUN_ARGS_2(_unit,_delay);
	PVT_1(_pos_and_dir);
	if (isNil "_delay") then
	{
		_delay = DEBUG_MARKER_UPDATE_DELAY;
	};
	DECLARE(_debug_marker_name) = [_unit] call Navy_Debug_InitMarker;
	while {alive _unit} do
	{
		_pos_and_dir = [_unit] call Navy_General_ReturnPosAndDir;
		_marker_name setMarkerPosLocal (_pos_and_dir select 0);
		_marker_name setMarkerDirLocal (_pos_and_dir select 1);
		sleep _delay;
	};
	[_marker_name] call Navy_Debug_RemoveMarker;
};