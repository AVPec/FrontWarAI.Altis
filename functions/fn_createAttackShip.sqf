params ["_mkr","_Pos","_rngPrcntg"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_RespawnDir = _mPos getDir _Pos;
	_RespawnPos = [_Pos,1,30,3,2] call BIS_fnc_findSafePos;
	_attckShipType = ["AttackBoatAndCrew",_rngPrcntg] call EOS_fnc_getUnitPools;
	_InfType = ["CargoInfantry","Divers"] selectRandomWeighted [8,2];
	_cargoPool = [_InfType,_rngPrcntg] call EOS_fnc_getUnitPools;
	_CrewGrp = createGroup west;
	_infantryGrp = createGroup west;
	_attckShip = createVehicle [(_attckShipType select 0),_RespawnPos,[],0,"CAN_COLLIDE"];
	_attckShip setDir (_attckShip getRelDir _mPos);

	{
		switch (_x select 0) do 
		{
			case "Driver":
			{
				_unit = _CrewGrp createUnit [(selectRandom (_attckShipType select 1)), _RespawnPos, [], 100, "CAN_COLLIDE"];					
				_unit assignAsDriver _attckShip;
				_unit moveInDriver _attckShip;
			};
			case "Turret":
			{
				_unit = _CrewGrp createUnit [(selectRandom (_attckShipType select 1)), _RespawnPos, [], 100, "CAN_COLLIDE"];
				_unit assignAsGunner _attckShip;
				_unit MoveInTurret [_attckShip,_x select 1];
			};
			case "Cargo":
			{
				if ((random 100)<80) then 
				{
					_unit = _infantryGrp createUnit [(selectRandom _cargoPool), _RespawnPos, [], 100, "CAN_COLLIDE"];
					_unit assignAsCargo _attckShip;
					_unit MoveInCargo _attckShip;
				}
			};
		}
	}foreach [["Driver",[]],["Turret",[0]],["Turret",[1]],["Cargo",[0]],["Cargo",[1]],["Cargo",[2]],["Cargo",[3]],["Cargo",[4]],["Cargo",[5]],["Cargo",[6]],["Cargo",[7]]];
	[_CrewGrp,_rngPrcntg] call EOS_fnc_setSkill;
	[_infantryGrp,_rngPrcntg] call EOS_fnc_setSkill;
	
	_IntermediatePos = [_mPos,(_mkrX+100+(random 50)),_RespawnDir] call BIS_fnc_relPos;	
	_DropingPos = [];
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

	_wp1 = _CrewGrp addWaypoint [_DropingPos, 0];  
	_wp1 setWaypointSpeed "NORMAL";
	_wp1 setWaypointType "UNLOAD";
	_wp1 setWaypointBehaviour "AWARE";
	
	_wpL = _infantryGrp addWaypoint [_DropingPos, 30];  
	_wpL setWaypointSpeed "FULL";
	_wpL setWaypointType "GETOUT";
	
	waitUntil{sleep 3; (_attckShip distance _DropingPos) < 100};

	if (_InfType == "CargoInfantry") then 
	{
		_infantryGrp leaveVehicle _attckShip;
		[_infantryGrp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;
	}else{
		{  
			[_x] ordergetin false;  
			[_x] allowGetIn false;  
			unassignvehicle _x;  
			moveout _x;  
			sleep 0.5;  
		} forEach (units _infantryGrp);
		[_infantryGrp,_mPos,_mkrX,true] call EOS_fnc_SHK_taskpatrol;
	};

	waitUntil{sleep 3; {_x in _attckShip} count units _infantryGrp == 0};

	_index = currentWaypoint _CrewGrp;
	deleteWaypoint [_CrewGrp, _index];
	[_CrewGrp,_mPos,_mkrX*5,true,2,true] call EOS_fnc_SHK_taskpatrol;