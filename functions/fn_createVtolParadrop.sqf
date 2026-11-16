params ["_mkr","_RespawnPos","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;
	
	_cargoVtolType = ["CargoVtol",_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
	_cargoVtolRoles = _cargoVtolType call BIS_fnc_vehicleRoles;
	_cargoVtol = createVehicle [_cargoVtolType,_RespawnPos,[],200,"fly"];
	_cargoVtol setDir (_cargoVtol getRelDir _mPos);

	{
		if (_x select 0 == "Driver") then 
		{
			_unit = _CrewGrp createUnit ["B_helipilot_F", _RespawnPos, [], 0, "CAN_COLLIDE"];					
			_unit assignAsDriver _cargoVtol;
			_unit moveInDriver _cargoVtol;
		}else{
			_unit = _CrewGrp createUnit ["B_heliCrew_F", _RespawnPos, [], 0, "CAN_COLLIDE"];
			_unit assignAsGunner _cargoVtol;
			_unit MoveInTurret [_cargoVtol,_x select 1];
		};
	}foreach [["Driver",[]],["Turret",[0]],["Turret",[1]],["Turret",[2]]];
	[_CrewGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_dropGrp = createGroup west;
	_cargoPool = ["CargoInfantry",_rngPrcntg] call EOS_fnc_getUnitPools;

	for "_x" from 1 to (10+(floor(random 20))) do 
	{					
		_unit = selectRandom _cargoPool;
		_unit = _unit createUnit [getPos _cargoVtol, _dropGrp];
	};		
	{_x moveincargo _cargoVtol}foreach units _dropGrp;
	[_dropGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_wp1 = _CrewGrp addWaypoint [_mPos, 0];  
	_wp1 setWaypointSpeed "FULL";
	_wp2 = _CrewGrp addWaypoint [[((_mPos select 0)+((_mPos select 0)-(_RespawnPos select 0))),((_mPos select 1)+((_mPos select 1)-(_RespawnPos select 1)))], 0];  
	_wp2 setWaypointSpeed "FULL";

	waituntil {(_cargoVtol distance2D _mPos) < 1400};	
	
	_cargoVtol animateDoor ['Door_1_source', 1];
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

	waitUntil{sleep 1; {_x in _cargoVtol} count units _dropGrp == 0};
	
	while {(count (waypoints _CrewGrp)) > 0} do {deleteWaypoint ((waypoints _CrewGrp) select 0)};
	sleep 3;
	_cargoVtol animateDoor ['Door_1_source', 0];
	[_dropGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;

	_wp3 = _CrewGrp addWaypoint [_RespawnPos, 0];  
	_wp3 setWaypointSpeed "FULL";  
	_wp3 setWaypointType "MOVE";
	_wp3 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew (vehicle this) + [vehicle this];"];