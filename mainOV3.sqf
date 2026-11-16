_closestPos = 
{
params ["_xPos","_yPos"];

	_xStr = str (floor _xPos);
	_numOfxStr = count _xStr;
	_remOfNumX = (parseNumber (_xStr select [_numOfxStr - 3]));
	_endPosX = floor (parseNumber (if (_remOfNumX >= 500) then {((_xStr select [0,_numOfxStr - 3]) + "750")}else{((_xStr select [0,_numOfxStr - 3]) + "250")}));

	_yStr = str (floor _yPos);
	_numOfyStr = count _yStr;
	_remOfNumY = (parseNumber (_yStr select [_numOfyStr - 3]));
	_endPosY = floor (parseNumber (if (_remOfNumY >= 500) then {((_yStr select [0,_numOfyStr - 3]) + "750")}else{((_yStr select [0,_numOfyStr - 3]) + "250")}));

	[_endPosX,_endPosY]
};


_createMkrPoint = 
{
private ["_xPos","_yPos","_pos","_mkrColor"];
params ["_pos","_mkrColor","_text"];
_pos params ["_xPos","_yPos"];

	_mkr = createMarker [_text,[_xPos,_yPos]];
	_mkr setMarkerTypeLocal "mil_dot";
	_mkr setMarkerColor _mkrColor;
	_mkr setMarkerText _text;

	_mkr
};

_createMkrRectangle = 
{
params ["_pos","_mkrColor"];
_pos params ["_xPos","_yPos"];

	_mkr = createMarker [(format["A_X%1Y%2R%3",_xPos,_yPos,(random 100)]),[_xPos,_yPos]];
	_mkr setMarkerShape "RECTANGLE";
	_mkr setMarkerSize [250, 250];
	_mkr setMarkerColor _mkrColor;
	_mkr setmarkerAlpha 0.5;

	_mkr
};

_createBezier = 
{
	_frontPoints = _this;


	[_frontPoints,"ColorRed"] call Foley_markers_fnc_drawSmoothPath;

/*
	{
		private _marker = createMarkerLocal [str _x, _x];
		_marker setMarkerTypeLocal "mil_objective";
		_marker setMarkerTextLocal ("P" + str _forEachIndex);
	}
	forEach _frontPoints;
	for "_i" from -0.5 to 1.5 step 0.01 do
	{
		private _marker = createMarkerLocal [str _i, _i bezierInterpolation _frontPoints];
		_marker setMarkerTypeLocal "mil_dot";
	};
*/
};

_createTemporaryArrow =
{
params ["_posFr","_posTo"];
	_myArrow = [_posFr, _posTo, [0,1,0,1], [20], false] call BIS_fnc_drawArrow;
	[_myArrow] spawn
	{
		sleep 5;
		(_this select 0) call BIS_fnc_drawArrow;
	}
};



// create first front line
_posFirstRear = (position player) call _closestPos;
_arrMkrsRear = [[_posFirstRear,"colorGUER"] call _createMkrRectangle];

_posFirstRear params ["_xPos","_yPos"];
_frontPoints = [[_xPos+500,_yPos,0],[_xPos+500,_yPos+500,0],[_xPos,_yPos+500,0],[_xPos-500,_yPos+500,0],[_xPos-500,_yPos,0],[_xPos-500,_yPos-500,0],[_xPos,_yPos-500,0],[_xPos+500,_yPos-500,0]];

_arrMkrsFront = [];
{_arrMkrsFront pushBack ([_x,"colorYellow"] call _createMkrRectangle)} forEach _frontPoints;

//_frontPoints call _createBezier;

openMap true;


debug = false;

while {true} do
{
	for [{_i = 0}, {_i < (count _arrMkrsFront)}, {_i = _i + 1}] do 
	{
		_marker = _arrMkrsFront select _i;
		_mkrPos = markerPos _marker;
		_allUnts = allUnits inAreaArray _marker;
		_friendlyUnits = {side _x == resistance} count _allUnts;
		if ((count _allUnts != 0) && (({(_mkrPos distance2D (markerPos _x) < 600)} count _arrMkrsRear) > 0)) then // check if there are units in the trigger
		{
			if ((_friendlyUnits*100/count _allUnts) > 80) then // more than 80% of all units must be friendly
			{
				_arrSortedRearPositions = [_arrMkrsRear, [], {_mkrPos distance2D (markerPos _x)}, "ASCEND", {(_mkrPos distance2D (markerPos _x)) < 600}] call BIS_fnc_sortBy;
				_numOfRearMkrs = count _arrSortedRearPositions;
				_rearMkr = [];_posFrontNew = [];
				for [{_j = 0}, {_j < _numOfRearMkrs}, {_j = _j + 1}] do // go through the rear markers from which to move the front line
				{
					_rearMkr = _arrSortedRearPositions select _j;

					/*
					if (debug) then 
					{
						_rearMkr setMarkerColor "colorRed"; 
						sleep 2;
						_rearMkr setMarkerColor "colorGuer"; 
					};
					*/


					_posFrontNew = (_mkrPos vectorAdd (_mkrPos vectorDiff (markerPos _rearMkr))) call _closestPos;
					// check that the new front position is not in active front line
					if ((({_posFrontNew distance2D (markerPos _x) < 100} count _arrMkrsFront) < 1)&&(({_posFrontNew distance2D (markerPos _x) < 100} count _arrMkrsRear) < 1)) exitWith 
					{
						_arrMkrsFront pushBack ([_posFrontNew,"colorYellow"] call _createMkrRectangle);
					}; 
				};

				[(markerPos _rearMkr),_posFrontNew] call _createTemporaryArrow;

				_arrMkrsFront deleteAt (_arrMkrsFront find _marker);
				_marker setMarkerColor "colorGUER";
				_arrMkrsRear pushBack _marker;


				if (({(_posFrontNew distance2D (markerPos _x) < 600)} count _arrMkrsFront) < 3) then // checking if the front line is closed
				{
					_arrOfPosChecks = [[500,0],[0,500],[0,-500],[-500,0]];
					_posFrontNew params ["_xPos","_yPos"];
					for [{_i = 0}, {_i < 4}, {_i = _i + 1}] do 
					{
						_posForCheck = [_xPos + ((_arrOfPosChecks select _i) select 0),_yPos + ((_arrOfPosChecks select _i) select 1),0];
						if (
								(({(_posForCheck distance2D (markerPos _x) < 100)} count _arrMkrsFront) < 1) && 
								(({(_posForCheck distance2D (markerPos _x) < 600)} count _arrMkrsFront) > 1) && 
								(({(_posForCheck distance2D (markerPos _x) < 100)} count _arrMkrsRear) < 1)	&&
								(({(_posForCheck distance2D (markerPos _x) < 800)} count _arrMkrsRear) > 0)
							) then //_posForCheck is available?
						{
							_arrMkrsFront pushBack ([_posForCheck,"colorYellow"] call _createMkrRectangle);
						}
					};
				};

				/*

				_arrRearFrontMkrs = _arrMkrsFront select {(_posFrontNew distance2D (markerPos _x) < 800)&&(_posFrontNew distance2D (markerPos _x) > 100)};

				if ((({_posFrontNew distance2D (markerPos _x) < 600} count _arrMkrsFront) < 3) && (({_posFrontNew distance2D (markerPos _x) < 100} count _arrMkrsRear) < 1)) then // checking if the front line is closed
				{
					_arrRearFrontMkrs = _arrMkrsFront select {(_posFrontNew distance2D (markerPos _x) < 800)&&(_posFrontNew distance2D (markerPos _x) > 600)};
					for [{_i = 0}, {_i < count _arrRearFrontMkrs}, {_i = _i + 1}] do // close front line
					{
						_posAverage = (_posFrontNew vectorAdd (markerPos (_arrRearFrontMkrs select _i))) vectorMultiply .5;
						_posFrontToClose = (_posAverage vectorAdd (((markerPos _marker) vectorFromTo _posAverage) vectorMultiply 707)) call _closestPos;
						if (({(_posFrontToClose distance2D (markerPos _x)) < 100} count _arrMkrsFront) < 1) then //does the marker already exist at the given position?
						{_arrMkrsFront pushBack ([_posFrontToClose,"colorYellow"] call _createMkrRectangle)};
						
						if (debug) then 
						{
							[_posFrontToClose,"colorRED"] call _createMkrPoint;
							[_posAverage,"colorblue"] call _createMkrPoint;
							[markerPos _marker,"colorblue"] call _createMkrPoint;
						};
						
					};
				};

				*/




			}		
		}
	};

	_countMkrFront = count _arrMkrsFront;
	_mkrPos = markerPos (_arrMkrsFront select 0);
	_arrFrontLine = []; _marker = "";

	for [{_i = 0}, {_i < _countMkrFront}, {_i = _i + 1}] do 
	{
		_arrSortedFrontMkrs = [_arrMkrsFront, [], {_mkrPos distance2D (markerPos _x)}, "ASCEND"] call BIS_fnc_sortBy;
		for [{_j = 0}, {_j < _countMkrFront}, {_j = _j + 1}] do 
		{
			_mkrPos = markerPos (_arrSortedFrontMkrs select _j);
			if (({(_mkrPos distance2D (markerPos _x)) < 100} count _arrFrontLine) < 1) exitWith 
			{
				_marker = [_mkrPos,"colorYellow",str _i] call _createMkrPoint;
				_arrFrontLine pushBack _marker;
			};
		};
	};

	if (debug) then 
	{	
		copyToClipboard str _arrMkrsFront; //debug
		systemChat str	({_x == ""} count _arrMkrsFront); //debug
		//{[(_x call BIS_fnc_randomPosTrigger), "colorGreen"] call _createMkrPoint} forEach _arrMkrsFront; //debug
	};	
	sleep 2;

	{deleteMarker _x} forEach _arrFrontLine;
}