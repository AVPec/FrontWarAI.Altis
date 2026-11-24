_debug = true;
_newGame = true;

_createMkrPoint = 
{
params ["_pos","_mkrColor","_text"];
_pos params ["_xPos","_yPos"];

	_mkr = createMarker [_text + (str (random 100)),[_xPos,_yPos]];
	_mkr setMarkerTypeLocal "mil_dot";
	_mkr setMarkerColor _mkrColor;
	_mkr setMarkerText _text;

	_mkr
};

//////////////////// accural system for AP ////////////////////
if (_newGame) then {
		{missionNamespace setVariable [_x, 0]} forEach ["APeast","APguerilla"];
} else {
	_data = profilenamespace getvariable "Save001";
	missionNamespace setVariable ["APeast", _data#2];
	missionNamespace setVariable ["APguerilla", _data#3];
};
if (_debug) then {
	[] spawn FW_fnc_pointSideOnScreen;
};
[] spawn {
	while {true} do {
		{
			_curentNumOfAp = missionNamespace getVariable _x;
			_accrualPoints = 10;
			missionNamespace setVariable [_x, (_curentNumOfAp + _accrualPoints)];		
		} forEach ["APeast","APguerilla"];
		sleep 30;
	}
};

//////////////////// positions presets ////////////////////
	GV_landArrPos = [];
	_mapSize = floor(worldSize/1000)-1;
	for "_j" from 0 to _mapSize step 1 do 
	{
		for "_i" from 0 to _mapSize step 1 do 
		{
			_xMain = _i*1000+500;
			_yMain = _j*1000+500;
			{
				_pos = ([_xMain,_yMain] vectorAdd _x);
				if !(surfaceIsWater _pos) exitWith {GV_landArrPos pushBack [_xMain,_yMain]};
			} forEach [[-250,250],[250,250],[250,-250],[-250,-250]];
		}
	};
	GV_landArrPos = GV_landArrPos apply 
	{
		[_x] + [(count (nearestObjects [_x,["building"],600,true]))];
	};
	{[_x] execVM "AiEachSide.sqf"} forEach [east,independent];
	
//////////////////// DEBUG ////////////////////
	if (_debug) then
	{
		{
		_x params ["_squarePos","_numOfBuildingsInArea"];

			_mkrSquare = createMarker [str (random 10000),_squarePos];
			_mkrSquare setMarkerShape "RECTANGLE";
			_mkrSquare setMarkerSize [500, 500];
			_mkrSquare setMarkerColor "colorGUER";
			_mkrSquare setmarkerAlpha 0.3;

			_mkrDot = createMarker [str (random 10000),_squarePos];
			_mkrDot setMarkerTypeLocal "mil_dot";
			_mkrDot setMarkerText (str _numOfBuildingsInArea);

			_mkrCircle = createMarker[str (random 10000),_squarePos];
			_mkrCircle setMarkerShape "Ellipse";
			_mkrCircle setMarkerBrush "Border";
			_mkrCircle setMarkerSize [600,600];			
		} forEach GV_landArrPos;
	};
// create first front line

_spawnNewFrontLine = {
	params ["_initPos"];
	_posFirstGreen = ["findClosestSquarePos", _initPos] call FW_fnc_findPos;
	_greenPositions pushBack _posFirstGreen;
	_posFirstGreen params ["_xPosGreen","_yPosGreen"];

	{
		_x params ["_xPos","_yPos"];
		for [{_i = 0}, {_i < _numLandArrPos}, {_i = _i + 1}] do 
		{
			(GV_landArrPos#_i)#0 params ["_landPosX","_landPosY"];
			if (_landPosX == _xPos) then 
			{
				if (_landPosY == _yPos) then 
				{
					_frontPositions pushBack [_xPos,_yPos];
					_i = _numLandArrPos;
				};
			};
		};
	} forEach [[_xPosGreen+1000,_yPosGreen],[_xPosGreen,_yPosGreen+1000],[_xPosGreen-1000,_yPosGreen],[_xPosGreen,_yPosGreen-1000]];
};

_frontPositions = [];
_greenPositions = [];
_numLandArrPos = count GV_landArrPos;

if (_newGame) then {
	[position player] call _spawnNewFrontLine;
} else {
	_data = profilenamespace getvariable "Save001";
	_greenPositions = _data#1;
	_frontPositions = _data#0;
};

_redPositions = [];
_deleteArrForRedPositions = _frontPositions + _greenPositions;
_numDeleteArr = count _deleteArrForRedPositions;
for [{_i = 0}, {_i < _numLandArrPos}, {_i = _i + 1}] do 
{
	_bool = true;
	(GV_landArrPos#_i)#0 params ["_landPosX","_landPosY"];
	for [{_j = 0}, {_j < _numDeleteArr}, {_j = _j + 1}] do 
	{
		_deleteArrForRedPositions#_j params ["_dltPosX","_dltPosY"];
		if (_landPosX == _dltPosX) then 
		{
			if (_landPosY == _dltPosY) then
			{
				_j = _numDeleteArr; _bool = false;
			}		
		}
	};
	if (_bool) then {_redPositions pushBack [_landPosX,_landPosY]};
};


//["Initialize", [player, [], true]] call BIS_fnc_EGSpectator;
openMap true;

// Прапорець змін фронту: true при старті для початкового малювання ліній, далі лише при захопленні квадратів
_frontChanged = true;

while {true} do
{
	for [{_i = 0}, {_i < (count _frontPositions)}, {_i = _i + 1}] do 
	{
		_selectedFrontPos = _frontPositions select _i;
		_allUnts = allUnits inAreaArray [_selectedFrontPos,500,500,0,true,100];
		if ((count _allUnts != 0)) then // check if there are units in the trigger
		{
			_friendlyUnits = {side _x == resistance} count _allUnts;
			if ((_friendlyUnits*100/count _allUnts) > 80) then // more than 80% of all units must be friendly
			{
				_frontChanged = true;
				_greenPositions pushBack _selectedFrontPos;
				_frontPositions deleteAt _i;

				// recalculating front line
				_selectedFrontPos params ["_xPosGreen","_yPosGreen"];
				_arrAvoidPos = _greenPositions + _frontPositions;
				_numAvoidPos = count _arrAvoidPos;
				{
					_x params ["_xPos","_yPos"];
					for [{_j = 0}, {_j < _numLandArrPos}, {_j = _j + 1}] do 
					{
						(GV_landArrPos#_j)#0 params ["_landPosX","_landPosY"];
						if (_landPosX == _xPos) then 
						{
							if (_landPosY == _yPos) then 
							{
								_j = _numLandArrPos;
								_bool = true;
								for [{_k = 0}, {_k < _numAvoidPos}, {_k = _k + 1}] do
								{
									_arrAvoidPos#_k params ["_avoidPosX","_avoidPosY"];
									if (_avoidPosX == _xPos) then 
									{
										if (_avoidPosY == _yPos) then 
										{
											_bool = false;
											_k = _numAvoidPos
										}
									}
								};
								if (_bool) then 
								{
									_frontPositions pushBack [_xPos,_yPos];
									_numRedPos = count _redPositions;
									for [{_l = 0}, {_l < _numRedPos}, {_l = _l + 1}] do
									{
										_redPositions#_l params ["_redPosX","_redPosY"];
										if (_xPos == _redPosX) then 
										{
											if (_yPos == _redPosY) then 
											{
												_redPositions deleteAt _l;
												_l = _numRedPos;
											}
										}
									}
								}
							}
						}
					}
				} forEach [[_xPosGreen+1000,_yPosGreen],[_xPosGreen,_yPosGreen+1000],[_xPosGreen-1000,_yPosGreen],[_xPosGreen,_yPosGreen-1000]];
			}else{
				_enemyUnits = {side _x == east} count _allUnts;
				if ((_enemyUnits*100/count _allUnts) > 80) then // if there are more enemies 
				{
					_frontChanged = true;
					_redPositions pushBack _selectedFrontPos;
					_frontPositions deleteAt _i;

					// recalculating front line
					_selectedFrontPos params ["_xPosRed","_yPosRed"];
					_arrAvoidPos = _redPositions + _frontPositions;
					_numAvoidPos = count _arrAvoidPos;
					{
						_x params ["_xPos","_yPos"];
						for [{_j = 0}, {_j < _numLandArrPos}, {_j = _j + 1}] do 
						{
							(GV_landArrPos#_j)#0 params ["_landPosX","_landPosY"];
							if (_landPosX == _xPos) then 
							{
								if (_landPosY == _yPos) then 
								{
									_j = _numLandArrPos;
									_bool = true;
									for [{_k = 0}, {_k < _numAvoidPos}, {_k = _k + 1}] do
									{
										_arrAvoidPos#_k params ["_avoidPosX","_avoidPosY"];
										if (_avoidPosX == _xPos) then 
										{
											if (_avoidPosY == _yPos) then 
											{
												_bool = false;
												_k = _numAvoidPos
											}
										}
									};
									if (_bool) then 
									{
										_frontPositions pushBack [_xPos,_yPos];
										_numGreenPos = count _greenPositions;
										for [{_l = 0}, {_l < _numGreenPos}, {_l = _l + 1}] do
										{
											_greenPositions#_l params ["_greenPosX","_greenPosY"];
											if (_xPos == _greenPosX) then 
											{
												if (_yPos == _greenPosY) then 
												{
													_greenPositions deleteAt _l;
													_l = _numGreenPos;
												}
											}
										}
									}
								}
							}
						}
					} forEach [[_xPosRed+1000,_yPosRed],[_xPosRed,_yPosRed+1000],[_xPosRed-1000,_yPosRed],[_xPosRed,_yPosRed-1000]];					
				}
			}
		}
	};

	missionNamespace setVariable ["FrontPos", _frontPositions];
	missionNamespace setVariable ["GreenPos", _greenPositions];
	missionNamespace setVariable ["RedPos", _redPositions];

	// Оновлюємо плавні лінії фронту лише коли хоча б один квадрат реально змінив сторону
	if (_frontChanged) then {
		[_frontPositions, _greenPositions, _redPositions] call FW_fnc_updateFrontLines;
		_frontChanged = false;
	};

	if (_debug) then {
		_createMkrRectangle = 
		{
		params ["_pos","_mkrColor"];
		_pos params ["_xPos","_yPos"];

			_mkr = createMarker [(format["A_X%1Y%2R%3",_xPos,_yPos,(random 100)]),[_xPos,_yPos]];
			_mkr setMarkerShape "RECTANGLE";
			_mkr setMarkerSize [500, 500];
			_mkr setMarkerColor _mkrColor;
			_mkr setmarkerAlpha 0.5;

			_mkr
		};
		sleep.5;		
		_allRectangleMkrs= [];
		{_allRectangleMkrs pushBack ([_x,"colorYellow"] call _createMkrRectangle)} forEach _frontPositions;
		{_allRectangleMkrs pushBack ([_x,"colorGUER"] call _createMkrRectangle)} forEach _greenPositions;
		{_allRectangleMkrs pushBack ([_x,"colorRed"] call _createMkrRectangle)} forEach _redPositions;
		sleep 20;
		_allRectangleMkrs spawn {{deleteMarker _x} foreach _this}
	};
	[_frontPositions,_greenPositions] call FW_fnc_saveGame;

	sleep 0;
}