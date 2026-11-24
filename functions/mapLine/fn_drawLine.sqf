// Adapted from: http://web.archive.org/web/20131027060328/http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
params [
	["_points", [], [[]]],
	["_color", "ColorBlack", [""]],
	["_markerName", "", [""]]
];

if (count _points < 2) exitWith { "" };

// Нормалізуємо всі 2D-координати [x, y] у 3D-вектори [x, y, 0] для vector* та bezierInterpolation
_points = _points apply {
	if (count _x == 2) then { [_x # 0, _x # 1, 0] } else { _x };
};

private _curvature = 1;
private _tweensCount = 10;

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

private _sum = [0, 0, 0];
{_sum = _sum vectorAdd _x} forEach _interpolatedPoints;
private _markerPos = _sum vectorMultiply (1 / count _interpolatedPoints);

private _polyline = [];
{
	_polyline pushBack (_x select 0);
	_polyline pushBack (_x select 1);
} forEach _interpolatedPoints;

// Генеруємо унікальне ім'я маркера, якщо не передано власне (щоб не перекривати попередні лінії)
if (_markerName == "") then {
	_markerName = format ["markerLine_%1_%2", diag_tickTime, floor (random 100000)];
};

private _marker = createMarker [_markerName, _markerPos];
_marker setMarkerShapeLocal "POLYLINE";
_marker setMarkerColorLocal _color;
_marker setMarkerPolyline _polyline;
_marker