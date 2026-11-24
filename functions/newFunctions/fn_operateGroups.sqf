params ["_createdGroups", "_attackPos"];
private ["_attackPos"];

_debug = false;

_side = side (_createdGroups # 0);
_calculateNumOfUnitsInGroups = {
	_numOfUnitsInGroups = 0;
	{_numOfUnitsInGroups = _numOfUnitsInGroups + (count units _x)} forEach _createdGroups;
	_numOfUnitsInGroups
};

_spawndeNumOfUnits = call _calculateNumOfUnitsInGroups;
_numOfUnitsInGroups = _spawndeNumOfUnits;
_uncceptableNumOfLosses = round (_spawndeNumOfUnits - _spawndeNumOfUnits * 0.8);

{
	[_x, "attack", _attackPos, _side] call FW_fnc_orderExecution;
	if (_debug) then {
		[_x, _attackPos, "attack"] call FW_fnc_drawMapArrow;
	};
} forEach _createdGroups;

_conditionForRetreat = false;
_previousAttackPos = _attackPos;

while {!_conditionForRetreat} do {
	sleep 20;
	_numOfUnitsInGroups = call _calculateNumOfUnitsInGroups;
	if !(_attackPos in (missionNamespace getVariable "frontPos")) then {
		_previousAttackPos = _attackPos;
		_attackPos = ["findFrontLineNearestSquarePos", _attackPos] call FW_fnc_findPos;
		if ((count _attackPos) > 0) then {
			{
				[_x] call FW_fnc_drawMapArrow;
				[_x, "attack", _attackPos, _side] call FW_fnc_orderExecution;
				if (_debug) then {
					[_x, _attackPos, "attack"] call FW_fnc_drawMapArrow;
				};
			} forEach _createdGroups;
		} else {
			_conditionForRetreat = true;
		};
	};
	if (_numOfUnitsInGroups < _uncceptableNumOfLosses) then {
		_conditionForRetreat = true;
	};
};

{
	[_x] call FW_fnc_drawMapArrow;
	systemChat "retreat";
	[_x, "retreat", [], _side] call FW_fnc_orderExecution;
	if (_debug) then {
		[_x, _previousAttackPos, "retreat"] call FW_fnc_drawMapArrow;
	};
} forEach _createdGroups;