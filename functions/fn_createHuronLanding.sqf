params ["_mkr","_RespawnPos","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;
	
	_cargoHeliType = ["CargoHeli",_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
	_cargoHeliRoles = [_cargoHeliType] call BIS_fnc_vehicleRoles;
	_cargoHeli = createVehicle [_cargoHeliType,_RespawnPos,[],100,"fly"];
	_cargoHeli setDir (_cargoHeli getRelDir _mPos);

	{
		if (_x select 0 == "Driver") then 
		{
			_unit = _CrewGrp createUnit ["B_helipilot_F", _RespawnPos, [], 0, "CAN_COLLIDE"];					
			_unit assignAsDriver _cargoHeli;
			_unit moveInDriver _cargoHeli;
		}else{
			_unit = _CrewGrp createUnit ["B_heliCrew_F", _RespawnPos, [], 0, "CAN_COLLIDE"];
			_unit assignAsGunner _cargoHeli;
			_unit MoveInTurret [_cargoHeli,_x select 1];
		};
	}foreach [["Driver",[]],["Turret",[0]],["Turret",[1]],["Turret",[2]]];
	[_CrewGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_landingGrp = createGroup west;
	_cargoPool = ["CargoInfantry",_rngPrcntg] call EOS_fnc_getUnitPools;

	for "_x" from 1 to (5+(floor(random 10))) do 
	{					
		_unit = (selectRandom _cargoPool) createUnit [_RespawnPos, _landingGrp];
	};															
	{_x moveincargo _cargoHeli}foreach units _landingGrp;
	[_landingGrp,_rngPrcntg] call EOS_fnc_setSkill;

    _LandingPos = [_mPos,0,_mkrX*1.8,8,0,0.15,0,[],([_mkr,false] call EOS_fnc_SHK_pos)] call BIS_fnc_findSafePos;
	_LandingPad = createVehicle ["Land_HelipadEmpty_F", _LandingPos, [], 0, "NONE"]; 

	_wp1 = _CrewGrp addWaypoint [_LandingPos, 0];  
	_wp1 setWaypointSpeed "FULL";
	_wp1 setWaypointType "SCRIPTED";
	_wp1 setWaypointScript "A3\functions_f\waypoints\fn_wpLand.sqf";
	_wp1 setWaypointStatements ["true", "(vehicle this) LAND 'GET IN';"]; 

	_wpL = _landingGrp addWaypoint [_LandingPos, 20];  
	_wpL setWaypointSpeed "FULL";
	_wpL setWaypointType "GETOUT";

	waituntil {(getpos _cargoHeli) select 2 < 3};
	
	_index = currentWaypoint _CrewGrp;
	deleteWaypoint [_CrewGrp, _index];
	_cargoHeli animateDoor ['Door_rear_source', 1];
	sleep 2;
	_cargoHeli engineOn true;
	{  
		[_x] ordergetin false;  
		[_x] allowGetIn false;  
		unassignvehicle _x;  
		moveout _x;  
		sleep 1;  
	} forEach (units _landingGrp); 
	
	[_landingGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;

	waitUntil{sleep 1; {_x in _cargoHeli} count assignedCargo _cargoHeli == 0};	

	_cargoHeli animateDoor ['Door_rear_source', 0];
	_wp2 = _CrewGrp addWaypoint [_RespawnPos, 0]; 
   	_wp2 setWaypointCompletionRadius 50;
	_wp2 setWaypointSpeed "FULL";  
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew (vehicle this) + [vehicle this];"];  
	
	deletevehicle _LandingPad;