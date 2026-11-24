/*
    File: fn_getDotSquarePositions.sqf
    Path: functions\mapLine\fn_getDotSquarePositions.sqf
    Description:
        Знаходить на карті всі маркери типу "mil_dot" (або іншого заданого типу),
        визначає центри відповідних квадратів сітки (1000x1000 м, напр. [2500, 3500])
        та повертає масив унікальних 2D-координат цих квадратів.
        Результат можна напряму передавати у `FW_fnc_drawClosedLine`.

    Parameters:
        0: _markerType  - STRING (опціонально, за замовчуванням: "mil_dot") - тип маркера для пошуку
        1: _markerColor - STRING (опціонально, за замовчуванням: "") - фільтр за кольором маркера
                          (порожній рядок = усі кольори; порівняння без урахування регістру)
        2: _cellSize    - NUMBER (опціонально, за замовчуванням: 1000) - розмір квадрата сітки в метрах

    Returns:
        ARRAY - масив унікальних 2D-координат центрів квадратів [[x1, y1], [x2, y2], ...]

    Examples:
        // 1. Знайти всі квадрати з маркерами "mil_dot" і обвести їх синьою плавною лінією
        private _squares = [] call FW_fnc_getDotSquarePositions;
        ["ColorBlue", _squares] call FW_fnc_drawClosedLine;

        // 2. Знайти тільки ті квадрати, де стоять червоні маркери "mil_dot"
        private _redSquares = ["hd_dot", "ColorRed"] call FW_fnc_getDotSquarePositions;
        ["ColorRed", _redSquares] call FW_fnc_drawClosedLine;
*/

params [
    ["_markerType", "hd_dot", [""]],
    ["_markerColor", "", [""]],
    ["_cellSize", 1000, [0]]
];

if (_cellSize <= 0) then { _cellSize = 1000 };

private _halfSize = _cellSize * 0.5;
private _filterColor = _markerColor != "";
private _seen = createHashMap;
private _squarePositions = [];

{
    if (
        getMarkerType _x == _markerType &&
        {!_filterColor || {getMarkerColor _x == _markerColor}}
    ) then {
        private _pos = getMarkerPos _x;
        private _sqX = (floor ((_pos # 0) / _cellSize)) * _cellSize + _halfSize;
        private _sqY = (floor ((_pos # 1) / _cellSize)) * _cellSize + _halfSize;

        private _key = format ["%1_%2", _sqX, _sqY];
        if !(_key in _seen) then {
            _seen set [_key, true];
            _squarePositions pushBack [_sqX, _sqY];
        };
    };
} forEach allMapMarkers;

_squarePositions