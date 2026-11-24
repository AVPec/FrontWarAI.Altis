/*
    File: fn_drawClosedLine.sqf
    Path: functions\mapLine\fn_drawClosedLine.sqf
    Description:
        Будує плавну замкнену лінію навколо довільної групи квадратів (1000x1000 м,
        напіврозмір 500 м), автоматично знаходячи зовнішній контур і передаючи його
        у `FW_fnc_drawLine`. Підтримує як прямі смуги, так і складні форми (Г-подібні,
        квадрати, зигзаги фронту) чи окремі острови квадратів.

    Parameters:
        Формат 1 (координати окремими елементами):
            ["ColorBlue", [2500,2500], [3500,2500], [4500,2500], [5500,2500]] call FW_fnc_drawClosedLine;

        Формат 2 (координати одним масивом):
            ["ColorBlue", [[2500,2500], [3500,2500], [4500,2500], [5500,2500]]] call FW_fnc_drawClosedLine;

    Returns:
        ARRAY - масив імен створених маркерів POLYLINE
*/

private _color = _this param [0, "ColorBlack", [""]];

// Підтримка обох форматів виклику: [color, pos1, pos2, ...] та [color, [pos1, pos2, ...]]
private _rawSquares = [];
if (
    count _this == 2 &&
    {(_this # 1) isEqualType []} &&
    {count (_this # 1) > 0} &&
    {((_this # 1) # 0) isEqualType []}
) then {
    _rawSquares = _this # 1;
} else {
    _rawSquares = _this select [1, (count _this) - 1];
};

if (_rawSquares isEqualTo []) exitWith { [] };

private _cellSize = 1000;
private _halfSize = 500;

// 1. Індексуємо всі унікальні квадрати в HashMap для швидкого пошуку сусідів
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
} forEach _rawSquares;

if (_uniqueSquares isEqualTo []) exitWith { [] };

// 2. Збираємо всі зовнішні ребра (направлені проти годинникової стрілки навколо фігури)
//    Для кожного ребра зберігаємо [endX, endY, midX, midY]
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

    // Нижній сусід відсутній -> нижнє зовнішнє ребро (зліва направо)
    if !((format ["%1_%2", _cx, _cy - _cellSize]) in _cellMap) then {
        [_cx - _halfSize, _cy - _halfSize, _cx + _halfSize, _cy - _halfSize, _cx, _cy - _halfSize] call _fn_addEdge;
    };

    // Правий сусід відсутній -> праве зовнішнє ребро (знизу вгору)
    if !((format ["%1_%2", _cx + _cellSize, _cy]) in _cellMap) then {
        [_cx + _halfSize, _cy - _halfSize, _cx + _halfSize, _cy + _halfSize, _cx + _halfSize, _cy] call _fn_addEdge;
    };

    // Верхній сусід відсутній -> верхнє зовнішнє ребро (справа наліво)
    if !((format ["%1_%2", _cx, _cy + _cellSize]) in _cellMap) then {
        [_cx + _halfSize, _cy + _halfSize, _cx - _halfSize, _cy + _halfSize, _cx, _cy + _halfSize] call _fn_addEdge;
    };

    // Лівий сусід відсутній -> ліве зовнішнє ребро (згори вниз)
    if !((format ["%1_%2", _cx - _cellSize, _cy]) in _cellMap) then {
        [_cx - _halfSize, _cy + _halfSize, _cx - _halfSize, _cy - _halfSize, _cx - _halfSize, _cy] call _fn_addEdge;
    };
} forEach _uniqueSquares;

// 3. Зшиваємо зовнішні ребра у замкнені контури та малюємо кожен контур через FW_fnc_drawLine
private _createdMarkers = [];

while {count _edgeMap > 0} do {
    private _startKey = (keys _edgeMap) # 0;
    private _currKey = _startKey;
    private _loopPoints = [];

    while {_currKey in _edgeMap} do {
        private _edges = _edgeMap get _currKey;
        private _edge = _edges deleteAt 0;
        if (_edges isEqualTo []) then {
            _edgeMap deleteAt _currKey;
        } else {
            _edgeMap set [_currKey, _edges];
        };

        _edge params ["_ex", "_ey", "_mx", "_my"];
        _loopPoints pushBack [_mx, _my];

        _currKey = format ["%1_%2", _ex, _ey];
        if (_currKey == _startKey) exitWith {};
    };

    private _cnt = count _loopPoints;
    if (_cnt >= 3) then {
        // Шукаємо точку на прямій ділянці (де попередня, поточна і наступна лежать на одній осі),
        // щоб місце змикання контуру було максимально плавним без зламу
        private _bestStart = 0;
        for "_i" from 0 to (_cnt - 1) do {
            private _prev = _loopPoints # ((_i - 1 + _cnt) mod _cnt);
            private _curr = _loopPoints # _i;
            private _next = _loopPoints # ((_i + 1) mod _cnt);

            if (
                ((_prev # 0) == (_curr # 0) && {(_curr # 0) == (_next # 0)}) ||
                {(_prev # 1) == (_curr # 1) && {(_curr # 1) == (_next # 1)}}
            ) exitWith {
                _bestStart = _i;
            };
        };

        // Повертаємо масив до знайденої стартової точки і замикаємо контур
        private _orderedPoints = [];
        for "_i" from 0 to (_cnt - 1) do {
            _orderedPoints pushBack (_loopPoints # ((_bestStart + _i) mod _cnt));
        };
        _orderedPoints pushBack (_orderedPoints # 0);

        private _mkr = [_orderedPoints, _color] call FW_fnc_drawLine;
        if (_mkr != "") then {
            _createdMarkers pushBack _mkr;
        };
    };
};

_createdMarkers