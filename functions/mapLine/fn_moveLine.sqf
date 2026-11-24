/*
    File: fn_moveLine.sqf
    Path: functions\mapLine\fn_moveLine.sqf
    Description:
        Переносить існуючу лінію (маркер POLYLINE або масив маркерів POLYLINE,
        створених через `FW_fnc_drawLine` чи `FW_fnc_drawClosedLine`) з позиції A
        на позицію B, зміщуючи всі вершини полілінії на вектор (B - A).
        Підтримує як миттєве перенесення, так і плавну анімацію переміщення.

    Parameters:
        0: _lineMarkers - STRING (ім'я одного маркера POLYLINE) або ARRAY (масив імен маркерів)
        1: _posA        - ARRAY (початкова опорна позиція [x, y] або [x, y, z]).
                          Якщо передати [], за точку A береться поточний центр маркера (getMarkerPos).
        2: _posB        - ARRAY (цільова позиція [x, y] або [x, y, z])
        3: _duration    - NUMBER (опціонально, за замовчуванням: 0) - тривалість плавного
                          перенесення в секундах (0 = миттєво)

    Returns:
        BOOL - true, якщо перенесення успішно виконано/запущено, інакше false

    Examples:
        // 1. Миттєве перенесення однієї лінії з позиції A на позицію B
        private _mkr = [_redMarkerPositions, "colorRed"] call FW_fnc_drawLine;
        [_mkr, [2500, 2500], [4500, 5500]] call FW_fnc_moveLine;

        // 2. Плавне перенесення замкненої лінії (з FW_fnc_drawClosedLine) за 3 секунди
        private _closedMkrs = ["ColorBlue", _yellowMarkerPositions] call FW_fnc_drawClosedLine;
        [_closedMkrs, [2500, 3500], [5500, 6500], 3] call FW_fnc_moveLine;

        // 3. Перенесення центру лінії прямо в задану точку B (без вказування A)
        [_mkr, [], [6000, 6000]] call FW_fnc_moveLine;
*/

params [
    ["_lineMarkers", [], ["", []]],
    ["_posA", [], [[]]],
    ["_posB", [], [[]]],
    ["_duration", 0, [0]]
];

if (count _posB < 2) exitWith {
    diag_log "[fn_moveLine] ERROR: Некоректна цільова позиція _posB.";
    false
};

private _markers = if (_lineMarkers isEqualType "") then { [_lineMarkers] } else { _lineMarkers };
_markers = _markers select { _x isEqualType "" && {markerShape _x == "POLYLINE"} };

if (_markers isEqualTo []) exitWith {
    diag_log "[fn_moveLine] ERROR: Не знайдено жодного дійсного маркера POLYLINE.";
    false
};

// Якщо _posA не задано, беремо поточну позицію першого маркера як опорну точку A
if (count _posA < 2) then {
    _posA = getMarkerPos (_markers # 0);
};

private _dx = (_posB # 0) - (_posA # 0);
private _dy = (_posB # 1) - (_posA # 1);

// Допоміжна функція зміщення всіх вершин полілінії та центру маркера на (offX, offY)
private _fn_applyOffset = {
    params ["_mkr", "_origPoly", "_origPos", "_offX", "_offY"];
    private _newPoly = [];
    private _cnt = count _origPoly;

    for "_i" from 0 to (_cnt - 2) step 2 do {
        _newPoly pushBack ((_origPoly # _i) + _offX);
        _newPoly pushBack ((_origPoly # (_i + 1)) + _offY);
    };

    _mkr setMarkerPosLocal [(_origPos # 0) + _offX, (_origPos # 1) + _offY];
    _mkr setMarkerPolyline _newPoly;
};

// Зберігаємо початковий стан усіх маркерів
private _snapshots = _markers apply {
    [_x, markerPolyline _x, getMarkerPos _x]
};

// Варіант 1: Миттєве перенесення
if (_duration <= 0) exitWith {
    {
        _x params ["_mkr", "_origPoly", "_origPos"];
        [_mkr, _origPoly, _origPos, _dx, _dy] call _fn_applyOffset;
    } forEach _snapshots;
    true
};

// Варіант 2: Плавне перенесення протягом _duration секунд
[_snapshots, _dx, _dy, _duration, _fn_applyOffset] spawn {
    params ["_snaps", "_totalDx", "_totalDy", "_dur", "_applyFn"];

    private _startTime = diag_tickTime;
    private _progress = 0;

    while {_progress < 1} do {
        _progress = ((diag_tickTime - _startTime) / _dur) min 1;

        {
            _x params ["_mkr", "_origPoly", "_origPos"];
            if (markerShape _mkr == "POLYLINE") then {
                [_mkr, _origPoly, _origPos, _totalDx * _progress, _totalDy * _progress] call _applyFn;
            };
        } forEach _snaps;

        if (_progress < 1) then { sleep 0.05 };
    };
};

true