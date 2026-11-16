/*
_anglePerMkr = 20;
_numOFMkr = 360/_anglePerMkr;

_posStart = position player;
_angMdfed = 0;
_mkrDts = [];

for "_i" from 1 to _numOFMkr step 1 do 
{
	_mkrPos = [_posStart, 100, _angMdfed] call BIS_fnc_relPos;
	_mkr = createMarker [str _mkrPos,_mkrPos];
	_mkr setMarkerTypeLocal "mil_dot";
	_angMdfed = _angMdfed + _anglePerMkr;
	_mkrDts pushBack _mkr;
};
_mkrDts pushBack (_mkrDts select 0);
_numOfMkrDts = (count _mkrDts) - 2;

for "_i" from 0 to _numOfMkrDts step 1 do 
{
	_posMkr01 = markerPos (_mkrDts select _i);
	_posMkr02 = markerPos (_mkrDts select (_i+1));
	(findDisplay 12 displayCtrl 51) ctrlAddEventHandler 
	["Draw",
		format[
			"(_this select 0) drawLine 
			[
				%1,
				%2,
				[0,0,1,1]
			]"
		,_posMkr01,_posMkr02]
	];
};


_mapSize = floor(worldSize/1000);
for "_j" from 0 to _mapSize step 1 do 
{
	for "_i" from 0 to _mapSize step 1 do 
	{
		_xMain = _i*100;
		_yMain = _j*100;

		_mkr = createMarker [(format["A_X%1Y%2",_xMain,_yMain]),[_xMain,_yMain]];
		_mkr setMarkerTypeLocal "mil_dot";
	}
}
*/


_closestPos = 
{
params ["_xPos","_yPos"];

	_xStr = str (floor _xPos);
	_numOfxStr = count _xStr;
	_remOfNumX = (parseNumber (_xStr select [_numOfxStr - 2,_numOfxStr - 1]));
	_endPosX = floor (if (_remOfNumX >= 50) then {_xPos  + (100 - _remOfNumX)}else{_xPos  - _remOfNumX});

	_yStr = str (floor _yPos);
	_numOfyStr = count _yStr;
	_remOfNumY = (parseNumber (_yStr select [_numOfyStr - 2,_numOfyStr - 1]));
	_endPosY = floor (if (_remOfNumY >= 50) then {_yPos  + (100 - _remOfNumY)}else{_yPos  - _remOfNumY});

	[_endPosX,_endPosY]
};

_craeteFrontLine = 
{
params ["_startPos","_distFrStart"];
_startPos params ["_xPos","_yPos"];

	_returnArr = [];
	_pos = [_xPos,_yPos+_distFrStart] call _closestPos;
	_returnArr pushBack _pos;
	_pos = [_xPos+_distFrStart,_yPos] call _closestPos;
	_returnArr pushBack _pos;
	_pos = [_xPos,_yPos-_distFrStart] call _closestPos;
	_returnArr pushBack _pos;
	_pos = [_xPos-_distFrStart,_yPos] call _closestPos;
	_returnArr pushBack _pos;
	_returnArr
};


_closeLine  = 
{
params ["_arrFrntLine"];

	while {true} do
	{
		for [{_j=0},{_j<(count _arrFrntLine)},{_j=_j+1}] do 
		{
			_slctdPnt = _arrFrntLine select _j;
			if (({(_slctdPnt distance2D _x) < 150} count _arrFrntLine) < 3) then 
			{
				_srtdArr = [_arrFrntLine,[],{_x distance2D _slctdPnt},"ASCEND"] call BIS_fnc_sortBy;
				for [{_i=1},{_i<(count _srtdArr)},{_i=_i+1}] do 
				{
					if !(({(_slctdPnt distance2D _x) < 150} count _arrFrntLine) < 3) exitWith {};
					_pos = [_slctdPnt, 140, (_slctdPnt getDir (_srtdArr select _i))] call BIS_fnc_relPos;
					_pos = _pos call _closestPos;

					if (({_pos isEqualTo _x} count _arrFrntLine) < 1) then 
					{
						_arrNrstPos = _arrFrntLine select {((_pos distance2D _x) > 50)&&((_pos distance2D _x) < 150)};
						if ((count _arrNrstPos)<3) then 
						{
							//systemChat ("AAA" + (str ({_pos isEqualTo _x} count _arrFrntLine)));
							copyToClipboard (format ["%1,%2",_pos,_arrNrstPos]);
							
							_condition = false;
							for [{_k=0},{_k<(count _arrNrstPos)},{_k=_k+1}] do 
							{
								_slctPos = _arrNrstPos select _k;
								if (({(_slctPos distance2D _x) < 150} count _arrFrntLine) < 3) exitWith {_condition = true};
							};
							if (_condition) then
							{
								//systemChat str ({(_pos distance2D _x) < 150} count _arrFrntLine);
								_nearestMarker01 = [allMapMarkers, _slctdPnt] call BIS_fnc_nearestPosition;
								_nearestMarker02 = [allMapMarkers, (_srtdArr select _i)] call BIS_fnc_nearestPosition;
								systemchat format ["%1,%2",markerText _nearestMarker01,_nearestMarker02];								
								[_pos,"colorGreen"] call _createMkr;
								_arrFrntLine pushBack _pos;
								_srtdArr = [_arrFrntLine,[],{_x distance2D _slctdPnt},"ASCEND"] call BIS_fnc_sortBy;
								sleep 3;
							}
						}
					}
				}
			};
		};
		sleep 5;
	};
};







_createMkr = 
{
params ["_pos","_mkrColor"];
_pos params ["_xPos","_yPos"];

	_text = random 100;
	_mkr = createMarker [(format ["_%1",_text]),[_xPos,_yPos]];
	_mkr setMarkerTypeLocal "mil_dot";
	_mkr setMarkerColor _mkrColor;
	_mkr setMarkerText str _text;
};

//arrFrontPosRED = [(getPos player),200] call _craeteFrontLine;
arrFrontPosBLCK = [(getPos player),400] call _craeteFrontLine;
//{[_x,"colorRed"] call _createMkr} forEach arrFrontPosRED;
{[_x,"colorBlue"] call _createMkr} forEach arrFrontPosBLCK;
//[arrFrontPosRED] call _closeLine;
[arrFrontPosBLCK] call _closeLine;



/*

		for 
		[
			{_j=0},
			{(_j < _numOfsrtdArr) && ({(_x distance2D _slctdPnt) < 150} count _srtdArr < 3)},
			{_j=_j+1}
		] do
		{
			_pos = [_slctdPnt, 140, (_slctdPnt getDir (_srtdArr select _j))] call BIS_fnc_relPos;
			_pos = _pos call _closestPos;
			if ({(_x distance2D _pos) < 150} count _srtdArr < 3) then {_srtdArr pushBack _pos};
		};

		while {({(_x distance2D _slctdPnt) < 150} count _srtdArr) < 3} do 
		{
			for [{_j=0},{_j<_numOfsrtdArr},{_j=_j+1}] do 
			{
				_pos = [_slctdPnt, 140, (_slctdPnt getDir (_srtdArr select _j))] call BIS_fnc_relPos;
				_pos = _pos call _closestPos;
				if (({(_x distance2D _pos) < 150} count _srtdArr < 3)&&({_x isEqualTo _pos} count _srtdArr < 1)) then {_srtdArr pushBack _pos; {[_x,"colorRed"] call _createMkr} forEach _srtdArr};
			}; 
		};

		_numOfarrFrntLine = count _arrFrntLine;
	for [{_i=0},{_i<_numOfarrFrntLine},{_i=_i+1}] do 
	{
		_slctdPnt = _arrFrntLine select _i;
		_srtdArr = [_arrFrntLine,[],{_x distance2D _slctdPnt},"ASCEND"] call BIS_fnc_sortBy;
		_numOfsrtdArr = count _srtdArr;

		_srtdArr
	};