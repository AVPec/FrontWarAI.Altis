params ["_position","_rngPrcntg","_type"];

	_vehTypeAndUnt=[_type,_rngPrcntg] call EOS_fnc_getUnitPools;
	_vehType = if (count _this > 3) then {_this select 3}else{_vehTypeAndUnt select 0};
	_grp = createGroup west;

	_vehicle = createVehicle [_vehType, _position, [], 0, "CAN_COLLIDE"];
	_VehRoles = if !(_vehType in ["B_LSV_01_armed_F","B_LSV_01_AT_F"]) then {_vehType call BIS_fnc_vehicleRoles}else{[["Driver",[]],["Turret",[0]],([["Turret",[1]],["Empty",[]]] selectRandomWeighted [2,8])]};

	{
	_x params ["_role","_path"];

		_untType = selectRandom (_vehTypeAndUnt select 1);
		switch (_role) do 
		{
			case "Driver":
			{
				_unit = _grp createUnit [_untType, _position, [], 0, "CAN_COLLIDE"];					
				_unit assignAsDriver _vehicle;
				_unit moveInDriver _vehicle;
			};
			case "Turret":
			{
				_unit = _grp createUnit [_untType, _position, [], 0, "CAN_COLLIDE"];
				_unit assignAsGunner _vehicle;
				_unit MoveInTurret [_vehicle,_path];
			};
		}
	}foreach _VehRoles;

_return=[_vehicle,_grp];
_return