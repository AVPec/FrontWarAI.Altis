params ["_mkr","_RespawnPos","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_cargoHeliType = ["CargoHeli",_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
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

	_dropGrp = createGroup west;
	_cargoPool = ["CargoInfantry",_rngPrcntg] call EOS_fnc_getUnitPools;
	
	for "_x" from 1 to (5+(floor(random 10))) do 
	{					
		_unit = (selectRandom _cargoPool) createUnit [_RespawnPos, _dropGrp];
	};															
	{_x moveincargo _cargoHeli}foreach units _dropGrp;
	[_dropGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_dropPos = [_mkr,false] call EOS_fnc_SHK_pos;									

	_wp1 = _CrewGrp addWaypoint [_dropPos, 0];  
	_wp1 setWaypointSpeed "FULL";
	_wp2 = _CrewGrp addWaypoint [[(2*(_dropPos select 0)-(_RespawnPos select 0)),(2*(_dropPos select 1)-(_RespawnPos select 1))], 0];  
	_wp2 setWaypointSpeed "FULL";

	waituntil {(((_cargoHeli distance2D _mPos) < 500)||((_cargoHeli distance2d _dropPos) < 500))};
	
	_cargoHeli animateDoor ['Door_rear_source', 1];
	sleep 3;

	{  
		removeBackpack _x;  
		_x addBackpack "B_Parachute";  
		[_x] ordergetin false;  
		[_x] allowGetIn false;  
		unassignvehicle _x;  
		moveout _x;  
		sleep 0.3;  
	} forEach (units _dropGrp);  

	waitUntil{sleep 1; {_x in _cargoHeli} count units _dropGrp == 0};

	while {(count (waypoints _CrewGrp)) > 0} do
	{
		deleteWaypoint ((waypoints _CrewGrp) select 0);
	};
	sleep 3;
	_cargoHeli animateDoor ['Door_rear_source', 0];
	[_dropGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskPatrol;

	_wp3 = _CrewGrp addWaypoint [_RespawnPos, 0];  
   	_wp3 setWaypointCompletionRadius 50;
	_wp3 setWaypointSpeed "FULL";  
	_wp3 setWaypointType "MOVE";
	_wp3 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew (vehicle this) + [vehicle this];"];  