params ["_task","_fromSquarePos","_side"];
_searchedPos = [];
_scatterArray = {
	_array = _this;
	_numOfArray = count _array;
	_scatteredArrayOfIndices = [];
	while {(count _scatteredArrayOfIndices) < _numOfArray} do 
	{
		_i = round (random (_numOfArray-1));
		if !(_i in _scatteredArrayOfIndices) then {_scatteredArrayOfIndices pushBack _i};
	};
	_scatteredArray = [];
	{_scatteredArray pushBack (_array#_x)} forEach _scatteredArrayOfIndices;
	_scatteredArray
};
_arrayWithAdditionalCoordinates = [[0,1000],[1000,1000],[1000,0],[1000,-1000],[0,-1000],[-1000,-1000],[-1000,0],[-1000,1000],[-1000,2000],[0,2000],[1000,2000],[2000,1000],[2000,0],[2000,-1000],[-1000,-2000],[0,-2000],[1000,-2000],[-2000,1000],[-2000,0],[-2000,-1000]];


switch _task do {
	case "randomizePosInSquare": {
		for "_i" from 1 to 6 do 
		{	
			_dist = random 600;
			_dir = random 360;
			_searchedPos = [(_fromSquarePos#0 + (_dist * sin _dir)),(_fromSquarePos#1 + (_dist * cos _dir)),0];
			if !(surfaceIsWater _searchedPos) exitWith {};
		};
	};
	case "findSafeSquarePos": {
		_strFriendlyPos = if (_side == independent) then {"GreenPos"} else {"RedPos"};
		_friendlyPos = missionNamespace getVariable _strFriendlyPos;		
		_numFriendlyPos = count _friendlyPos;
		_numLandArrPos = count GV_landArrPos;
		_reinforcementPosWithWeight = [];
		{
			_pos = (_fromSquarePos vectorAdd _x);
			for [{_i = 0}, {_i < _numFriendlyPos}, {_i = _i + 1}] do {
				if (_pos#0 == (_friendlyPos#_i)#0) then {
					if (_pos#1 == (_friendlyPos#_i)#1) then {
						for [{_j = 0}, {_j < _numLandArrPos}, {_j = _j + 1}] do {
							if (_pos#0 == ((GV_landArrPos#_j)#0)#0) then {
								if (_pos#1 == ((GV_landArrPos#_j)#0)#1) then {
									_reinforcementPosWithWeight append GV_landArrPos#_j;
									_i = _numFriendlyPos; _j = _numLandArrPos
								}
							}	
						}
					}
				}
			}
		} forEach _arrayWithAdditionalCoordinates;
		_searchedPos =  selectRandomWeighted _reinforcementPosWithWeight;
	};
	case "findFrontLineSquarePos": {
		_frontPositions = missionNamespace getVariable "frontPos"; 
		_frontPosWithWeight = [];
		_numlandArrPos = count GV_landArrPos;
		{
			_curFrontPos = _x;
			for [{_i = 0}, {_i < _numlandArrPos}, {_i = _i + 1}] do 
			{
				if ((_curFrontPos#0) == (((GV_landArrPos#_i)#0)#0)) then 
				{
					if ((_curFrontPos#1) == (((GV_landArrPos#_i)#0)#1)) then 
					{
						_frontPosWithWeight pushBack (GV_landArrPos#_i)#0;
						_frontPosWithWeight pushBack (GV_landArrPos#_i)#1;
						_i = _numlandArrPos;
					}
				}
			};
		} forEach _frontPositions;
		_searchedPos = selectRandomWeighted _frontPosWithWeight;
	};

	case "findFrontLineNearestSquarePos": {
		_arrayWithAdditionalCoordinatesScattered = _arrayWithAdditionalCoordinates call _scatterArray;
		_frontPositions = missionNamespace getVariable "frontPos";
		_numOfarrayWithAdditionalCoordinatesScattered = count _arrayWithAdditionalCoordinatesScattered;
		for [{_i = 0}, {_i < _numOfarrayWithAdditionalCoordinatesScattered}, {_i = _i + 1}] do {
			_posForCheck = _fromSquarePos vectorAdd (_arrayWithAdditionalCoordinatesScattered#_i);
			if (_posForCheck in _frontPositions) exitWith {_searchedPos = _posForCheck};
		};
	};

};
_searchedPos


