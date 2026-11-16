params ["_mkr","_RespawnPos","_rngPrcntg","_grpSize"];
_mPos = markerPos _mkr;
_mkrX =	(markerSize _mkr) select 0;

	_RespawnDir = ((_mPos getDir _RespawnPos) + ((random -45) + (random 45)));
	_distancePos = _mPos distance _RespawnPos; 
	if (_distancePos < 500) then 
	{
		_RespawnPos = [_mPos, (_distancePos+_distancePos*0.2-_distancePos*0.2), _RespawnDir] call BIS_fnc_relPos
	}else{
		_RespawnPos = [_mPos, 500+(random 500), _RespawnDir] call BIS_fnc_relPos;
	};

	_untPool = if (surfaceiswater _RespawnPos) then {["Divers",_rngPrcntg] call EOS_fnc_getUnitPools}else{["Infantry",_rngPrcntg] call EOS_fnc_getUnitPools};	
	_grp = createGroup west;

	for "_x" from 1 to _grpSize do 
	{					
		_unit = _grp createUnit [(selectRandom _untPool), _RespawnPos, [], 6, "FORM"];  
	};
	
	[_grp,_mPos,_mkrX,false,1] call EOS_fnc_SHK_taskpatrol;
	[_grp,_rngPrcntg] call EOS_fnc_setSkill;

