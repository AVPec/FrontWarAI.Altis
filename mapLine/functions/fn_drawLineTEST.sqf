// Adapted from: http://web.archive.org/web/20131027060328/http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
params ["_points","_color"];
_curvature = 1; _tweensCount = 10;

	// Step 1
	private _as = [];

	for "_i" from 0 to (count _points) - 2 do
	{
		private _pCurrent = _points select _i;
		private _pNext = _points select (_i + 1);
		private _a = (_pCurrent vectorAdd _pNext) vectorMultiply 0.5;
		_as pushBack _a;
	};

	// Step 2
	private _bs = [];
	for "_i" from 0 to (count _points) - 3 do 
	{
		private _aCurrent = _as select _i;
		private _aNext = _as select (_i + 1);
		private _l1 = (_points select _i) distance (_points select (_i + 1));
		private _l2 = (_points select (_i + 1)) distance (_points select (_i + 2));
		private _b = vectorLinearConversion [0.0, 1.0, _l1 / (_l1 + _l2), _aCurrent, _aNext];
		_bs pushBack _b;
	};

	private _cs = [];
	for "_i" from 0 to (count _points) - 3 do 
	{
		private _b = _bs select _i;
		private _prevA = _as select _i;
		private _nextA = _as select (_i + 1);
		private _prevOffset = _prevA vectorDiff _b;
		private _nextOffset = _nextA vectorDiff _b;
		private _anchor = _points select (_i + 1);
		_cs pushBack [_anchor, _prevOffset, _nextOffset];
	};

	// Step 3 & 4
	private _allControlPoints = [];
	for "_i" from 0 to (count _points) - 2 do 
	{
		private _pCurrent = _points select _i;
		private _pNext = _points select (_i + 1);
		private _control1 = _pCurrent;

		if (_i > 0) then 
		{
			private _cPrev = _cs select (_i - 1);
			_cPrev params ["_anchor", "_prevOffset", "_nextOffset"];
			_control1 = _anchor vectorAdd (_nextOffset vectorMultiply _curvature);
		};
		
		private _control2 = _pNext;
		if (_i < count _cs) then 
		{
			private _cCurrent = _cs select _i;
			_cCurrent params ["_anchor", "_prevOffset", "_nextOffset"];
			_control2 = _anchor vectorAdd (_prevOffset vectorMultiply _curvature);
		};

		_allControlPoints pushBack [_pCurrent, _control1, _control2, _pNext];
	};

	// Step 5
	private _interpolatedPoints = [];
	{
		private _controlPoints = _x;
		private _step = 1 / _tweensCount;

		for "_t" from 0.0 to 1.0 + 0.25 * _step step _step do 
		{
			_interpolatedPoints pushBack (_t bezierInterpolation _controlPoints);
		};
	} forEach _allControlPoints;



	_sum = [0, 0, 0];
	{_sum = _sum vectorAdd _x} forEach _interpolatedPoints;
	_markerPos = _sum vectorMultiply (1 / count _interpolatedPoints);

	_polyline = [];
	{
		_polyline pushBack (_x select 0);
		_polyline pushBack (_x select 1);
	} forEach _interpolatedPoints;

	//_marker = createMarker ["1111", _markerPos];
	_marker = "1111";
	_marker setMarkerShape "POLYLINE";
	_marker setMarkerColor _color;
	_marker setMarkerPolyline _polyline;
	_interpolatedPoints