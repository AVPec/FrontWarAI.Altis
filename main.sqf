_debug = true;
_newGame = false;

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
			_mkrSquare setmarkerAlpha 0.5;

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







/*
	//TRYING TO CREATE A CURVED LINE

	{
		for [{_i = 0}, {_i < (count _frontPositions)}, {_i = _i + 1}] do 
		{
			
		}
	} forEach -_frontPositions;




















/*
	//TRYING TO CREATE A CURVED LINE

	_arrSortedPath = [];
	_arrGreenMkrsPos = _greenPositions apply {markerPos _x};
	_countGreenMkrsPos = count _arrGreenMkrsPos;
	_checkDistToGreenMkr = 
	{
		_slctdPos = _this;
		_bool = false;
		for [{_l = 0}, {_l < _countGreenMkrsPos}, {_l = _l + 1}] do 
		{
			if ((_slctdPos distance2D (_arrGreenMkrsPos select _l)) < 1100) exitWith {_bool = true};
		};
		_bool
	};

	_arrFrontPosForLine1 = [];
	{
		(markerPos _x) params["_xPos","_yPos"];
		{_arrFrontPosForLine1 pushBack _x} forEach [[_xPos - 250, _yPos + 250],[_xPos + 250,_yPos + 250],[_xPos + 250,_yPos - 250],[_xPos - 250,_yPos - 250]];
	} forEach _frontPositions;
	_arrFrontPosForLine2 = [];
	{
		_slctdPos = _x;
		if (_slctdPos call _checkDistToGreenMkr) then {_arrFrontPosForLine2 pushBack _slctdPos};
	} forEach _arrFrontPosForLine1;

	call FW_fnc_sortLinePath;
	_arrSortedPath apply {_x pushBack 0};
	_arrSortedPath pushBack _arrSortedPath#0;
	_selectedFrontPos = [_arrSortedPath,"colorRed"] call FW_fnc_drawLine;
	//copyToClipboard str _arrSortedPath; //debug

/*
	{ 
		_mkrPointDebug = [_x,"colorGUER",str _forEachIndex] call _createMkrPoint; //debug
	} forEach _arrSortedPath; //debug


/*
	_firstPos = _arrFrontPosForLine2 select 0; _arrFrontPosForLine2 deleteAt 0;
	[_firstPos,"colorYellow","pezda1"] call _createMkrPoint;

	_secondPos = [];
	_countFrontPosForLine2 = count _arrFrontPosForLine2;
	for [{_i = 0}, {_i < _countFrontPosForLine2}, {_i = _i + 1}] do 
	{
		_slctdPos = _arrFrontPosForLine2 select _i;
		if ((_slctdPos distance2D _firstPos) < 600) exitWith {_secondPos = _slctdPos; _arrFrontPosForLine2 deleteAt _i};
	};
	[_secondPos,"colorYellow","pezda2"] call _createMkrPoint;

	_thirPos = [];
	_intrmedPos = _secondPos vectorAdd (_secondPos vectorDiff _firstPos);
	_countFrontPosForLine2 = count _arrFrontPosForLine2;
	for [{_i = 0}, {_i < _countFrontPosForLine2}, {_i = _i + 1}] do 
	{
		_slctdPos = _arrFrontPosForLine2 select _i;
		if ((_slctdPos distance2D _intrmedPos) < 100) exitWith {_thirPos = _slctdPos; _arrFrontPosForLine2 deleteAt _i};
	};
	[_thirPos,"colorYellow","pezda3"] call _createMkrPoint;

	copyToClipboard format ["%1,%2",_thirPos,_intrmedPos];
*/


/*
	_countMkrFront = count _frontPositions;
	_mkrPos = markerPos ((_frontPositions select {_slctdMkr = markerPos _x; ({(_slctdMkr distance2D (markerPos _x)) < 1100} count _frontPositions ) > 2}) select 0); //find a suitable first marker UNNECESSARY ACTION
	_arrFrontLine = []; _selectedFrontPos = "";

	for [{_i = 0}, {_i < _countMkrFront}, {_i = _i + 1}] do 
	{
		_arrSortedFrontMkrs = [_frontPositions, [], {_mkrPos distance2D (markerPos _x)}, "ASCEND"] call BIS_fnc_sortBy;
		for [{_j = 0}, {_j < _countMkrFront}, {_j = _j + 1}] do 
		{
			_mkrPos = markerPos (_arrSortedFrontMkrs select _j);
			if (({(_mkrPos distance2D (markerPos _x)) < 100} count _arrFrontLine) < 1) exitWith 
			{
				_selectedFrontPos = [_mkrPos,"colorYellow",str _i] call _createMkrPoint;
				_arrFrontLine pushBack _selectedFrontPos;
			};
		};
	};




	//TRYING TO CREATE A CURVED LINE

	_arrFrontLine pushBack (_arrFrontLine select 0);
	_arrFrLinePos = [];
	_arrDebugMkr = []; //debug
	_mkrStart = markerPos (_arrFrontLine select 0);
	_nearestGreenMkr = ([_greenPositions, [], {_mkrStart distance2D (markerPos _x)}, "ASCEND"] call BIS_fnc_sortBy) select 0;
	_mkrStart params ["_xPos","_yPos"];
	_arrPosFrontMarker = [[_xPos - 250, _yPos + 250],[_xPos + 250,_yPos + 250],[_xPos + 250,_yPos - 250],[_xPos - 250,_yPos - 250]];

	_startPos = ([_arrPosFrontMarker, [], {markerPos _nearestGreenMkr distance2D _x}, "ASCEND"] call BIS_fnc_sortBy) select 0;
	_debugMkr = [_startPos,"colorBlue","FrP" + str (random 100)] call _createMkrPoint; //debug
	_arrFrLinePos pushBack _startPos;
	_arrDebugMkr pushBack _debugMkr; //debug

	for [{_i = 1}, {_i < count _arrFrontLine}, {_i  = _i + 1}] do 
	{
		_mkrStart params ["_xPos","_yPos"];
		_arrPosFrontMarker = [[_xPos - 250, _yPos + 250],[_xPos + 250,_yPos + 250],[_xPos + 250,_yPos - 250],[_xPos - 250,_yPos - 250]];	
		_mkrSecond = markerPos (_arrFrontLine select _i);
		if ((_startPos distance2D _mkrSecond) > 800) then 
		{

			for [{_j = 0}, {_j < (count  _arrPosFrontMarker)}, {_j = _j + 1}] do 
			{
				_slctdPos = _arrPosFrontMarker select _j;
				if 
				(
					!(_slctdPos isEqualTo _startPos) &&
					((_slctdPos distance2D _startPos) < 600) &&
					((_slctdPos distance2D _mkrSecond) < 800)		
				) exitWith 
				{
					_startPos = _slctdPos;
					_arrFrLinePos pushBack _startPos;
					_debugMkr = [_startPos,"colorBlue","FrP" + str (random 100)] call _createMkrPoint;
					_arrDebugMkr pushBack _debugMkr; //debug
				};
			};
			
		};

		_mkrSecond params ["_xPos","_yPos"];
		_arrPosFrontMarker = [[_xPos - 250, _yPos + 250],[_xPos + 250,_yPos + 250],[_xPos + 250,_yPos - 250],[_xPos - 250,_yPos - 250]];
		_secondPos = ([_arrPosFrontMarker, [], {_startPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy) select 0;

		if (_i == ( count _arrFrontLine - 1)) then 
		{		
			if (({_secondPos isEqualTo _x} count _arrFrLinePos) < 1) then 
			{
				_arrFrLinePos pushBack _secondPos;
				_debugMkr = [_secondPos,"colorBlue","FrPS" + str (random 100)] call _createMkrPoint; //debug
				_arrDebugMkr pushBack _debugMkr; //debug
			}
		}else{
			_arrFrLinePos pushBack _secondPos;
			_debugMkr = [_secondPos,"colorBlue","FrPS" + str (random 100)] call _createMkrPoint; //debug
			_arrDebugMkr pushBack _debugMkr; //debug
		};

		_startPos = _secondPos; _mkrStart = _mkrSecond;
		sleep 0.5;
	};
*/

	missionNamespace setVariable ["FrontPos", _frontPositions];
	missionNamespace setVariable ["GreenPos", _greenPositions];
	missionNamespace setVariable ["RedPos", _redPositions];

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

/*
	_unitPoints = (east countSide allunits) * 5;
	typeof ((assignedVehicles grp1)#0) groups east
	_vehArray = [];
	{_vehArray append  _x} forEach (groups east);
*/
	[_frontPositions,_greenPositions] call FW_fnc_saveGame;

	sleep 0;
}