	_firstPos = [];_secondPos = []; _thirdPos = [];_arrFrontPosForLine4 = [];
	_countFrontPosForLine2 = count _arrFrontPosForLine2;
	for [{_i = 0}, {_i < _countFrontPosForLine2}, {_i = _i + 1}] do 
	{
		_firstPos = _arrFrontPosForLine2 select _i;
		_arrFrontPosForLine3 = [];
		_arrFrontPosForLine3 append _arrFrontPosForLine2;
		_arrFrontPosForLine3 deleteAt _i;
		_countFrontPosForLine3 = count _arrFrontPosForLine3;
		for [{_j = 0}, {_j < _countFrontPosForLine3}, {_j = _j + 1}] do 
		{
			_slctdPos = _arrFrontPosForLine3 select _j;
			if ((_slctdPos distance2D _firstPos) < 600) then 
			{
				_secondPos = _slctdPos;
				_searchParam =  if ((_firstPos select 0) == (_secondPos select 0)) then {[_firstPos select 0,0]}else{[_firstPos select 1,1]};
				_searchParam params ["_values","_index"];
				_arrFrontPosForLine4 append _arrFrontPosForLine3;
				_arrFrontPosForLine4 deleteAt _j;
				_countFrontPosForLine4 = count _arrFrontPosForLine4;
				for [{_k = 0}, {_k < _countFrontPosForLine4}, {_k = _k + 1}] do 
				{			
					_slctdPos = _arrFrontPosForLine4 select _k;
					if(((_slctdPos distance2D _secondPos) < 600) && ((_slctdPos select _index) == _values)) exitWith 
					{
						_thirdPos = _slctdPos; 
						_arrFrontPosForLine4 deleteAt _k; 
						_j = _countFrontPosForLine3;
						_i = _countFrontPosForLine2;
					};						
				};
			};
		};
	};
	_arrSortedPath = [_firstPos,_secondPos,_thirdPos];

	_prevPos = _thirdPos;
	_nextPos = [];
	_countFrontPosForLine4 = count _arrFrontPosForLine4;
	for [{_i = 0}, {_i < _countFrontPosForLine4}, {_i = _i + 1}] do 
	{
		_countFrontPosForLine5 = count _arrFrontPosForLine4;
		for [{_j = 0}, {_j < _countFrontPosForLine5}, {_j = _j + 1}] do 
		{
			_slctdPos = _arrFrontPosForLine4 select _j;
			if ((_slctdPos distance2D _prevPos) < 600) then 
			{	
				_nextPos = _slctdPos;
				if (((_prevPos select 0) == (_slctdPos select 0)) || ((_prevPos select 1) == (_slctdPos select 1))) then 
				{
					_j = _countFrontPosForLine5;
				};
			}
		};
		_arrFrontPosForLine4 deleteAt (_arrFrontPosForLine4 findIf {_nextPos isEqualTo _x});
		if (_arrSortedPath findIf {_nextPos isEqualTo _x} != -1) exitWith 
		{	
			_arrFrontPosForLine2 = _arrFrontPosForLine2 call BIS_fnc_arrayShuffle;
			call FW_fnc_sortLinePath;
		};
		_arrSortedPath pushBack _nextPos;
		//systemchat format ["i:%1,cnt:%2",_i,_countFrontPosForLine2]; //debug
		_prevPos = _nextPos;
		if (debug) then {sleep 1};
	};
	if (((_arrSortedPath select 0) distance2D (_arrSortedPath select ((count _arrSortedPath) - 1))) > 600) then
	{
		_arrFrontPosForLine2 = _arrFrontPosForLine2 call BIS_fnc_arrayShuffle;
		call FW_fnc_sortLinePath;
	};
	_arrSortedPath