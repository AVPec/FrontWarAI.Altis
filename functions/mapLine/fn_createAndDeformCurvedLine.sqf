/*
    File: fn_createAndDeformCurvedLine.sqf
    Path: functions\mapLine\fn_createAndDeformCurvedLine.sqf
    Description:
        Створює плавну замкнену криву лінію (POLYLINE) по краях початкового набору квадратів
        (1000x1000 м) та плавно деформує її форму до країв кінцевого набору квадратів
        протягом заданої кількості секунд.

    Parameters:
        0: _color          - STRING (колір маркера, напр. "colorBlue", "ColorRed")
        1: _squaresStart   - ARRAY (початкові координати квадратів [[x1,y1], [x2,y2], ...])
        2: _squaresEnd     - ARRAY (кінцеві координати квадратів [[x1,y1], [x2,y2], ...])
        3: _duration       - NUMBER (опціонально, за замовчуванням: 10) - час деформації в секундах
        4: _existingMarker - STRING (опціонально, за замовчуванням: "") - існуючий маркер POLYLINE,
                             якщо потрібно деформувати вже створену лінію замість створення нової

    Returns:
        STRING - ім'я створеного (або переданого) маркера POLYLINE ("" у разі помилки)

    Examples:
        // Створити синю криву навколо 2 квадратів і плавно розширити її до 3 квадратів за 10 секунд
        [
            "colorBlue",
            [[1500,2500],[2500,2500]],
            [[1500,2500],[2500,2500],[3500,2500]],
            10
        ] call FW_fnc_createAndDeformCurvedLine;
*/

params [
    ["_color", "ColorBlue", [""]],
    ["_squaresStart", [], [[]]],
    ["_squaresEnd", [], [[]]],
    ["_duration", 10, [0]],
    ["_existingMarker", "", [""]]
];

if (_squaresStart isEqualTo [] || {_squaresEnd isEqualTo []}) exitWith {
    diag_log "[fn_createAndDeformCurvedLine] ERROR: _squaresStart та _squaresEnd не можуть бути порожніми.";
    ""
};

private _sampleCount = 96; // Фіксована кількість вершин для плавного морфінгу без ривків

// Допоміжна функція: будує замкнену плавну криву Безьє по краях набору квадратів
// і передискретизує її у рівно _n рівномірних точок по довжині дуги
private _fn_buildResampledLoop = {
    params ["_squares", "_n"];

    private _cellSize = 1000;
    private _halfSize = 500;

    // 1. Унікальні квадрати в HashMap
    private _cellMap = createHashMap;
    private _uniqueSquares = [];
    {
        if (_x isEqualType [] && {count _x >= 2}) then {
            private _cx = round (_x # 0);
            private _cy = round (_x # 1);
            private _key = format ["%1_%2", _cx, _cy];
            if !(_key in _cellMap) then {
                _cellMap set [_key, true];
                _uniqueSquares pushBack [_cx, _cy];
            };
        };
    } forEach _squares;

    if (_uniqueSquares isEqualTo []) exitWith { [] };

    // 2. Зовнішні ребра (CCW) та їхні середини
    private _edgeMap = createHashMap;
    private _fn_addEdge = {
        params ["_sx", "_sy", "_ex", "_ey", "_mx", "_my"];
        private _sKey = format ["%1_%2", _sx, _sy];
        private _list = _edgeMap getOrDefault [_sKey, []];
        _list pushBack [_ex, _ey, _mx, _my];
        _edgeMap set [_sKey, _list];
    };

    {
        _x params ["_cx", "_cy"];
        if !((format ["%1_%2", _cx, _cy - _cellSize]) in _cellMap) then {
            [_cx - _halfSize, _cy - _halfSize, _cx + _halfSize, _cy - _halfSize, _cx, _cy - _halfSize] call _fn_addEdge;
        };
        if !((format ["%1_%2", _cx + _cellSize, _cy]) in _cellMap) then {
            [_cx + _halfSize, _cy - _halfSize, _cx + _halfSize, _cy + _halfSize, _cx + _halfSize, _cy] call _fn_addEdge;
        };
        if !((format ["%1_%2", _cx, _cy + _cellSize]) in _cellMap) then {
            [_cx + _halfSize, _cy + _halfSize, _cx - _halfSize, _cy + _halfSize, _cx, _cy + _halfSize] call _fn_addEdge;
        };
        if !((format ["%1_%2", _cx - _cellSize, _cy]) in _cellMap) then {
            [_cx - _halfSize, _cy + _halfSize, _cx - _halfSize, _cy - _halfSize, _cx - _halfSize, _cy] call _fn_addEdge;
        };
    } forEach _uniqueSquares;

    // 3. Збираємо найбільший замкнений контур (зовнішній периметр)
    private _bestLoop = [];
    while {count _edgeMap > 0} do {
        private _startKey = (keys _edgeMap) # 0;
        private _currKey = _startKey;
        private _loop = [];

        while {_currKey in _edgeMap} do {
            private _edges = _edgeMap get _currKey;
            private _edge = _edges deleteAt 0;
            if (_edges isEqualTo []) then {
                _edgeMap deleteAt _currKey;
            } else {
                _edgeMap set [_currKey, _edges];
            };

            _edge params ["_ex", "_ey", "_mx", "_my"];
            _loop pushBack [_mx, _my, 0];

            _currKey = format ["%1_%2", _ex, _ey];
            if (_currKey == _startKey) exitWith {};
        };

        if (count _loop > count _bestLoop) then {
            _bestLoop = _loop;
        };
    };

    private _m = count _bestLoop;
    if (_m < 3) exitWith { [] };

    // 4. Замкнена інтерполяція Безьє (циклічні індекси забезпечують плавність у всіх точках)
    private _curvature = 1;
    private _tweensCount = 10;

    private _as = [];
    for "_i" from 0 to (_m - 1) do {
        private _pCurr = _bestLoop # _i;
        private _pNext = _bestLoop # ((_i + 1) mod _m);
        _as pushBack ((_pCurr vectorAdd _pNext) vectorMultiply 0.5);
    };

    private _cs = [];
    for "_i" from 0 to (_m - 1) do {
        private _prevIdx = (_i - 1 + _m) mod _m;
        private _nextIdx = (_i + 1) mod _m;
        private _pPrev = _bestLoop # _prevIdx;
        private _pCurr = _bestLoop # _i;
        private _pNext = _bestLoop # _nextIdx;

        private _aPrev = _as # _prevIdx;
        private _aCurr = _as # _i;
        private _l1 = _pPrev distance _pCurr;
        private _l2 = _pCurr distance _pNext;
        private _b = vectorLinearConversion [0.0, 1.0, _l1 / ((_l1 + _l2) max 0.001), _aPrev, _aCurr];

        _cs pushBack [_pCurr, _aPrev vectorDiff _b, _aCurr vectorDiff _b];
    };

    private _denseCurve = [];
    private _step = 1 / _tweensCount;
    for "_i" from 0 to (_m - 1) do {
        private _pCurr = _bestLoop # _i;
        private _pNext = _bestLoop # ((_i + 1) mod _m);

        (_cs # _i) params ["_anc1", "", "_nextOff1"];
        private _ctrl1 = _anc1 vectorAdd (_nextOff1 vectorMultiply _curvature);

        (_cs # ((_i + 1) mod _m)) params ["_anc2", "_prevOff2", ""];
        private _ctrl2 = _anc2 vectorAdd (_prevOff2 vectorMultiply _curvature);

        private _ctrlPts = [_pCurr, _ctrl1, _ctrl2, _pNext];
        for "_k" from 0 to (_tweensCount - 1) do {
            _denseCurve pushBack ((_k * _step) bezierInterpolation _ctrlPts);
        };
    };

    // 5. Передискретизація замкненої кривої за довжиною дуги у рівно _n точок
    private _dCount = count _denseCurve;
    private _cumDist = [0];
    private _totalLen = 0;

    for "_i" from 0 to (_dCount - 1) do {
        private _p1 = _denseCurve # _i;
        private _p2 = _denseCurve # ((_i + 1) mod _dCount);
        _totalLen = _totalLen + (_p1 distance2D _p2);
        _cumDist pushBack _totalLen;
    };

    if (_totalLen <= 0) exitWith { [] };

    private _resampled = [];
    private _segIdx = 0;
    for "_i" from 0 to (_n - 1) do {
        private _targetDist = (_i / _n) * _totalLen;
        while {_segIdx < (_dCount - 1) && {(_cumDist # (_segIdx + 1)) < _targetDist}} do {
            _segIdx = _segIdx + 1;
        };

        private _d0 = _cumDist # _segIdx;
        private _d1 = _cumDist # (_segIdx + 1);
        private _frac = if (_d1 > _d0) then { (_targetDist - _d0) / (_d1 - _d0) } else { 0 };

        private _p1 = _denseCurve # _segIdx;
        private _p2 = _denseCurve # ((_segIdx + 1) mod _dCount);

        _resampled pushBack [
            (_p1 # 0) + ((_p2 # 0) - (_p1 # 0)) * _frac,
            (_p1 # 1) + ((_p2 # 1) - (_p1 # 1)) * _frac
        ];
    };

    _resampled
};

// Будуємо початкову та кінцеву передискретизовані криві
private _ptsStart = [_squaresStart, _sampleCount] call _fn_buildResampledLoop;
private _ptsEnd = [_squaresEnd, _sampleCount] call _fn_buildResampledLoop;

if (_ptsStart isEqualTo [] || {_ptsEnd isEqualTo []}) exitWith {
    diag_log "[fn_createAndDeformCurvedLine] ERROR: Не вдалося побудувати контур для заданих квадратів.";
    ""
};

// Знаходимо оптимальний циклічний зсув _ptsEnd, щоб мінімізувати шлях вершин (усуває перекручування лінії)
private _bestShift = 0;
private _bestCost = 1e30;

for "_shift" from 0 to (_sampleCount - 1) step 2 do {
    private _cost = 0;
    for "_i" from 0 to (_sampleCount - 1) step 2 do {
        private _pA = _ptsStart # _i;
        private _pB = _ptsEnd # ((_i + _shift) mod _sampleCount);
        private _dx = (_pB # 0) - (_pA # 0);
        private _dy = (_pB # 1) - (_pA # 1);
        _cost = _cost + (_dx * _dx) + (_dy * _dy);
    };
    if (_cost < _bestCost) then {
        _bestCost = _cost;
        _bestShift = _shift;
    };
};

// Уточнюємо зсув на ±1
{
    private _cand = (_bestShift + _x + _sampleCount) mod _sampleCount;
    private _cost = 0;
    for "_i" from 0 to (_sampleCount - 1) do {
        private _pA = _ptsStart # _i;
        private _pB = _ptsEnd # ((_i + _cand) mod _sampleCount);
        private _dx = (_pB # 0) - (_pA # 0);
        private _dy = (_pB # 1) - (_pA # 1);
        _cost = _cost + (_dx * _dx) + (_dy * _dy);
    };
    if (_cost < _bestCost) then {
        _bestCost = _cost;
        _bestShift = _cand;
    };
} forEach [-1, 1];

// Повертаємо _ptsEnd на оптимальний зсув
private _alignedEnd = [];
for "_i" from 0 to (_sampleCount - 1) do {
    _alignedEnd pushBack (_ptsEnd # ((_i + _bestShift) mod _sampleCount));
};

// Допоміжна функція перетворення масиву точок [[x,y],...] у замкнений формат POLYLINE [x0,y0,...,x0,y0]
private _fn_toPolyline = {
    params ["_pts"];
    private _poly = [];
    {
        _poly pushBack (_x # 0);
        _poly pushBack (_x # 1);
    } forEach _pts;
    _poly pushBack ((_pts # 0) # 0);
    _poly pushBack ((_pts # 0) # 1);
    _poly
};

// Обчислюємо початковий центр маркера
private _sumX = 0;
private _sumY = 0;
{
    _sumX = _sumX + (_x # 0);
    _sumY = _sumY + (_x # 1);
} forEach _ptsStart;
private _startCenter = [_sumX / _sampleCount, _sumY / _sampleCount];

// Створюємо новий маркер POLYLINE або використовуємо переданий
private _marker = if (_existingMarker != "" && {markerShape _existingMarker == "POLYLINE"}) then {
    _existingMarker
} else {
    createMarker [format ["markerDeformLine_%1_%2", diag_tickTime, floor (random 100000)], _startCenter]
};

_marker setMarkerShapeLocal "POLYLINE";
_marker setMarkerColorLocal _color;
_marker setMarkerPolyline ([_ptsStart] call _fn_toPolyline);

// Якщо тривалість <= 0 — одразу застосовуємо фінальну форму
if (_duration <= 0) exitWith {
    _marker setMarkerPolyline ([_alignedEnd] call _fn_toPolyline);
    _marker
};

// Запускаємо плавну деформацію протягом _duration секунд (із плавним прискоренням/гальмуванням Smoothstep)
[_marker, _ptsStart, _alignedEnd, _duration, _sampleCount] spawn {
    params ["_mkr", "_pStart", "_pEnd", "_dur", "_n"];

    private _startTime = diag_tickTime;
    private _t = 0;

    while {_t < 1 && {markerShape _mkr == "POLYLINE"}} do {
        _t = ((diag_tickTime - _startTime) / _dur) min 1;
        // Плавна функція Smoothstep: 3t^2 - 2t^3
        private _s = _t * _t * (3 - 2 * _t);

        private _poly = [];
        private _cx = 0;
        private _cy = 0;

        for "_i" from 0 to (_n - 1) do {
            private _a = _pStart # _i;
            private _b = _pEnd # _i;
            private _x = (_a # 0) + ((_b # 0) - (_a # 0)) * _s;
            private _y = (_a # 1) + ((_b # 1) - (_a # 1)) * _s;
            _poly pushBack _x;
            _poly pushBack _y;
            _cx = _cx + _x;
            _cy = _cy + _y;
        };

        // Замикаємо контур у першій точці
        _poly pushBack (_poly # 0);
        _poly pushBack (_poly # 1);

        _mkr setMarkerPosLocal [_cx / _n, _cy / _n];
        _mkr setMarkerPolyline _poly;

        if (_t < 1) then { sleep 0.05 };
    };
};

_marker