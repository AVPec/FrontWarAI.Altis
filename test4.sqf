/*
    File: fn_getCirclePositions.sqf
    Description:
        Будує масив координат точок навколо початкової позиції [0,0] (або заданого центру)
        за годинниковою стрілкою на відстані _numOfCircle.
        При _numOfCircle = 1 повертає 8 точок:
        [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]
        При _numOfCircle = 2 повертає 16 точок на відстані 2 і т.д. (8 * _numOfCircle точок).

    Parameters:
        0: _numOfCircle         - NUMBER (відстань / номер кола, >= 1)
        1: _includeInnerCircles - BOOL (опціонально, за замовчуванням: false)
                                  false = повертає точки тільки на відстані _numOfCircle
                                  true  = повертає точки всіх кіл від 1 до _numOfCircle включно
        2: _centerPos           - ARRAY (опціонально, за замовчуванням: [0,0]) - початкова позиція [x,y]
        3: _step                - NUMBER (опціонально, за замовчуванням: 1) - крок сітки (напр. 1000 для квадратів по 1 км)

    Returns:
        ARRAY - масив координат [[x1,y1], [x2,y2], ...]

    Examples:
        // 1. Точки на відстані 1 навколо [0,0]
        private _posArr1 = [1] call FW_fnc_getCirclePositions;
        // Результат: [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]

        // 2. Точки на відстані 2 навколо [0,0]
        private _posArr2 = [2] call FW_fnc_getCirclePositions;

        // 3. Точки на відстані 2 навколо [_xPos, _yPos] з кроком сітки 1000 м
        private _gridOffsets = [2, false, [_xPos, _yPos], 1000] call FW_fnc_getCirclePositions;
*/

params [
    ["_numOfCircle", 1, [0]],
    ["_includeInnerCircles", false, [false]],
    ["_centerPos", [0, 0], [[]]],
    ["_step", 1, [0]]
];

_numOfCircle = floor _numOfCircle;
if (_numOfCircle < 1) exitWith { [[_centerPos # 0, _centerPos # 1]] };

private _centerX = _centerPos # 0;
private _centerY = _centerPos # 1;
private _startCircle = if (_includeInnerCircles) then { 1 } else { _numOfCircle };
private _positions = [];

for "_r" from _startCircle to _numOfCircle do {
    // 1. Верхня грань (від x = 0 до _r, y = _r)
    for "_x" from 0 to _r do {
        _positions pushBack [_centerX + (_x * _step), _centerY + (_r * _step)];
    };

    // 2. Права грань (x = _r, від y = _r - 1 до -_r)
    for "_y" from (_r - 1) to -_r step -1 do {
        _positions pushBack [_centerX + (_r * _step), _centerY + (_y * _step)];
    };

    // 3. Нижня грань (від x = _r - 1 до -_r, y = -_r)
    for "_x" from (_r - 1) to -_r step -1 do {
        _positions pushBack [_centerX + (_x * _step), _centerY + (-_r * _step)];
    };

    // 4. Ліва грань (x = -_r, від y = -_r + 1 до _r)
    for "_y" from (-_r + 1) to _r do {
        _positions pushBack [_centerX + (-_r * _step), _centerY + (_y * _step)];
    };

    // 5. Залишок верхньої грані (від x = -_r + 1 до -1, y = _r)
    for "_x" from (-_r + 1) to -1 do {
        _positions pushBack [_centerX + (_x * _step), _centerY + (_r * _step)];
    };
};

copytoclipboard str count (_positions)
/*
[[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]
8
[[0,2],[1,2],[2,2],[2,1],[2,0],[2,-1],[2,-2],[1,-2],[0,-2],[-1,-2],[-2,-2],[-2,-1],[-2,0],[-2,1],[-2,2],[-1,2]]
16
[1, false, [0,0], 1] execVM "test4.sqf"