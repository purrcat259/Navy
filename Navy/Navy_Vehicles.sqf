#include "Navy_Macros.h"

Navy_Vehicle_SpawnAirVehicle =
{
	FUN_ARGS_2(_classname,_spawn_position);
	DECLARE(_vehicleID) = createVehicle [_classname,_spawn_position,[],0,Navy_Vehicle_StartingForm];
	WAIT_DELAY(0.1,!isNil "_vehicleID");
	_spawn_position = getposATL _spawn_position;
	_vehicleID setposATL [(_spawn_position select 0),(_spawn_position select 1),NAVY_DEFAULT_FLIGHT_HEIGHT];
	_vehicleID flyInHeight NAVY_DEFAULT_FLIGHT_HEIGHT;
	Navy_Vehicles pushBack _vehicleID;
	INC(Navy_Vehicle_Counter);
	_vehicleID;
};

Navy_Vehicle_SpawnFilledAirVehicle =
{
	FUN_ARGS_4(_unit_template,_vehicle_classname,_spawn_position,_cargo_amount);
	PVT_3(_driver,_vehicleID,_cargo_group);
	_driver = [_unit_template] call Navy_Units_SpawnDriver;
	_vehicleID = [_vehicle_classname,_spawn_position] call Navy_Vehicle_SpawnAirVehicle;
	_driver assignAsDriver _vehicleID;
	_driver moveinDriver _vehicleID;
	DEBUG
	{
		[_vehicleID] spawn Navy_Debug_TrackVehicle;
		[["Driver %1 placed in vehicle %2 at position %3 with form: %4",_driver,_vehicleID,_spawn_position,Navy_Vehicle_StartingForm]] call Navy_Debug_HintRPT;
	};
	_cargo_group = [_unit_template,_cargo_amount] call Navy_Vehicle_FillCargo;
	{
		_x assignAsCargo _vehicleID;
		_x moveInCargo _vehicleID;
	} forEach units _cargo_group;
	DEBUG
	{
		[["Cargo unit group %1 has been placed in the vehicle %2",_cargo_group,_vehicleID]] call Navy_Debug_HintRPT;
	};
	[_vehicleID,_cargo_group];
};

Navy_Vehicle_ReturnCargo =
{
	FUN_ARGS_1(_vehicleID);
	DECLARE(_cargo) = [crew _vehicleID, {_vehicleID getCargoIndex _x >= 0}] call BIS_fnc_conditionalSelect;
	_cargo;
	DEBUG
	{
		[["Vehicle: %1 has %2 cargo units: %3",_vehicleID,(count _cargo),_cargo]] call Navy_Debug_HintRPT;
	};
};

Navy_Vehicle_FillCargo =
{
	FUN_ARGS_2(_unit_template,_amount);
	DECLARE(_group) = createGroup ([_unit_template] call adm_common_fnc_getUnitTemplateSide);
	DECLARE(_cargo_unit_array) = [];
	PVT_2(_i,_cargo_unit);
	for "_i" from 1 to _amount do
	{
		_cargo_unit = [_unit_template,_group] call Navy_Units_SpawnCargoUnit;
		_cargo_unit_array pushBack _cargo_unit;
	};
	Navy_GroundUnit_Groups pushBack _cargo_unit_array;
	DEBUG
	{
		[["Cargo Unit group created with array: %1",_cargo_unit_array]] call Navy_Debug_HintRPT;
	};
	_group;
};

Navy_Vehicle_CargoUnassign =
{
	FUN_ARGS_2(_cargo_group,_delay);
	if (isNil "_delay") then
	{
		_delay = NAVY_DEFAULT_PARADROP_DELAY;
	};
	{
		unassignVehicle _x;
		sleep _delay;
	} forEach units _cargo_group;
	DEBUG
	{
		[["Cargo Unit Group: %1 has been unassigned from their vehicle",_cargo_group]] call Navy_Debug_HintRPT;
	};
};

Navy_Vehicle_CargoAction =
{
	FUN_ARGS_3(_cargo_group,_action,_delay);
	if (isNil "_delay") then
	{
		_delay = NAVY_DEFAULT_PARADROP_DELAY;
	};
	{
		(_x) action [_action, vehicle _x];
		//unassignVehicle _x;
		sleep _delay;
	} forEach units _cargo_group;
	DEBUG
	{
		[["Cargo Unit Group: %1 have been assigned action: %2",_cargo_group,_action]] call Navy_Debug_HintRPT;
	};
};

Navy_Vehicle_CargoGetOut =
{
	FUN_ARGS_2(_cargo_group,_delay);
	if (isNil "_delay") then
	{
		_delay = NAVY_DEFAULT_PARADROP_DELAY;
	};
	{
		unassignVehicle _x;
		(_x) action ["GETOUT", vehicle _x];
		sleep _delay;
	} forEach units _cargo_group;
	DEBUG
	{
		[["Cargo Unit Group: %1 have been ordered to get out",_cargo_group]] call Navy_Debug_HintRPT;
	};
};

Navy_Vehicle_EjectCargo =
{
	FUN_ARGS_2(_cargo_group,_delay);
	if (isNil "_delay") then
	{
		_delay = NAVY_DEFAULT_PARADROP_DELAY;
	};
	{
		moveOut _x;
		unassignVehicle _x;
		_x setVelocity [0,0,-5];
		sleep _delay;
	} forEach units _cargo_group;
	DEBUG
	{
		[["Cargo Unit Group: %1 has paradropped successfully.",_cargo_group]] call Navy_Debug_HintRPT;
	};
};

Navy_Vehicle_Animation_Door =
{
	FUN_ARGS_3(_vehicleID,_door,_phase);
	_vehicleID animateDoor [_door,_phase,false];
};

Navy_Vehicle_Animation_OpenDoor =
{
	FUN_ARGS_2(_vehicleID,_door);
	[_vehicleID,_door,1] call Navy_Vehicle_Animation_Door;
};

Navy_Vehicle_Animation_CloseDoor =
{
	FUN_ARGS_2(_vehicleID,_door);
	[_vehicleID,_door,0] call Navy_Vehicle_Animation_Door;
};

Navy_Vehicle_Animation_OpenDoorArray =
{
	FUN_ARGS_2(_vehicleID,_door_array);
	{
		[_vehicleID,_x] call Navy_Vehicle_Animation_OpenDoor;
	} forEach _door_array;
};

Navy_Vehicle_Animation_CloseDoorArray =
{
	FUN_ARGS_2(_vehicleID,_door_array);
	{
		[_vehicleID,_x] call Navy_Vehicle_Animation_CloseDoor;
	} forEach _door_array;
};

Navy_Vehicle_CleanUp =
{
	FUN_ARGS_1(_vehicleID);
	DEBUG
	{
		[["Vehicle %1 and crew %2 are being deleted",_vehicleID,(crew _vehicleID)]] call Navy_Debug_HintRPT;
		DECLARE(_waypoints) = waypoints _vehicleID; // Required to remove debug markers
		PVT_1(_i);
		for "_i" from 1 to (count _waypoints) do // waypoint 0 does not have a debug marker attached
		{
			deleteMarkerLocal (str(_waypoints select _i));
		};
	};
	sleep 1;
	{
		deleteVehicle _x;
	} forEach (crew _vehicleID);
	deleteVehicle _vehicleID;
	
};