params ["_mkr","_Pos","_RespawnDir","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_RespawnPos = [_Pos,0,100,3,0] call BIS_fnc_findSafePos;
	_cargoVehType=["CargoVehAndCrew",_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
	_cargoVeh = createVehicle [(_cargoVehType select 0),_RespawnPos,[],0,"CAN_COLLIDE"];
	_cargoVeh setDir (_cargoVeh getRelDir _mPos);
	_unit = _CrewGrp createUnit [(_cargoVehType select 1), _RespawnPos, [], 0, "CAN_COLLIDE"];					
	_unit assignAsDriver _cargoVeh;
	_unit moveInDriver _cargoVeh;
	_cargoPool = ["CargoInfantry",_rngPrcntg] call EOS_fnc_getUnitPools;
	_infantryGrp = createGroup west;
	_cargoVehRoles = [_cargoVehType select 0] call BIS_fnc_vehicleRoles; 
	
	for "_x" from 1 to ((count _cargoVehRoles)*.3+(floor (random ((count _cargoVehRoles)*.7*_rngPrcntg)))-1) do 
	{					
		_unit = (selectRandom _cargoPool) createUnit [_RespawnPos, _infantryGrp];
	};															
	{_x moveincargo _cargoVeh} foreach units _infantryGrp;
	[_infantryGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_DropingPos = [_mPos,(_mkrX+300+(random 100)),_RespawnDir] call BIS_fnc_relPos;	
	if (surfaceiswater _DropingPos) then {_DropingPos = [_DropingPos,0,1,false,6] call EOS_fnc_SHK_pos};

	_wp1 = _CrewGrp addWaypoint [_DropingPos, 0];
   	_wp1 setWaypointCompletionRadius 50;
	_wp1 setWaypointSpeed "NORMAL";
	_wp1 setWaypointType "UNLOAD";
	_wp1 setWaypointBehaviour "AWARE";
	
	_wpL = _infantryGrp addWaypoint [_DropingPos, 20];  
	_wpL setWaypointSpeed "FULL";
	_wpL setWaypointType "GETOUT";
	
	waitUntil{sleep 3; (_cargoVeh distance _DropingPos) < 100};	

	_infantryGrp leaveVehicle _cargoVeh;			
	[_infantryGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskPatrol;
	
	waitUntil{sleep 3; {_x in _cargoVeh} count units _infantryGrp == 0};
	
	_index = currentWaypoint _CrewGrp;
	deleteWaypoint [_CrewGrp, _index];							
	_wp2 = _CrewGrp addWaypoint [_RespawnPos, 0];
   	_wp2 setWaypointCompletionRadius 50;
	_wp2 setWaypointSpeed "NORMAL";  
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew (vehicle this) + [vehicle this]"];  