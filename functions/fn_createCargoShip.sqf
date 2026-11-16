params ["_mkr","_Pos","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_RespawnDir = _mPos getDir _Pos;
	_RespawnPos = [_Pos,1,30,3,2] call BIS_fnc_findSafePos;
	_InfType = ["CargoInfantry","Divers"] selectRandomWeighted [8,2];
	_cargoPool = [_InfType,_rngPrcntg] call EOS_fnc_getUnitPools;
	_boatGrp = createGroup west;	
	_cargoShip = createVehicle ["B_Boat_Transport_01_F",_RespawnPos,[],0,"CAN_COLLIDE"];
	_cargoShip setDir (_cargoShip getRelDir _mPos);
	
	{
		switch (_x select 0) do 
		{
			case "Driver":
			{

				_unit = _boatGrp createUnit [(selectRandom _cargoPool), _RespawnPos, [], 0, "CAN_COLLIDE"];
				_unit assignAsDriver _cargoShip;
				_unit moveInDriver _cargoShip;
			};
			case "Turret":
			{
				if ((random 100)<80) then 
				{
					_unit = _boatGrp createUnit [(selectRandom _cargoPool), _RespawnPos, [], 0, "CAN_COLLIDE"];
					_unit assignAsGunner _cargoShip;
					_unit MoveInTurret [_cargoShip,(_x select 1)];
				}
			};
		}
	}foreach [["Driver",[]],["Turret",[0]],["Turret",[1]],["Turret",[2]],["Turret",[3]]];
	[_boatGrp,_rngPrcntg] call EOS_fnc_setSkill;

	_IntermediatePos = [_mPos,(_mkrX+100+(random 50)),_RespawnDir] call BIS_fnc_relPos;
	_DropingPos=[];
	if (_InfType == "CargoInfantry") then 
	{
		_DropingPos = [_IntermediatePos,0,1,true,2] call EOS_fnc_SHK_pos;
	}else{
		if(!surfaceIsWater _IntermediatePos)then
		{
			_DropingPos = [_IntermediatePos,0,1,true,0] call EOS_fnc_SHK_pos
		}else{
			_DropingPos = _IntermediatePos;
		}
	};

	_wp1 = _boatGrp addWaypoint [_DropingPos, 0];  
	_wp1 setWaypointSpeed "NORMAL";
	_wp1 setWaypointType "UNLOAD";
	_wp1 setWaypointBehaviour "AWARE";

	waitUntil{sleep 3; (_cargoShip distance _DropingPos) < 100};
	
	if (_InfType == "CargoInfantry") then 
	{
		_boatGrp leaveVehicle _cargoShip;
		[_boatGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;
	}else{
		{  
			[_x] ordergetin false;  
			[_x] allowGetIn false;  
			unassignvehicle _x;  
			moveout _x;  
			sleep 0.5;  
		} forEach (units _boatGrp);
		[_boatGrp,_mPos,_mkrX,true] call EOS_fnc_SHK_taskpatrol;
	};