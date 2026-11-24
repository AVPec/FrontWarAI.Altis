/*
    File: fn_updateFrontLines.sqf
    Path: functions\mapLine\fn_updateFrontLines.sqf
    Description:
        Подієво-орієнтована функція оновлення ліній фронту (викликається з `main.sqf`
        лише при старті та при реальній зміні квадратів).
        - Будує червону лінію на стику жовтих (FrontPos) і червоних (RedPos) квадратів
          із перпендикулярними штрихами (короткий/довгий), спрямованими в бік червоної зони.
        - Будує зелену лінію на стику жовтих (FrontPos) і зелених (GreenPos) квадратів
          із перпендикулярними штрихами, спрямованими в бік зеленої зони.
        - Подовжує обидва кінці відкритих ліній на 1500 м уздовж напрямку крайніх ребер.
        - Усі штрихи вбудовані в той самий один маркер POLYLINE (без створення зайвих маркерів)
          і плавно деформуються, з'являються та зникають разом із лінією.

    Parameters:
        0: _yellowSquaresPositions - ARRAY (за замовчуванням: missionNamespace "FrontPos")
        1: _greenSquaresPositions  - ARRAY (за замовчуванням: missionNamespace "GreenPos")
        2: _redSquaresPositions    - ARRAY (за замовчуванням: missionNamespace "RedPos")
        3: _colorYellowRed         - STRING (за замовчуванням: "ColorRed")
        4: _colorYellowGreen       - STRING (за замовчуванням: "ColorGUER")
        5: _morphDuration          - NUMBER (за замовчуванням: 5)    - час плавної анімації в секундах
        6: _endExtension           - NUMBER (за замовчуванням: 1500) - подовження кінців відкритих ліній у метрах
        7: _tickShortLen           - NUMBER (за замовчуванням: 200)  - довжина короткого штриха в метрах (0 = без штрихів)
        8: _tickLongLen            - NUMBER (за замовчуванням: 400)  - довжина довгого штриха в метрах

    Usage (із main.sqf):
        [_frontPositions, _greenPositions, _redPositions] call FW_fnc_updateFrontLines;
*/

params [
    ["_yellowSquaresPositions", missionNamespace getVariable ["FrontPos", []], [[]]],
    ["_greenSquaresPositions", missionNamespace getVariable ["GreenPos", []], [[]]],
    ["_redSquaresPositions", missionNamespace getVariable ["RedPos", []], [[]]],
    ["_colorYellowRed", "ColorRed", [""]],
    ["_colorYellowGreen", "ColorGUER", [""]],
    ["_morphDuration", 5, [0]],
    ["_endExtension", 1500, [0]],
    ["_tickShortLen", 200, [0]],
    ["_tickLongLen", 400, [0]]
];

private _cellSize = 1000;
private _halfSize = 500;
private _sampleCount = 64;

// -------------------------------------------------------------------------
// 1. Витягує плавні передискретизовані криві по всіх стиках між _setA (жовті) та _setB
//    Орієнтація ребер гарантує, що ліва нормаль (-ty, tx) завжди дивиться в бік _setB
// -------------------------------------------------------------------------
private _fn_extractBoundaryCurves = {
    params ["_setA", "_setB", "_cSize", "_hSize", "_nSamples", "_extLen"];

    if (_setA isEqualTo [] || {_setB isEqualTo []}) exitWith { [] };

    private _mapB = createHashMap;
    {
        if (_x isEqualType [] && {count _x >= 2}) then {
            _mapB set [format ["%1_%2", round (_x # 0), round (_x # 1)], true];
        };
    } forEach _setB;

    private _outEdges = createHashMap;
    private _inDegree = createHashMap;
    private _seenA = createHashMap;

    private _fn_addEdge = {
        params ["_sx", "_sy", "_ex", "_ey"];
        private _sKey = format ["%1_%2", _sx, _sy];
        private _eKey = format ["%1_%2", _ex, _ey];

        private _list = _outEdges getOrDefault [_sKey, []];
        _list pushBack [_ex, _ey, _sx, _sy];
        _outEdges set [_sKey, _list];

        _inDegree set [_eKey, (_inDegree getOrDefault [_eKey, 0]) + 1];
    };

    {
        if (_x isEqualType [] && {count _x >= 2}) then {
            private _cx = round (_x # 0);
            private _cy = round (_x # 1);
            private _aKey = format ["%1_%2", _cx, _cy];

            if !(_aKey in _seenA) then {
                _seenA set [_aKey, true];

                if ((format ["%1_%2", _cx, _cy + _cSize]) in _mapB) then {
                    [_cx - _hSize, _cy + _hSize, _cx + _hSize, _cy + _hSize] call _fn_addEdge;
                };
                if ((format ["%1_%2", _cx + _cSize, _cy]) in _mapB) then {
                    [_cx + _hSize, _cy + _hSize, _cx + _hSize, _cy - _hSize] call _fn_addEdge;
                };
                if ((format ["%1_%2", _cx, _cy - _cSize]) in _mapB) then {
                    [_cx + _hSize, _cy - _hSize, _cx - _hSize, _cy - _hSize] call _fn_addEdge;
                };
                if ((format ["%1_%2", _cx - _cSize, _cy]) in _mapB) then {
                    [_cx - _hSize, _cy - _hSize, _cx - _hSize, _cy + _hSize] call _fn_addEdge;
                };
            };
        };
    } forEach _setA;

    if (count _outEdges == 0) exitWith { [] };

    private _rawChains = [];
    private _fn_traceFrom = {
        params ["_startKey", "_isClosedHint"];
        private _currKey = _startKey;
        private _verts = [];

        while {_currKey in _outEdges} do {
            private _edges = _outEdges get _currKey;
            private _edge = _edges deleteAt 0;
            if (_edges isEqualTo []) then {
                _outEdges deleteAt _currKey;
            } else {
                _outEdges set [_currKey, _edges];
            };

            _edge params ["_ex", "_ey", "_sx", "_sy"];
            if (_verts isEqualTo []) then {
                _verts pushBack [_sx, _sy];
            };
            _verts pushBack [_ex, _ey];

            _currKey = format ["%1_%2", _ex, _ey];
            if (_isClosedHint && {_currKey == _startKey}) exitWith {};
        };

        private _closed = (count _verts >= 4) && {(_verts # 0) isEqualTo (_verts # (count _verts - 1))};
        [_closed, _verts]
    };

    private _openStarts = (keys _outEdges) select { (_inDegree getOrDefault [_x, 0]) == 0 };
    {
        while {_x in _outEdges} do {
            private _chain = [_x, false] call _fn_traceFrom;
            if (count (_chain # 1) >= 2) then {
                _rawChains pushBack _chain;
            };
        };
    } forEach _openStarts;

    while {count _outEdges > 0} do {
        private _k = (keys _outEdges) # 0;
        private _chain = [_k, true] call _fn_traceFrom;
        if (count (_chain # 1) >= 2) then {
            _rawChains pushBack _chain;
        };
    };

    private _curves = [];
    {
        _x params ["_isClosed", "_verts"];
        private _ctrlSrc = [];
        private _vCnt = count _verts;

        // Подовжуємо початок відкритої лінії на _extLen метрів
        if (!_isClosed) then {
            private _v0 = _verts # 0;
            private _v1 = _verts # 1;
            if (_extLen > 0) then {
                private _dx0 = (_v0 # 0) - (_v1 # 0);
                private _dy0 = (_v0 # 1) - (_v1 # 1);
                private _len0 = (sqrt (_dx0 * _dx0 + _dy0 * _dy0)) max 0.001;
                _ctrlSrc pushBack [
                    (_v0 # 0) + (_dx0 / _len0) * _extLen,
                    (_v0 # 1) + (_dy0 / _len0) * _extLen,
                    0
                ];
            };
            _ctrlSrc pushBack [_v0 # 0, _v0 # 1, 0];
        };

        for "_i" from 0 to (_vCnt - 2) do {
            private _v1 = _verts # _i;
            private _v2 = _verts # (_i + 1);
            _ctrlSrc pushBack [((_v1 # 0) + (_v2 # 0)) * 0.5, ((_v1 # 1) + (_v2 # 1)) * 0.5, 0];
        };

        // Подовжуємо кінець відкритої лінії на _extLen метрів
        if (!_isClosed) then {
            private _vPrev = _verts # (_vCnt - 2);
            private _vLast = _verts # (_vCnt - 1);
            _ctrlSrc pushBack [_vLast # 0, _vLast # 1, 0];
            if (_extLen > 0) then {
                private _dx1 = (_vLast # 0) - (_vPrev # 0);
                private _dy1 = (_vLast # 1) - (_vPrev # 1);
                private _len1 = (sqrt (_dx1 * _dx1 + _dy1 * _dy1)) max 0.001;
                _ctrlSrc pushBack [
                    (_vLast # 0) + (_dx1 / _len1) * _extLen,
                    (_vLast # 1) + (_dy1 / _len1) * _extLen,
                    0
                ];
            };
        };

        private _m = count _ctrlSrc;
        if (_m < 2) then { continue };

        private _curvature = 1;
        private _tweensCount = 8;
        private _step = 1 / _tweensCount;
        private _dense = [];

        if (_isClosed && {_m >= 3}) then {
            private _as = [];
            for "_i" from 0 to (_m - 1) do {
                _as pushBack (((_ctrlSrc # _i) vectorAdd (_ctrlSrc # ((_i + 1) mod _m))) vectorMultiply 0.5);
            };
            private _cs = [];
            for "_i" from 0 to (_m - 1) do {
                private _pPrev = _ctrlSrc # ((_i - 1 + _m) mod _m);
                private _pCurr = _ctrlSrc # _i;
                private _pNext = _ctrlSrc # ((_i + 1) mod _m);
                private _aPrev = _as # ((_i - 1 + _m) mod _m);
                private _aCurr = _as # _i;
                private _l1 = _pPrev distance _pCurr;
                private _l2 = _pCurr distance _pNext;
                private _b = vectorLinearConversion [0.0, 1.0, _l1 / ((_l1 + _l2) max 0.001), _aPrev, _aCurr];
                _cs pushBack [_pCurr, _aPrev vectorDiff _b, _aCurr vectorDiff _b];
            };
            for "_i" from 0 to (_m - 1) do {
                private _pCurr = _ctrlSrc # _i;
                private _pNext = _ctrlSrc # ((_i + 1) mod _m);
                (_cs # _i) params ["_anc1", "", "_nextOff1"];
                (_cs # ((_i + 1) mod _m)) params ["_anc2", "_prevOff2", ""];
                private _ctrl1 = _anc1 vectorAdd (_nextOff1 vectorMultiply _curvature);
                private _ctrl2 = _anc2 vectorAdd (_prevOff2 vectorMultiply _curvature);
                private _cPts = [_pCurr, _ctrl1, _ctrl2, _pNext];
                for "_k" from 0 to (_tweensCount - 1) do {
                    _dense pushBack ((_k * _step) bezierInterpolation _cPts);
                };
            };
        } else {
            private _as = [];
            for "_i" from 0 to (_m - 2) do {
                _as pushBack (((_ctrlSrc # _i) vectorAdd (_ctrlSrc # (_i + 1))) vectorMultiply 0.5);
            };
            private _cs = [];
            for "_i" from 0 to (_m - 3) do {
                private _aCurr = _as # _i;
                private _aNext = _as # (_i + 1);
                private _l1 = (_ctrlSrc # _i) distance (_ctrlSrc # (_i + 1));
                private _l2 = (_ctrlSrc # (_i + 1)) distance (_ctrlSrc # (_i + 2));
                private _b = vectorLinearConversion [0.0, 1.0, _l1 / ((_l1 + _l2) max 0.001), _aCurr, _aNext];
                _cs pushBack [_ctrlSrc # (_i + 1), _aCurr vectorDiff _b, _aNext vectorDiff _b];
            };
            for "_i" from 0 to (_m - 2) do {
                private _pCurr = _ctrlSrc # _i;
                private _pNext = _ctrlSrc # (_i + 1);
                private _ctrl1 = _pCurr;
                if (_i > 0) then {
                    (_cs # (_i - 1)) params ["_anc", "", "_nextOff"];
                    _ctrl1 = _anc vectorAdd (_nextOff vectorMultiply _curvature);
                };
                private _ctrl2 = _pNext;
                if (_i < count _cs) then {
                    (_cs # _i) params ["_anc", "_prevOff", ""];
                    _ctrl2 = _anc vectorAdd (_prevOff vectorMultiply _curvature);
                };
                private _cPts = [_pCurr, _ctrl1, _ctrl2, _pNext];
                for "_k" from 0 to (_tweensCount - 1) do {
                    _dense pushBack ((_k * _step) bezierInterpolation _cPts);
                };
            };
            _dense pushBack (_ctrlSrc # (_m - 1));
        };

        private _dCnt = count _dense;
        if (_dCnt < 2) then { continue };

        private _cumDist = [0];
        private _totalLen = 0;
        private _segCount = if (_isClosed) then { _dCnt } else { _dCnt - 1 };

        for "_i" from 0 to (_segCount - 1) do {
            private _p1 = _dense # _i;
            private _p2 = _dense # ((_i + 1) mod _dCnt);
            _totalLen = _totalLen + (_p1 distance2D _p2);
            _cumDist pushBack _totalLen;
        };

        if (_totalLen <= 0) then { continue };

        private _resampled = [];
        private _segIdx = 0;
        private _denom = if (_isClosed) then { _nSamples } else { (_nSamples - 1) max 1 };

        for "_i" from 0 to (_nSamples - 1) do {
            private _targetDist = (_i / _denom) * _totalLen;
            while {_segIdx < (_segCount - 1) && {(_cumDist # (_segIdx + 1)) < _targetDist}} do {
                _segIdx = _segIdx + 1;
            };
            private _d0 = _cumDist # _segIdx;
            private _d1 = _cumDist # (_segIdx + 1);
            private _frac = if (_d1 > _d0) then { (_targetDist - _d0) / (_d1 - _d0) } else { 0 };
            private _p1 = _dense # _segIdx;
            private _p2 = _dense # ((_segIdx + 1) mod _dCnt);

            _resampled pushBack [
                (_p1 # 0) + ((_p2 # 0) - (_p1 # 0)) * _frac,
                (_p1 # 1) + ((_p2 # 1) - (_p1 # 1)) * _frac
            ];
        };

        _curves pushBack [_isClosed, _resampled];
    } forEach _rawChains;

    _curves
};

// -------------------------------------------------------------------------
// 2. Геометричні утиліти та генерація полілінії з перпендикулярними штрихами
// -------------------------------------------------------------------------
private _fn_centroid = {
    params ["_pts"];
    private _sx = 0;
    private _sy = 0;
    private _n = count _pts;
    { _sx = _sx + (_x # 0); _sy = _sy + (_x # 1); } forEach _pts;
    [_sx / (_n max 1), _sy / (_n max 1)]
};

// Будує єдиний масив POLYLINE: основна лінія + перпендикулярні штрихи (короткий/довгий) у бік _setB
private _fn_toHatchedPolyline = {
    params ["_pts", "_isClosed", "_normalSign", "_shortLen", "_longLen"];
    private _n = count _pts;
    private _poly = [];
    private _hasTicks = (_shortLen > 0 || _longLen > 0) && {_n >= 3};
    private _tickIdx = 0;

    for "_i" from 0 to (_n - 1) do {
        private _p = _pts # _i;
        private _px = _p # 0;
        private _py = _p # 1;
        _poly pushBack _px;
        _poly pushBack _py;

        // Ставимо перпендикулярний штрих через кожну 2-гу точку (пропускаючи самі краї відкритої лінії)
        if (_hasTicks && {(_i mod 2) == 1} && {_isClosed || {_i < (_n - 1)}}) then {
            private _pPrev = if (_isClosed) then {
                _pts # ((_i - 1 + _n) mod _n)
            } else {
                _pts # ((_i - 1) max 0)
            };
            private _pNext = if (_isClosed) then {
                _pts # ((_i + 1) mod _n)
            } else {
                _pts # ((_i + 1) min (_n - 1))
            };

            private _tx = (_pNext # 0) - (_pPrev # 0);
            private _ty = (_pNext # 1) - (_pPrev # 1);
            private _tLen = (sqrt (_tx * _tx + _ty * _ty)) max 0.001;

            // Ліва нормаль (-ty, tx) * _normalSign завжди спрямована в бік відповідної території (Red або Green)
            private _nx = (-_ty / _tLen) * _normalSign;
            private _ny = (_tx / _tLen) * _normalSign;

            // Чергуємо короткий і довгий штрих (як на тактичній карті)
            private _len = if ((_tickIdx mod 2) == 0) then { _shortLen } else { _longLen };
            _tickIdx = _tickIdx + 1;

            // Вихід перпендикулярно на _len м і повернення назад на основну лінію
            _poly pushBack (_px + _nx * _len);
            _poly pushBack (_py + _ny * _len);
            _poly pushBack _px;
            _poly pushBack _py;
        };
    };

    if (_isClosed && {_n > 0}) then {
        _poly pushBack ((_pts # 0) # 0);
        _poly pushBack ((_pts # 0) # 1);
    };

    _poly
};

// Повертає [_alignedPts, _normalSign] (+1 якщо порядок збережено, -1 якщо розвернуто)
private _fn_alignCurve = {
    params ["_ptsStart", "_ptsEnd", "_isClosed"];
    private _n = count _ptsStart;

    if (!_isClosed) exitWith {
        private _costFwd = 0;
        private _costRev = 0;
        for "_i" from 0 to (_n - 1) step 2 do {
            private _a = _ptsStart # _i;
            private _bF = _ptsEnd # _i;
            private _bR = _ptsEnd # (_n - 1 - _i);
            _costFwd = _costFwd + ((_bF # 0) - (_a # 0))^2 + ((_bF # 1) - (_a # 1))^2;
            _costRev = _costRev + ((_bR # 0) - (_a # 0))^2 + ((_bR # 1) - (_a # 1))^2;
        };
        if (_costRev < _costFwd) then {
            private _rev = +_ptsEnd;
            reverse _rev;
            [_rev, -1]
        } else {
            [_ptsEnd, 1]
        };
    };

    private _bestShift = 0;
    private _bestCost = 1e30;
    for "_shift" from 0 to (_n - 1) step 2 do {
        private _cost = 0;
        for "_i" from 0 to (_n - 1) step 2 do {
            private _a = _ptsStart # _i;
            private _b = _ptsEnd # ((_i + _shift) mod _n);
            _cost = _cost + ((_b # 0) - (_a # 0))^2 + ((_b # 1) - (_a # 1))^2;
        };
        if (_cost < _bestCost) then {
            _bestCost = _cost;
            _bestShift = _shift;
        };
    };

    private _aligned = [];
    for "_i" from 0 to (_n - 1) do {
        _aligned pushBack (_ptsEnd # ((_i + _bestShift) mod _n));
    };
    [_aligned, 1]
};

private _fn_hasChanged = {
    params ["_ptsA", "_ptsB"];
    private _changed = false;
    for "_i" from 0 to ((count _ptsA) - 1) step 2 do {
        if (((_ptsA # _i) distance2D (_ptsB # _i)) > 2) exitWith {
            _changed = true;
        };
    };
    _changed
};

private _fn_planBoundaryUpdate = {
    params ["_activeList", "_newCurves", "_color", "_shortLen", "_longLen", "_morphTasks", "_fadeInTasks", "_fadeOutTasks"];

    private _oldCnt = count _activeList;
    private _newCnt = count _newCurves;

    private _oldCentroids = _activeList apply { [_x # 1] call _fn_centroid };
    private _newCentroids = _newCurves apply { [_x # 1] call _fn_centroid };

    private _usedOld = [];
    private _usedNew = [];
    private _nextActive = [];

    private _pairs = [];
    for "_oi" from 0 to (_oldCnt - 1) do {
        for "_ni" from 0 to (_newCnt - 1) do {
            private _d = (_oldCentroids # _oi) distance2D (_newCentroids # _ni);
            _pairs pushBack [_d, _oi, _ni];
        };
    };
    _pairs sort true;

    {
        _x params ["", "_oi", "_ni"];
        if (!(_oi in _usedOld) && {!(_ni in _usedNew)}) then {
            _usedOld pushBack _oi;
            _usedNew pushBack _ni;

            (_activeList # _oi) params ["_mkr", "_oldPts", "_oldClosed", ["_oldSign", 1]];
            (_newCurves # _ni) params ["_newClosed", "_newPts"];

            if (markerShape _mkr != "POLYLINE") then {
                private _c = [_newPts] call _fn_centroid;
                _mkr = createMarker [format ["FW_frontLine_%1_%2", diag_tickTime, floor (random 100000)], _c];
                _mkr setMarkerShapeLocal "POLYLINE";
                _mkr setMarkerColorLocal _color;
                _mkr setMarkerAlphaLocal 0;
                _mkr setMarkerPolyline ([_newPts, _newClosed, 1, _shortLen, _longLen] call _fn_toHatchedPolyline);
                _fadeInTasks pushBack _mkr;
                _nextActive pushBack [_mkr, _newPts, _newClosed, 1];
            } else {
                ([_oldPts, _newPts, _oldClosed && _newClosed] call _fn_alignCurve) params ["_alignedNew", "_newSign"];
                private _entry = [_mkr, _oldPts, _newClosed, _newSign];
                if ([_oldPts, _alignedNew] call _fn_hasChanged || {_oldClosed isNotEqualTo _newClosed} || {_oldSign != _newSign}) then {
                    _morphTasks pushBack [_mkr, _oldPts, _alignedNew, _newClosed, _newSign, _entry];
                } else {
                    _entry set [1, _alignedNew];
                };
                _nextActive pushBack _entry;
            };
        };
    } forEach _pairs;

    for "_ni" from 0 to (_newCnt - 1) do {
        if !(_ni in _usedNew) then {
            (_newCurves # _ni) params ["_newClosed", "_newPts"];
            private _c = [_newPts] call _fn_centroid;
            private _mkr = createMarker [format ["FW_frontLine_%1_%2", diag_tickTime, floor (random 100000)], _c];
            _mkr setMarkerShapeLocal "POLYLINE";
            _mkr setMarkerColorLocal _color;
            _mkr setMarkerAlphaLocal 0;
            _mkr setMarkerPolyline ([_newPts, _newClosed, 1, _shortLen, _longLen] call _fn_toHatchedPolyline);
            _fadeInTasks pushBack _mkr;
            _nextActive pushBack [_mkr, _newPts, _newClosed, 1];
        };
    };

    for "_oi" from 0 to (_oldCnt - 1) do {
        if !(_oi in _usedOld) then {
            private _mkr = (_activeList # _oi) # 0;
            if (markerShape _mkr == "POLYLINE") then {
                _fadeOutTasks pushBack _mkr;
            };
        };
    };

    _nextActive
};

// -------------------------------------------------------------------------
// 3. Одноразовий розрахунок та запуск неблокуючої анімації
// -------------------------------------------------------------------------
private _animToken = (missionNamespace getVariable ["FW_frontLinesAnimToken", 0]) + 1;
missionNamespace setVariable ["FW_frontLinesAnimToken", _animToken];

{ deleteMarker _x } forEach (missionNamespace getVariable ["FW_pendingDeleteFrontLines", []]);
missionNamespace setVariable ["FW_pendingDeleteFrontLines", []];

private _activeRedLines   = missionNamespace getVariable ["FW_activeRedFrontLines", []];
private _activeGreenLines = missionNamespace getVariable ["FW_activeGreenFrontLines", []];

private _newRedCurves   = [_yellowSquaresPositions, _redSquaresPositions, _cellSize, _halfSize, _sampleCount, _endExtension] call _fn_extractBoundaryCurves;
private _newGreenCurves = [_yellowSquaresPositions, _greenSquaresPositions, _cellSize, _halfSize, _sampleCount, _endExtension] call _fn_extractBoundaryCurves;

private _morphTasks = [];
private _fadeInTasks = [];
private _fadeOutTasks = [];

_activeRedLines   = [_activeRedLines, _newRedCurves, _colorYellowRed, _tickShortLen, _tickLongLen, _morphTasks, _fadeInTasks, _fadeOutTasks] call _fn_planBoundaryUpdate;
_activeGreenLines = [_activeGreenLines, _newGreenCurves, _colorYellowGreen, _tickShortLen, _tickLongLen, _morphTasks, _fadeInTasks, _fadeOutTasks] call _fn_planBoundaryUpdate;

missionNamespace setVariable ["FW_activeRedFrontLines", _activeRedLines];
missionNamespace setVariable ["FW_activeGreenFrontLines", _activeGreenLines];
missionNamespace setVariable ["FW_pendingDeleteFrontLines", _fadeOutTasks];

if (_morphTasks isEqualTo [] && {_fadeInTasks isEqualTo []} && {_fadeOutTasks isEqualTo []}) exitWith { true };

if (_morphDuration <= 0) exitWith {
    {
        _x params ["_mkr", "", "_pEnd", "_closed", "_sign", "_entry"];
        if (markerShape _mkr == "POLYLINE") then {
            _mkr setMarkerPosLocal ([_pEnd] call _fn_centroid);
            _mkr setMarkerPolyline ([_pEnd, _closed, _sign, _tickShortLen, _tickLongLen] call _fn_toHatchedPolyline);
            _entry set [1, _pEnd];
        };
    } forEach _morphTasks;
    { if (markerShape _x == "POLYLINE") then { _x setMarkerAlpha 1 } } forEach _fadeInTasks;
    { deleteMarker _x } forEach _fadeOutTasks;
    missionNamespace setVariable ["FW_pendingDeleteFrontLines", []];
    true
};

// Асинхронна плавна анімація морфінгу лінії разом зі штрихами
[_animToken, _morphDuration, _sampleCount, _tickShortLen, _tickLongLen, _morphTasks, _fadeInTasks, _fadeOutTasks, _fn_toHatchedPolyline] spawn {
    params ["_myToken", "_dur", "_n", "_shortLen", "_longLen", "_morphs", "_fadeIns", "_fadeOuts", "_hatchedFn"];

    private _animStart = diag_tickTime;
    private _t = 0;

    while {_t < 1 && {(missionNamespace getVariable ["FW_frontLinesAnimToken", 0]) == _myToken}} do {
        _t = ((diag_tickTime - _animStart) / _dur) min 1;
        private _s = _t * _t * (3 - 2 * _t); // Smoothstep

        {
            _x params ["_mkr", "_pStart", "_pEnd", "_closed", "_sign", "_entry"];
            if (markerShape _mkr == "POLYLINE") then {
                private _livePts = [];
                private _cx = 0;
                private _cy = 0;

                for "_i" from 0 to (_n - 1) do {
                    private _a = _pStart # _i;
                    private _b = _pEnd # _i;
                    private _px = (_a # 0) + ((_b # 0) - (_a # 0)) * _s;
                    private _py = (_a # 1) + ((_b # 1) - (_a # 1)) * _s;
                    _livePts pushBack [_px, _py];
                    _cx = _cx + _px;
                    _cy = _cy + _py;
                };

                _mkr setMarkerPosLocal [_cx / _n, _cy / _n];
                _mkr setMarkerPolyline ([_livePts, _closed, _sign, _shortLen, _longLen] call _hatchedFn);
                _entry set [1, _livePts];
            };
        } forEach _morphs;

        {
            if (markerShape _x == "POLYLINE") then { _x setMarkerAlpha _s };
        } forEach _fadeIns;

        {
            if (markerShape _x == "POLYLINE") then { _x setMarkerAlpha (1 - _s) };
        } forEach _fadeOuts;

        if (_t < 1) then { sleep 0.05 };
    };

    if ((missionNamespace getVariable ["FW_frontLinesAnimToken", 0]) == _myToken) then {
        { deleteMarker _x } forEach _fadeOuts;
        missionNamespace setVariable ["FW_pendingDeleteFrontLines", []];
    };
};

true