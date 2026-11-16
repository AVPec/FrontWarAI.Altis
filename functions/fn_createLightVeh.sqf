params ["_mkr","_Pos","_RespawnDir","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_RespawnPos = [_Pos,0,30,3,0] call BIS_fnc_findSafePos;
	_vehTypeAndCrew=["LightVehAndCrew",_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
	_lightVehRoles = [(_vehTypeAndCrew select 0)] call BIS_fnc_vehicleRoles;
	_lightVeh = createVehicle [(_vehTypeAndCrew select 0),_RespawnPos,[],0,"CAN_COLLIDE"];
	_lightVeh setDir (_lightVeh getRelDir _mPos);
	_cargoPool = ["CargoInfantry",_rngPrcntg] call EOS_fnc_getUnitPools;
	_infantryGrp = createGroup west;

	if ((_vehTypeAndCrew select 0) in ["B_LSV_01_armed_F","B_LSV_01_AT_F"]) then {_lightVehRoles = [["Driver",[]],["Turret",[0]],([["Turret",[1]],["Empty",[]]] selectRandomWeighted [2,8]),["Cargo",[]],["Cargo",[]]]};
	{
		switch (_x select 0) do 
		{
			case "Driver":
			{
				_unit = _CrewGrp createUnit [(selectRandom(_vehTypeAndCrew select 1)), _RespawnPos, [], 0, "CAN_COLLIDE"];					
				_unit assignAsDriver _lightVeh;
				_unit moveInDriver _lightVeh;
			};
			case "Turret":
			{
				_unit = _CrewGrp createUnit [(selectRandom(_vehTypeAndCrew select 1)), _RespawnPos, [], 0, "CAN_COLLIDE"];
				_unit assignAsGunner _lightVeh;
				_unit moveInTurret [_lightVeh,(_x select 1)];
			};
			case "Cargo":
			{
				if ((random 100)<80) then 
				{				
					_unit = _infantryGrp createUnit [(selectRandom _cargoPool), _RespawnPos, [], 0, "CAN_COLLIDE"];
					_unit assignAsCargo _lightVeh;
					_unit MoveInCargo _lightVeh;
				}
			};
		}
	}foreach _lightVehRoles;
	[_CrewGrp,_rngPrcntg] call EOS_fnc_setSkill;
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

	waitUntil{sleep 3; (_lightVeh distance2D _DropingPos) < 100};	

	_infantryGrp leaveVehicle _lightVeh;

	waitUntil{sleep 3; {_x in _lightVeh} count units _infantryGrp == 0};

	[_infantryGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;
	_index = currentWaypoint _CrewGrp;
	deleteWaypoint [_CrewGrp, _index];
	[_CrewGrp,_mPos,(_mkrX*2),false,1] call EOS_fnc_SHK_taskpatrol;

