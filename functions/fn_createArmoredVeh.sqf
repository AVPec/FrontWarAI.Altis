params ["_mkr","_Pos","_RespawnDir","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_RespawnPos = [_Pos,0,30,3,0] call BIS_fnc_findSafePos;
	_vehTypeAndCrew = ["ArmVehAndCrew",_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
	_armorVehRoles = _vehTypeAndCrew call BIS_fnc_vehicleRoles;
	_ifCargo = {(_x select 0) == "Cargo"} count _armorVehRoles > 0;
	_armorVeh = createVehicle [(_vehTypeAndCrew select 0),_RespawnPos,[],0,"CAN_COLLIDE"];
	_armorVeh setDir (_armorVeh getRelDir _mPos);

	_cargoPool=[]; _infantryGrp=[];
	if (_ifCargo) then 
	{
		_cargoPool = ["Infantry",_rngPrcntg] call EOS_fnc_getUnitPools;
		_infantryGrp = createGroup west;
	};

	{
		switch (_x select 0) do 
		{
			case "Driver":
			{
				_unit = _CrewGrp createUnit [(selectRandom(_vehTypeAndCrew select 1)), _RespawnPos, [], 0, "CAN_COLLIDE"];					
				_unit assignAsDriver _armorVeh;
				_unit moveInDriver _armorVeh;
			};
			case "Turret":
			{
				_unit = _CrewGrp createUnit [(selectRandom(_vehTypeAndCrew select 1)), _RespawnPos, [], 0, "CAN_COLLIDE"];
				_unit assignAsGunner _armorVeh;
				_unit moveInTurret [_armorVeh,(_x select 1)];
			};
			case "Cargo":
			{
				if ((random 100)<80) then 
				{
					_unit = selectRandom _cargoPool;	
					_unit = _infantryGrp createUnit [_unit, _RespawnPos, [], 0, "CAN_COLLIDE"];
					_unit assignAsCargo _armorVeh;
					_unit MoveInCargo _armorVeh;
				};
			};
		};
	}foreach _armorVehRoles;
	[_CrewGrp,_rngPrcntg] call EOS_fnc_setSkill;
	[_infantryGrp,_rngPrcntg] call EOS_fnc_setSkill;
	
	if (_ifCargo) then 
	{
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

		waitUntil{sleep 5; (_armorVeh distance _DropingPos) < 100};	

		_infantryGrp leaveVehicle _armorVeh;

		waitUntil{sleep 5; {_x in _armorVeh} count units _infantryGrp == 0};

		[_infantryGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;
		_index = currentWaypoint _CrewGrp;
		deleteWaypoint [_CrewGrp, _index];
	};
	[_CrewGrp,_mPos,_mkrX*2,false,1] call EOS_fnc_SHK_taskpatrol;