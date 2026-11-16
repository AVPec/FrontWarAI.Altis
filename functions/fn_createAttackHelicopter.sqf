params ["_mkr","_RespawnPos","_patrolBool","_attackHeliType","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_CrewGrp = createGroup west;
	_attackHeli = createVehicle [_attackHeliType,_RespawnPos,[],100,"fly"];
	_attackHeli setDir (_attackHeli getRelDir _mPos);
	_unit = _CrewGrp createUnit ["B_helipilot_F", _RespawnPos, [], 0, "CAN_COLLIDE"];					
	_unit assignAsDriver _attackHeli;
	_unit moveInDriver _attackHeli;
	_unit = _CrewGrp createUnit ["B_helipilot_F", _RespawnPos, [], 0, "CAN_COLLIDE"];
	_unit assignAsGunner _attackHeli;
	_unit moveInTurret [_attackHeli,[0]];
	[_CrewGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_wp1 = _CrewGrp addWaypoint [_mPos, 0];  
	_wp1 setWaypointSpeed "FULL";  
	_wp1 setWaypointType "SAD";

	waituntil {(_attackHeli distance _mPos) < 600};	
	
	[_CrewGrp,_mPos,_mkrX*6,true] call EOS_fnc_SHK_taskpatrol;
	sleep 90;

	if !(_patrolBool) then 
	{	
		while {(count (waypoints _CrewGrp)) > 0} do	{deleteWaypoint ((waypoints _CrewGrp) select 0)};

		sleep 3;

		_wpDel = _CrewGrp addWaypoint [_RespawnPos, 0];  
		_wpDel setWaypointSpeed "FULL";  
		_wpDel setWaypointType "MOVE";
		_wpDel setWaypointStatements ["true", "{deleteVehicle _x} forEach crew (vehicle this) + [vehicle this]"];
	}