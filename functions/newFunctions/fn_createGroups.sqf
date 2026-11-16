params ["_strengthOfReinforcements","_spawnSquarePos","_side"];

_strSidePoints = if (_side == independent) then {"APguerilla"} else {"APeast"};
_availablePoints = missionNamespace getVariable _strSidePoints;
_createdGroups = [];
_numOfGroups = 0;
_maxNumUnitsInGroup = 0;
switch (_strengthOfReinforcements) do {
	case "minor": {
		_numOfGroups = 1 + (round (random 1));
		_maxNumUnitsInGroup = 3;
	};	
	case "normal": {
		_numOfGroups = 2 + (round (random 1));
		_maxNumUnitsInGroup = 4;
	};
	case "high": {
		_numOfGroups = 2 + (round (random 2));
		_maxNumUnitsInGroup = 5;
	};
};

for [{_i = 0}, {_i < _numOfGroups}, {_i = _i + 1}] do {
	_numUnitsInGroup = 2 + (round  (random (_maxNumUnitsInGroup - 2)));
	_ifEnoughPointsForHiring = (_numUnitsInGroup * 5) < _availablePoints;
	if (!_ifEnoughPointsForHiring) exitWith {};
	_availablePoints = _availablePoints - (_numUnitsInGroup * 5);
	missionNamespace setVariable [_strSidePoints, _availablePoints];
	_group = createGroup _side;
	_createdGroups pushBack _group;					
	_posForSpawn = ["randomizePosInSquare",_spawnSquarePos] call FW_fnc_findPos;
	[_group,_posForSpawn,"infantry",_side,_numUnitsInGroup] call FW_fnc_spawnUnit;
};

_createdGroups