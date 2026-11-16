_mkrDebug = true;


_closestPos = 
{
params ["_xPos","_yPos"];

	_xStr = str (floor _xPos);
	_numOfxStr = count _xStr;
	_endPosX = floor (parseNumber ((_xStr select [0,_numOfxStr - 3]) + "500"));

	_yStr = str (floor _yPos);
	_numOfyStr = count _yStr;
	_endPosY = floor (parseNumber ((_yStr select [0,_numOfyStr - 3]) + "500"));

	[_endPosX,_endPosY]
};

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



//////////////////// positions presets ////////////////////
	_landArrPos = [];
	_mapSize = floor(worldSize/1000)-1;
	for "_j" from 0 to _mapSize step 1 do 
	{
		for "_i" from 0 to _mapSize step 1 do 
		{
			_xMain = _i*1000+500;
			_yMain = _j*1000+500;
			{
				_pos = ([_xMain,_yMain] vectorAdd _x);
				if !(surfaceIsWater _pos) exitWith {_landArrPos pushBack [_xMain,_yMain]};
			} forEach [[-250,250],[250,250],[250,-250],[-250,-250]];
		}
	};
	_landArrPos = _landArrPos apply 
	{
		[_x] + [(count (nearestObjects [_x,["building"],600,true]))];
	};
//////////////////// DEBUG ////////////////////
	if (false) then
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
		} forEach _landArrPos;
	};
// create first front line
_posFirstGreen = (position player) call _closestPos;
_posFirstGreen params ["_xPosGreen","_yPosGreen"];
_greenPositions = [_posFirstGreen];

_frontPositions = [];
_numLandArrPos = count _landArrPos;
{
	_x params ["_xPos","_yPos"];
	for [{_i = 0}, {_i < _numLandArrPos}, {_i = _i + 1}] do 
	{
		(_landArrPos#_i)#0 params ["_landPosX","_landPosY"];
		if (_landPosX == _xPos) then 
		{
			if (_landPosY == _yPos) then 
			{
				_frontPositions pushBack [_xPos,_yPos,0];
				_i = _numLandArrPos;
			};
		};
	};
} forEach [[_xPosGreen+1000,_yPosGreen],[_xPosGreen+1000,_yPosGreen+1000],[_xPosGreen,_yPosGreen+1000],[_xPosGreen-1000,_yPosGreen+1000],[_xPosGreen-1000,_yPosGreen],[_xPosGreen-1000,_yPosGreen-1000],[_xPosGreen,_yPosGreen-1000],[_xPosGreen+1000,_yPosGreen-1000]];

_redPositions = [];
_deleteArrForRedPositions = _frontPositions + _greenPositions;
_numDeleteArr = count _deleteArrForRedPositions;
for [{_i = 0}, {_i < _numLandArrPos}, {_i = _i + 1}] do 
{
	_bool = true;
	(_landArrPos#_i)#0 params ["_landPosX","_landPosY"];
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
	if (_bool) then {_redPositions pushBack [_landPosX,_landPosY,0]};
};

openMap true;

while {true} do
{
	for [{_i = 0}, {_i < (count _frontPositions)}, {_i = _i + 1}] do 
	{
		_selectedFrontPos = _frontPositions select _i;
		_allUnts = allUnits inAreaArray [_selectedFrontPos,500,500,0,true,100];
		if ((count _allUnts != 0)) then // check if there are units in the trigger  			&& (({(_selectedFrontPos distance2D _x < 1100)} count _greenPositions) > 0)
		{
			if((_greenPositions findIf {_selectedFrontPos distance2D _x < 1100}) > -1) then	// check if it's not a corner position
			{
				_friendlyUnits = {side _x == resistance} count _allUnts;
				if ((_friendlyUnits*100/count _allUnts) > 80) then // more than 80% of all units must be friendly
				{
					/*
					TRASH 01
					_arrSortedGreenPositions = [_greenPositions, [], {_selectedFrontPos distance2D _x}, "ASCEND", {(_selectedFrontPos distance2D _x) < 1100}] call BIS_fnc_sortBy;
					_numOfGreenPositions = count _arrSortedGreenPositions;
					_greenPos = [];_posFrontNew = [];
					for [{_j = 0}, {_j < _numOfGreenPositions}, {_j = _j + 1}] do // go through the green markers from which to move the front line
					{
						_greenPos = _arrSortedGreenPositions select _j;
						_posFrontNew = (_selectedFrontPos vectorAdd (_selectedFrontPos vectorDiff _greenPos)) call _closestPos;
						// check that the new front position is not in active front line
						if ((({_posFrontNew distance2D _x < 100} count _frontPositions) < 1)&&(({_posFrontNew distance2D _x < 100} count _greenPositions) < 1)) exitWith 
						{
							_frontPositions pushBack _posFrontNew;
						}; 
					}; 
					*/
					_greenPositions pushBack _selectedFrontPos;
					_frontPositions deleteAt _i;

					/*
					TRASH 01
					if (_mkrDebug) then //DEBUG 
					{
						_myArrow = [_greenPos, _posFrontNew, [0,1,0,1], [20], false] call BIS_fnc_drawArrow;
						[_myArrow] spawn
						{
							sleep 5;
							(_this select 0) call BIS_fnc_drawArrow;
						}
					};
					*/

					// recalculating front line
					_selectedFrontPos params ["_xPosGreen","_yPosGreen"];
					_arrAvoidPos = _greenPositions + _frontPositions;
					_numAvoidPos = count _arrAvoidPos;
					{
						_x params ["_xPos","_yPos"];
						for [{_j = 0}, {_j < _numLandArrPos}, {_j = _j + 1}] do 
						{
							(_landArrPos#_j)#0 params ["_landPosX","_landPosY"];
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
										_frontPositions pushBack [_xPos,_yPos,0];
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
					} forEach [[_xPosGreen+1000,_yPosGreen],[_xPosGreen+1000,_yPosGreen+1000],[_xPosGreen,_yPosGreen+1000],[_xPosGreen-1000,_yPosGreen+1000],[_xPosGreen-1000,_yPosGreen],[_xPosGreen-1000,_yPosGreen-1000],[_xPosGreen,_yPosGreen-1000],[_xPosGreen+1000,_yPosGreen-1000]];



/*

					if (({(_posFrontNew distance2D _x < 1100)} count _frontPositions) < 3) then // checking if the front line is closed
					{
						_arrOfPosChecks = [[1000,0],[0,1000],[0,-1000],[-1000,0]];
						_posFrontNew params ["_xPos","_yPos"];
						for [{_i = 0}, {_i < 4}, {_i = _i + 1}] do 
						{ 
							_posForCheck = [_xPos + ((_arrOfPosChecks#_i)#0),_yPos + ((_arrOfPosChecks#_i)#1),0];
							if ( //_posForCheck is available?
									(({(_posForCheck distance2D _x < 100)} count _frontPositions) < 1) && 
									(({(_posForCheck distance2D _x < 1100)} count _frontPositions) > 1) && 
									(({(_posForCheck distance2D _x < 100)} count _greenPositions) < 1)	&&
									(({(_posForCheck distance2D _x < 1500)} count _greenPositions) > 0) &&
									(({(_posForCheck distance2D _x < 100)} count _redPositions) > 0)
								) then {_frontPositions pushBack _posForCheck} 
						};
					};
*/
				}else{ //else there are more enemy units here
					_arrSortedGreenPositions = [_greenPositions, [], {_selectedFrontPos distance2D _x}, "ASCEND", {(_selectedFrontPos distance2D _x) < 1100}] call BIS_fnc_sortBy;
					_numOfGreenPositions = count _arrSortedGreenPositions;
					_greenPos = [];_posFrontNew = [];
					for [{_j = 0}, {_j < _numOfGreenPositions}, {_j = _j + 1}] do // go through the green markers from which to move the front line
					{
						_greenPos = _arrSortedGreenPositions select _j;
						_posFrontNew = (_selectedFrontPos vectorDiff (_selectedFrontPos vectorDiff _greenPos)) call _closestPos;
						// check that the new front position is not in active front line
						if ((({_posFrontNew distance2D _x < 100} count _frontPositions) < 1)&&(({_posFrontNew distance2D _x < 100} count _greenPositions) > 0)) exitWith 
						{
							_frontPositions pushBack _posFrontNew;
							_oldGreenPosID = _greenPositions findIf {_posFrontNew distance2D _x < 100};
							_greenPositions deleteAt _oldGreenPosID;
						};

					};

					if (_mkrDebug) then //DEBUG 
					{
						_myArrow = [_greenPos, _posFrontNew, [0,1,0,1], [20], false] call BIS_fnc_drawArrow;
						[_myArrow] spawn
						{
							sleep 5;
							(_this select 0) call BIS_fnc_drawArrow;
						}
					};

					_frontPositions deleteAt _i;
/*
					_newfrontPositions = [];
					{
						_checkingFrontPos = _x;
						if (({(_checkingFrontPos distance2D _x < 1500)} count _greenPositions) > 0) then // checking if the front line is closed
						{							
							_newfrontPositions pushBack _checkingFrontPos
						}
					} forEach _frontPositions;
					_frontPositions = _newfrontPositions;


	/*
					if (({(_posFrontNew distance2D (markerPos _x) < 1100)} count _frontPositions) < 3) then // checking if the front line is closed
					{
						_arrOfPosChecks = [[1000,0],[0,1000],[0,-1000],[-1000,0]];
						_posFrontNew params ["_xPos","_yPos"];
						for [{_i = 0}, {_i < 4}, {_i = _i + 1}] do 
						{
							_posForCheck = [_xPos + ((_arrOfPosChecks select _i) select 0),_yPos + ((_arrOfPosChecks select _i) select 1),0];
							if (
									(({(_posForCheck distance2D (markerPos _x) < 100)} count _frontPositions) < 1) && 
									(({(_posForCheck distance2D (markerPos _x) < 1100)} count _frontPositions) > 1) && 
									(({(_posForCheck distance2D (markerPos _x) < 100)} count _greenPositions) < 1)	&&
									(({(_posForCheck distance2D (markerPos _x) < 1500)} count _greenPositions) > 0)
								) then //_posForCheck is available?
							{
								_frontPositions pushBack ([_posForCheck,"colorYellow"] call _createMkrRectangle);
							}
						};
					};
					*/
				}
			}
		}
	};




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

	missionNamespace setVariable ["FrontPositions", _frontPositions];
	missionNamespace setVariable ["GreenPositions", _greenPositions];
	missionNamespace setVariable ["RedPositions", _redPositions];

	//[_landArrPos] execVM "AIenemyside.sqf";

	if (_mkrDebug) then //DEBUG
	{
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
		_allRectangleMkrs= [];
		{_allRectangleMkrs pushBack ([_x,"colorYellow"] call _createMkrRectangle)} forEach _frontPositions;
		{_allRectangleMkrs pushBack ([_x,"colorGUER"] call _createMkrRectangle)} forEach _greenPositions;
		{_allRectangleMkrs pushBack ([_x,"colorRed"] call _createMkrRectangle)} forEach _redPositions;
		_allRectangleMkrs spawn {sleep 2; {deleteMarker _x} foreach _this}
	};

	sleep 2;
}


